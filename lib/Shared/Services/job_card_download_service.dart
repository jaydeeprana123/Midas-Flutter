import 'package:flutter/services.dart';

class JobCardDownloadService {
  static const MethodChannel _channel = MethodChannel('com.garima.midas/job_card');

  Future<void> downloadJobCardReport({
    required String baseUrl,
    required String token,
    required String jobCardNumber,
  }) async {
    await _channel.invokeMethod<void>(
      'downloadJobCardReport',
      {
        'baseUrl': baseUrl,
        'token': token,
        'jobCardNumber': jobCardNumber,
      },
    );
  }
}
