import 'dart:convert';

GpsInsertResponse gpsInsertResponseFromJson(String str) =>
    GpsInsertResponse.fromJson(json.decode(str));

/// A single RFID + GPS reading collected during tracking.
/// Posted to `POST /api/GPS/InsertGPSData` as a JSON array.
class GpsDataModel {
  final String rfidNumber;
  final double latitude;
  final double longitude;
  final String timestamp;
  final bool isHandHeld;
  final double frequencyPoint;

  GpsDataModel({
    required this.rfidNumber,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isHandHeld = true,
    this.frequencyPoint = 0,
  });

  Map<String, dynamic> toJson() => {
        'rfidnumber': rfidNumber,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'isHandHeld': isHandHeld,
        'frequencyPoint': frequencyPoint,
      };

  /// Whether this reading can be drawn on the scan map.
  ///
  /// Missing or invalid means a coordinate is NaN or infinite, latitude is
  /// outside -90..90, longitude is outside -180..180, or both values are 0.
  /// (0, 0) is the location cache before the first GPS fix, so it is treated
  /// as no location yet. A latitude of 0 with a non-zero longitude is valid.
  bool get hasMappableLocation {
    if (latitude.isNaN ||
        longitude.isNaN ||
        latitude.isInfinite ||
        longitude.isInfinite) {
      return false;
    }
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return false;
    }
    if (latitude == 0 && longitude == 0) return false;
    return true;
  }

  GpsDataModel copyWith({
    double? latitude,
    double? longitude,
    String? timestamp,
    double? frequencyPoint,
  }) {
    return GpsDataModel(
      rfidNumber: rfidNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isHandHeld: isHandHeld,
      frequencyPoint: frequencyPoint ?? this.frequencyPoint,
    );
  }
}

/// Response envelope for `POST /api/GPS/InsertGPSData`.
class GpsInsertResponse {
  final bool isSuccess;
  final String message;

  GpsInsertResponse({
    required this.isSuccess,
    required this.message,
  });

  bool get succeeded => isSuccess;

  factory GpsInsertResponse.fromJson(Map<String, dynamic> json) =>
      GpsInsertResponse(
        isSuccess: json['isSuccess'] == true,
        message: (json['message'] ?? '').toString(),
      );
}
