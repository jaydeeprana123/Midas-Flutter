package com.garima.midas

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
}
