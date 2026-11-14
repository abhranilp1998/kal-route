import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// On web this is a no-op; the app shows an in-app banner instead.
  static Future<void> init(void Function(String?) onTap, {bool requestPermission = true}) async {
    if (kIsWeb || _ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (r) => onTap(r.payload),
    );
    if (requestPermission) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    _ready = true;
  }

  static Future<void> show({required String title, required String body, String? payload}) async {
    if (kIsWeb) return;
    if (!_ready) await init((_) {}, requestPermission: false);
    await _plugin.show(
      id: 2100,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nightly_plan',
          "Tomorrow's plan",
          channelDescription: 'One card every night with tomorrow\'s trips',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}
