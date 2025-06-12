

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationRepository {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationRepository(this._plugin);

  /// Schemalägg en notis 15 minuter innan `endTime`.
  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime endTime,
  }) {
    // Beräkna när notisen ska triggas (15 min före sluttid)
    final reminderTime = tz.TZDateTime.from(
      endTime,
      tz.local,
    ).subtract(const Duration(minutes: 15));

    return _plugin.zonedSchedule(
      // Använd hashCode eller annat unikt int som ID
      id.hashCode,
      title,
      body,
      reminderTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_chan_v2',
          'Parkering',
          channelDescription: 'Påminnelser för dina parkeringssessioner',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('carhorn'),
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Avbryt en schemalagd notis (använd samma `id`).
  Future<void> cancelReminder(String id) {
    return _plugin.cancel(id.hashCode);
  }

  /// Uppdatera en schemalagd påminnelse: avbryt + schemalägg på nytt.
  Future<void> rescheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime newEndTime,
  }) async {
    await cancelReminder(id);
    await scheduleReminder(
      id: id,
      title: title,
      body: body,
      endTime: newEndTime,
    );
  }
}
