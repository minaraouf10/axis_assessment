import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode;

class Logging {
  static void log(String message, {String tag = 'MyApp-Log'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
      );
    }
  }

  static void error(String message, {String tag = 'MyApp-Error'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
        level: 1000, // Higher level for errors
      );
    }
  }

  static void warn(String message, {String tag = 'MyApp-Warning'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
        level: 900, // Warning level
      );
    }
  }

  static void info(String message, {String tag = 'MyApp-Info'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
        level: 800, // Info level
      );
    }
  }
}
