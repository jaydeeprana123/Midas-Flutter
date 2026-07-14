import 'package:geolocator/geolocator.dart';

/// Provides cached GPS coordinates for RFID tracking, mirroring the reference
/// app's `LocationCache` updated by fused location updates.
class LocationService {
  double _latitude = 0;
  double _longitude = 0;
  DateTime? _lastUpdate;

  double get latitude => _latitude;
  double get longitude => _longitude;

  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Starts periodic location updates into the in-memory cache.
  Future<void> startTracking() async {
    final ok = await ensurePermission();
    if (!ok) return;

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    Geolocator.getPositionStream(locationSettings: settings).listen((position) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _lastUpdate = DateTime.now();
    });

    await refresh();
  }

  Future<void> stopTracking() async {
    // Stream is fire-and-forget; cache retains the last known position.
  }

  /// Fetches the current position once and updates the cache.
  Future<void> refresh() async {
    final ok = await ensurePermission();
    if (!ok) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      _lastUpdate = DateTime.now();
    } catch (_) {
      // Keep the last cached values when a one-shot read fails.
    }
  }

  static String deviceTimestamp() {
    final now = DateTime.now().toUtc();
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '${now.toIso8601String().split('.').first}.${ms}Z';
  }
}
