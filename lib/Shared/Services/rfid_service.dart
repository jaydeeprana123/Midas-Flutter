import 'dart:async';

import 'package:flutter/services.dart';

/// Bridges the Flutter layer to the native Chainway UHF RFID SDK
/// (`com.rscja.deviceapi`) that ships as an aar under `android/app/libs/`.
///
/// The native side is wired through a [MethodChannel] (control) and an
/// [EventChannel] (tag stream). A hardware trigger press is handled natively in
/// `MainActivity.dispatchKeyEvent` and pushes the scanned EPC over [tagStream];
/// continuous inventory ([startInventory]/[stopInventory]) streams every read
/// over the same [tagStream].
/// On
/// platforms/devices where the reader is unavailable (emulators, other
/// hardware, iOS), every call degrades gracefully so the rest of the app keeps
/// working with manual/camera input.
class RfidService {
  static const MethodChannel _methods =
      MethodChannel('com.garima.midas/rfid');
  static const EventChannel _events =
      EventChannel('com.garima.midas/rfid_tags');

  Stream<String>? _tagStream;

  /// Emits tag ids (EPC) as they are read, either from a single read or from a
  /// hardware trigger pull.
  Stream<String> get tagStream {
    _tagStream ??= _events
        .receiveBroadcastStream()
        .map((event) => event?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .handleError((_) {}, test: (_) => true);
    return _tagStream!;
  }

  /// Connects to the first available reader. Returns `false` when no reader is
  /// present or the native bridge is not registered (e.g. on an emulator).
  Future<bool> connect() async {
    try {
      final result = await _methods.invokeMethod<bool>('connect');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _methods.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Performs a single inventory read and returns the first tag id, or `null`.
  Future<String?> readSingleTag() async {
    try {
      return await _methods.invokeMethod<String>('readSingleTag');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Starts continuous inventory. Every tag read is delivered over [tagStream].
  /// Returns `false` if no reader is present / the bridge is unavailable.
  Future<bool> startInventory() async {
    try {
      final result = await _methods.invokeMethod<bool>('startInventory');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Stops continuous inventory started by [startInventory].
  Future<void> stopInventory() async {
    try {
      await _methods.invokeMethod('stopInventory');
    } on MissingPluginException {
      // No native bridge available; nothing to stop.
    } on PlatformException {
      // Ignore failures while stopping.
    }
  }

  /// Plays a success/failure beep on the reader (same sound used for scans).
  Future<void> beep({bool success = true}) async {
    try {
      await _methods.invokeMethod('beep', {'success': success});
    } on MissingPluginException {
      // No native bridge available; skip the beep.
    } on PlatformException {
      // Ignore beep failures.
    }
  }

  Future<void> disconnect() async {
    try {
      await _methods.invokeMethod('disconnect');
    } on MissingPluginException {
      // No native bridge available; nothing to release.
    } on PlatformException {
      // Ignore teardown failures.
    }
  }
}
