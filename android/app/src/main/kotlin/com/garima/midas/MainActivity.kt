package com.garima.midas

import android.util.Log
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var rfidBridge: RfidBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        rfidBridge = RfidBridge(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    // Chainway handheld trigger keys (same codes as the reference AssignQRActivity).
    //
    // We intercept at dispatchKeyEvent (not onKeyDown) because Flutter's view and
    // the focused text field/IME consume key events before they reach the
    // Activity's onKeyDown, so onKeyDown is often never called on the hardware
    // scanner trigger. dispatchKeyEvent runs first, so this reliably fires.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val keyCode = event.keyCode
        // Diagnostic: run `adb logcat -s RfidTrigger` and press the scan button
        // to confirm which key code this device sends.
        if (event.action == KeyEvent.ACTION_DOWN) {
            Log.d("RfidTrigger", "keyDown code=$keyCode")
        }
        if (keyCode == 139 || keyCode == 280 || keyCode == 293) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                rfidBridge?.onTriggerPressed()
            }
            // Consume so the key isn't forwarded to Flutter / the text field.
            return true
        }
        return super.dispatchKeyEvent(event)
    }
}
