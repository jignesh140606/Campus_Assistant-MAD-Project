// Stub for mobile platforms (no web notification support)
import 'package:flutter/foundation.dart';

class WebNotificationHelper {
  static Future<void> init() async {
    debugPrint('🌐 Web notifications not supported on mobile');
  }

  static void show({required String title, required String body}) {
    debugPrint('🌐 Web notifications not supported on mobile');
  }
}
