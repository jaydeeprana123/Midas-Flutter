package com.garima.midas

import android.content.Context
import android.media.AudioManager
import android.media.SoundPool
import android.media.ToneGenerator
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import com.rscja.deviceapi.RFIDWithUHFUART
import com.rscja.deviceapi.interfaces.IUHF
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges the Flutter layer to the Chainway UHF RFID SDK
 * (`com.rscja.deviceapi`, bundled as `app/libs/DeviceAPI_..._release.aar`).
 *
 * This mirrors the behaviour of `AssignQRActivity` / `AuditAssetsActivity` in the
 * reference Android app:
 *  - a hardware trigger press ([onTriggerPressed]) performs a single EPC read
 *    ([readEpc], `readData(EPC bank, ptr 2, len 6)`) and pushes the tag id, and
 *  - continuous inventory ([startInventory]/[stopInventory]) uses
 *    `setInventoryCallback` + `startInventoryTag()` and streams every EPC read.
 * Both paths push tag ids to Flutter over the same [EventChannel].
 *
 * MethodChannel `com.garima.midas/rfid`      -> connect / disconnect / isConnected /
 *                                               readSingleTag / startInventory /
 *                                               stopInventory / beep
 * EventChannel  `com.garima.midas/rfid_tags` -> stream of tag ids (trigger + inventory)
 *
 * Everything is wrapped defensively so that on devices without a Chainway reader
 * (emulators, other hardware) the calls simply report "not connected".
 */
