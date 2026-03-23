// Web-specific notification implementation
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebNotificationHelper {
  static Future<void> init() async {
    try {
      final permission = html.Notification.permission;
      if (permission == 'default') {
        await html.Notification.requestPermission();
      }
      debugPrint('🌐 Web notification permission: ${html.Notification.permission}');
    } catch (e) {
      debugPrint('❌ Web notification error: $e');
    }
  }

  static void show({required String title, required String body}) {
    try {
      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
        debugPrint('🌐 Web notification shown: $title');
      } else {
        debugPrint('⚠️ Web notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Web notification error: $e');
    }
  }
}
