package com.garima.midas

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.zebra.rfid.api3.ENUM_TRANSPORT
import com.zebra.rfid.api3.HANDHELD_TRIGGER_EVENT_TYPE
import com.zebra.rfid.api3.RFIDReader
import com.zebra.rfid.api3.ReaderDevice
import com.zebra.rfid.api3.Readers
import com.zebra.rfid.api3.RfidEventsListener
import com.zebra.rfid.api3.RfidReadEvents
import com.zebra.rfid.api3.RfidStatusEvents
import com.zebra.rfid.api3.STATUS_EVENT_TYPE
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges the Flutter layer to the Zebra RFID SDK (`com.zebra.rfid.api3`) that
 * is bundled as `app/libs/API3_LIB-release-2.0.2.114.aar`.
 *
 * MethodChannel `com.garima.midas/rfid`  -> connect / disconnect / isConnected / readSingleTag
 * EventChannel  `com.garima.midas/rfid_tags` -> stream of tag ids (trigger / inventory reads)
 *
 * Everything is wrapped defensively so that on devices without a Zebra reader
 * the calls simply report "not connected" instead of crashing the app.
 */
class RfidBridge(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val worker = Handler(
        android.os.HandlerThread("rfid-worker").apply { start() }.looper,
    )

    private var readers: Readers? = null
    private var reader: RFIDReader? = null
    private var eventSink: EventChannel.EventSink? = null

    init {
        MethodChannel(messenger, CHANNEL_METHODS).setMethodCallHandler(this)
        EventChannel(messenger, CHANNEL_EVENTS).setStreamHandler(this)
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
            "isConnected" -> result.success(isConnected())
            "readSingleTag" -> worker.post {
                performInventory(true)
                mainHandler.post { result.success(null) }
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

    private fun isConnected(): Boolean = reader?.isConnected == true

    private fun connectReader(): Boolean {
        try {
            if (isConnected()) return true

            val readersInstance = readers ?: Readers(context, ENUM_TRANSPORT.ALL).also { readers = it }
            val available: List<ReaderDevice> =
                readersInstance.GetAvailableRFIDReaderList() ?: return false
            if (available.isEmpty()) return false

            val device = available[0]
            val rfidReader = device.rfidReader
            if (!rfidReader.isConnected) {
                rfidReader.connect()
            }
            configureReader(rfidReader)
            reader = rfidReader
            return rfidReader.isConnected
        } catch (t: Throwable) {
            return false
        }
    }

    private fun configureReader(rfidReader: RFIDReader) {
        try {
            rfidReader.Events.addEventsListener(EventHandler())
            rfidReader.Events.setHandheldEvent(true)
            rfidReader.Events.setTagReadEvent(true)
            rfidReader.Events.setAttachTagDataWithReadEvent(false)
        } catch (t: Throwable) {
            // Reader connected but event setup failed; ignore.
        }
    }

    private fun performInventory(stopAfter: Boolean) {
        val rfidReader = reader ?: return
        try {
            rfidReader.Actions.Inventory.perform()
            if (stopAfter) {
                worker.postDelayed({
                    try {
                        rfidReader.Actions.Inventory.stop()
                    } catch (_: Throwable) {
                    }
                }, 600)
            }
        } catch (_: Throwable) {
        }
    }

    private fun stopInventory() {
        try {
            reader?.Actions?.Inventory?.stop()
        } catch (_: Throwable) {
        }
    }

    private fun disconnectReader() {
        try {
            reader?.let {
                stopInventory()
                if (it.isConnected) it.disconnect()
            }
        } catch (_: Throwable) {
        } finally {
            reader = null
            try {
                readers?.Dispose()
            } catch (_: Throwable) {
            }
            readers = null
        }
    }

    private fun emitTag(tagId: String?) {
        if (tagId.isNullOrEmpty()) return
        mainHandler.post { eventSink?.success(tagId) }
    }

    private inner class EventHandler : RfidEventsListener {
        override fun eventReadNotify(events: RfidReadEvents?) {
            val rfidReader = reader ?: return
            try {
                val tags = rfidReader.Actions.getReadTags(100) ?: return
                for (tag in tags) {
                    emitTag(tag.tagID)
                }
            } catch (_: Throwable) {
            }
        }

        override fun eventStatusNotify(events: RfidStatusEvents?) {
            val data = events?.StatusEventData ?: return
            if (data.statusEventType != STATUS_EVENT_TYPE.HANDHELD_TRIGGER_EVENT) return
            val triggerType = data.HandheldTriggerEventData.handheldEvent
            if (triggerType == HANDHELD_TRIGGER_EVENT_TYPE.HANDHELD_TRIGGER_PRESSED) {
                performInventory(false)
            } else if (triggerType == HANDHELD_TRIGGER_EVENT_TYPE.HANDHELD_TRIGGER_RELEASED) {
                stopInventory()
            }
        }
    }

    companion object {
        private const val CHANNEL_METHODS = "com.garima.midas/rfid"
        private const val CHANNEL_EVENTS = "com.garima.midas/rfid_tags"
    }
}
