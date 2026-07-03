import 'dart:async';

import 'package:flutter/services.dart';

/// Bridges the Flutter layer to the native Zebra RFID SDK (`com.zebra.rfid.api3`)
/// that ships as `android/app/libs/API3_LIB-release-2.0.2.114.aar`.
///
/// The native side is wired through a [MethodChannel] (control) and an
/// [EventChannel] (tag/trigger stream). On platforms/devices where the reader
/// is unavailable (emulators, non-Zebra hardware, iOS), every call degrades
/// gracefully so the rest of the app keeps working with manual/camera input.
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
