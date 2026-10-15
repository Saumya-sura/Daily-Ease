import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kReleaseMode ? Level.warning : Level.trace,
  );

  /// Sanitize data map to redact any passwords, tokens, full phone numbers, or credit/id numbers
  static Map<String, dynamic> _sanitize(Map<String, dynamic>? data) {
    if (data == null) return {};
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = {
      'password',
      'token',
      'access_token',
      'refresh_token',
      'secret',
      'service_role',
      'phone_number',
      'phone',
      'aadhaar',
      'pan',
    };

    for (final key in sanitized.keys.toList()) {
      final lowerKey = key.toLowerCase();
      if (sensitiveKeys.any((s) => lowerKey.contains(s))) {
        sanitized[key] = '[REDACTED]';
      } else if (sanitized[key] is Map<String, dynamic>) {
        sanitized[key] = _sanitize(sanitized[key] as Map<String, dynamic>);
      }
    }
    return sanitized;
  }

  static void trace(String module, String event, [Map<String, dynamic>? context]) {
    final cleanContext = _sanitize(context);
    _logger.t('[$module] $event ${cleanContext.isNotEmpty ? cleanContext : ""}');
  }

  static void debug(String module, String event, [Map<String, dynamic>? context]) {
    final cleanContext = _sanitize(context);
    _logger.d('[$module] $event ${cleanContext.isNotEmpty ? cleanContext : ""}');
  }

  static void info(String module, String event, [Map<String, dynamic>? context]) {
    final cleanContext = _sanitize(context);
    _logger.i('[$module] $event ${cleanContext.isNotEmpty ? cleanContext : ""}');
  }

  static void warning(String module, String event, [Map<String, dynamic>? context]) {
    final cleanContext = _sanitize(context);
    _logger.w('[$module] $event ${cleanContext.isNotEmpty ? cleanContext : ""}');
  }

  static void error(
    String module,
    String event, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final cleanContext = _sanitize(context);
    _logger.e(
      '[$module] $event ${cleanContext.isNotEmpty ? cleanContext : ""}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void fatal(
    String module,
    String event, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final cleanContext = _sanitize(context);
    _logger.f(
      '[$module] CRITICAL: $event ${cleanContext.isNotEmpty ? cleanContext : ""}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
