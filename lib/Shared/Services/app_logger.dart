import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const String _defaultTag = 'Midas';

  /// Set to `false` to disable all app logs (enabled in debug by default).
  static bool enabled = kDebugMode;

  static void log(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) return;
    developer.log(
      message,
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String tag = _defaultTag}) {
    log(message, tag: tag);
  }

  static void info(String message, {String tag = _defaultTag}) {
    log(message, tag: tag);
  }

  static void warning(String message, {String tag = _defaultTag}) {
    log(message, tag: tag);
  }

  static void error(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs an outgoing API request.
  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('──────── API Request ────────')
      ..writeln('Method: $method')
      ..writeln('URL: $url');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('Query: ${_format(queryParameters)}');
    }
    if (body != null) {
      buffer.writeln('Body: ${_format(body)}');
    }
    buffer.writeln('──────────────────────────────');

    log(buffer.toString(), tag: 'API');
  }

  /// Logs an API response or error payload.
  static void apiResponse({
    required String method,
    required String url,
    int? statusCode,
    dynamic response,
    String? errorMessage,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('──────── API Response ────────')
      ..writeln('Method: $method')
      ..writeln('URL: $url');

    if (statusCode != null) {
      buffer.writeln('Status: $statusCode');
    }
    if (errorMessage != null && errorMessage.isNotEmpty) {
      buffer.writeln('Error: $errorMessage');
    }
    if (response != null) {
      buffer.writeln('Response: ${_format(response)}');
    } else {
      buffer.writeln('Response: null');
    }
    buffer.writeln('───────────────────────────────');

    log(buffer.toString(), tag: 'API');
  }

  static String _format(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
