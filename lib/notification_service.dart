import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

// Conditional import for web notifications
import 'notification_service_stub.dart'
    if (dart.library.html) 'notification_service_web.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const _kChannelId   = 'campus_channel';
const _kChannelName = 'Campus Alerts';
const _kChannelDesc = 'Reminders and alerts for Campus Assistant';

// ─────────────────────────────────────────────────────────────────────────────
// Background message handler (must be top-level function)
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background message: ${message.notification?.title}');
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService  –  singleton, web-safe
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // ── init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (kIsWeb) {
      await _initWeb();
      return;
    }

    // Mobile initialization
    tz.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Android 8+ notification channel
    const channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Android 13+ runtime permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Firebase Cloud Messaging setup
    await _initFCM();
  }

  // ── Web notification initialization ───────────────────────────────────────
  Future<void> _initWeb() async {
    await WebNotificationHelper.init();
  }

  // ── Firebase Cloud Messaging initialization ───────────────────────────────
  Future<void> _initFCM() async {
    try {
      // Request iOS permissions
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
      );

      // Get FCM token
      _fcmToken = await messaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
      });

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📨 Foreground message: ${message.notification?.title}');
        if (message.notification != null) {
          showNotification(
            id: message.hashCode,
            title: message.notification!.title ?? 'Campus Assistant',
            body: message.notification!.body ?? '',
          );
        }
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 Notification tapped: ${message.notification?.title}');
        // Handle navigation here if needed
      });

      // Check if app was opened from a terminated state notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 App opened from notification: ${initialMessage.notification?.title}');
      }
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
    }
  }

  // ── notification details ──────────────────────────────────────────────────
  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── public API ────────────────────────────────────────────────────────────

  /// Fire an instant local notification right now.
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      _showWebNotification(title: title, body: body);
      return;
    }
    await _plugin.show(id, title, body, _details);
  }

  /// Show web notification (browser)
  void _showWebNotification({required String title, required String body}) {
    WebNotificationHelper.show(title: title, body: body);
  }

  /// Schedule a local notification at [scheduledDate].
  /// Silently skips if [scheduledDate] is already in the past.
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all pending notifications.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// Cancel specific notification by ID
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  /// Schedule multiple notifications for an event:
  /// - 1 day before (at 9 AM)
  /// - 1 hour before
  /// - 15 minutes before
  Future<void> scheduleEventNotifications({
    required String eventId,
    required String title,
    required DateTime eventTime,
    String? location,
  }) async {
    if (kIsWeb) return;

    final now = DateTime.now();
    final baseId = eventId.hashCode;

    // 1 day before at 9 AM
    final oneDayBefore = DateTime(
      eventTime.year,
      eventTime.month,
      eventTime.day - 1,
      9,
      0,
    );
    if (oneDayBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 1,
        title: '📅 Tomorrow: $title',
        body: 'Starting at ${_formatTime(eventTime)}'
            '${location != null && location.isNotEmpty ? " @ $location" : ""}',
        scheduledDate: oneDayBefore,
      );
    }

    // 1 hour before
    final oneHourBefore = eventTime.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 2,
        title: '⏰ Starting in 1 hour: $title',
        body: 'At ${_formatTime(eventTime)}'
            '${location != null && location.isNotEmpty ? " @ $location" : ""}',
        scheduledDate: oneHourBefore,
      );
    }

    // 15 minutes before
    final fifteenMinsBefore = eventTime.subtract(const Duration(minutes: 15));
    if (fifteenMinsBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 3,
        title: '🔔 Starting in 15 minutes: $title',
        body: location != null && location.isNotEmpty ? 'Location: $location' : 'Starting soon!',
        scheduledDate: fifteenMinsBefore,
      );
    }
  }

  /// Helper to format time as "hh:mm AM/PM"
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