class RfidBridge(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val worker = Handler(
        HandlerThread("rfid-worker").apply { start() }.looper,
    )

    private var reader: RFIDWithUHFUART? = null
    private var eventSink: EventChannel.EventSink? = null

    // Beep feedback (loaded from res/raw if the sound files are present).
    private val audioManager =
        context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
    private var soundPool: SoundPool? = null
    private var soundSuccess = 0
    private var soundError = 0

    // Fallback beeper so a sound always plays even when the optional
    // barcodebeep/serror raw resources aren't bundled in the app.
    private var toneGenerator: ToneGenerator? = null

    init {
        MethodChannel(messenger, CHANNEL_METHODS).setMethodCallHandler(this)
        EventChannel(messenger, CHANNEL_EVENTS).setStreamHandler(this)
        initSound()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> worker.post {
                val ok = connectReader()
                mainHandler.post { result.success(ok) }
            }
            "disconnect" -> worker.post {
                disconnectReader()
                mainHandler.post { result.success(null) }
            }
            "isConnected" -> result.success(reader != null)
            "readSingleTag" -> worker.post {
                val epc = readEpc()
                mainHandler.post { result.success(epc) }
            }
            "startInventory" -> worker.post {
                val ok = startInventory()
                mainHandler.post { result.success(ok) }
            }
            "stopInventory" -> worker.post {
                val ok = stopInventory()
                mainHandler.post { result.success(ok) }
            }
            "beep" -> {
                val success = (call.argument<Boolean>("success")) ?: true
                playSound(success)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun connectReader(): Boolean {
        return try {
            if (reader == null) {
                reader = RFIDWithUHFUART.getInstance()
            }
            val ok = reader?.init() ?: false
            if (!ok) reader = null
            Log.d(TAG, "connectReader -> $ok")
            ok
        } catch (t: Throwable) {
            reader = null
            Log.e(TAG, "connectReader failed", t)
            false
        }
    }

    private fun disconnectReader() {
        try {
            reader?.free()
        } catch (_: Throwable) {
        } finally {
            reader = null
        }
    }

    /**
     * Reads the EPC of the tag currently in the field, matching the reference
     * app's `readData("00000000", IUHF.Bank_EPC, 2, 6)`.
     */
    private fun readEpc(): String? {
        val r = reader ?: run {
            Log.w(TAG, "readEpc: reader not connected")
            return null
        }
        return try {
            val data = r.readData("00000000", IUHF.Bank_EPC, 2, 6)
            Log.d(TAG, "readEpc -> ${data ?: "null"}")
            if (!data.isNullOrEmpty()) {
                playSound(true)
                data
            } else {
                playSound(false)
                null
            }
        } catch (t: Throwable) {
            Log.e(TAG, "readEpc failed", t)
            playSound(false)
            null
        }
    }

    /**
     * Invoked from [MainActivity.dispatchKeyEvent] when a hardware trigger key
     * is pressed. Performs a single read and streams the tag id to Flutter.
     */
    fun onTriggerPressed() {
        worker.post {
            // Connect lazily if the reader hasn't been initialised yet, so the
            // trigger works even before Flutter has called connect().
            if (reader == null) connectReader()
            val epc = readEpc()
            if (!epc.isNullOrEmpty()) {
                mainHandler.post { eventSink?.success(epc) }
            }
        }
    }

    /**
     * Starts continuous inventory, streaming every EPC read to Flutter over the
     * event channel, matching the reference `AuditAssetsActivity`
     * (`setInventoryCallback` + `startInventoryTag`). Beeps are intentionally NOT
     * played here; the Flutter layer decides when to beep so it can do so once
     * per newly-matched tag rather than on every raw callback.
     */
    private fun startInventory(): Boolean {
        if (reader == null) connectReader()
        val r = reader ?: run {
            Log.w(TAG, "startInventory: reader not connected")
            return false
        }
        return try {
            r.setInventoryCallback { info ->
                val epc = info?.epc
                if (!epc.isNullOrEmpty()) {
                    mainHandler.post { eventSink?.success(epc) }
                }
            }
            val ok = r.startInventoryTag()
            Log.d(TAG, "startInventory -> $ok")
            ok
        } catch (t: Throwable) {
            Log.e(TAG, "startInventory failed", t)
            false
        }
    }

    private fun stopInventory(): Boolean {
        return try {
            val ok = reader?.stopInventory() ?: false
            Log.d(TAG, "stopInventory -> $ok")
            ok
        } catch (t: Throwable) {
            Log.e(TAG, "stopInventory failed", t)
            false
        }
    }

    private fun initSound() {
        try {
            soundPool = SoundPool(10, AudioManager.STREAM_MUSIC, 5)
            val okId =
                context.resources.getIdentifier("barcodebeep", "raw", context.packageName)
            val errId =
                context.resources.getIdentifier("serror", "raw", context.packageName)
            if (okId != 0) soundSuccess = soundPool?.load(context, okId, 1) ?: 0
            if (errId != 0) soundError = soundPool?.load(context, errId, 1) ?: 0
        } catch (_: Throwable) {
        }
        try {
            toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, ToneGenerator.MAX_VOLUME)
        } catch (_: Throwable) {
        }
    }

    /**
     * Plays a success/failure beep immediately after a scan, matching the
     * reference app. Prefers the bundled barcodebeep/serror raw resources; if
     * they aren't present it falls back to a system tone so a beep always plays.
     */
    private fun playSound(success: Boolean) {
        val id = if (success) soundSuccess else soundError
        if (id != 0) {
            try {
                val max = audioManager?.getStreamMaxVolume(AudioManager.STREAM_MUSIC)?.toFloat()
                val cur = audioManager?.getStreamVolume(AudioManager.STREAM_MUSIC)?.toFloat()
                val volume = if (max != null && cur != null && max > 0) cur / max else 1f
                soundPool?.play(id, volume, volume, 1, 0, 1f)
                return
            } catch (_: Throwable) {
            }
        }
        try {
            val tone = if (success) ToneGenerator.TONE_PROP_BEEP else ToneGenerator.TONE_PROP_NACK
            val durationMs = if (success) 150 else 250
            toneGenerator?.startTone(tone, durationMs)
        } catch (_: Throwable) {
        }
    }

    companion object {
        private const val TAG = "RfidBridge"
        private const val CHANNEL_METHODS = "com.garima.midas/rfid"
        private const val CHANNEL_EVENTS = "com.garima.midas/rfid_tags"
    }
}
