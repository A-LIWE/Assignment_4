

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationRepository {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _tzInitialized = false;

  NotificationRepository(this._plugin);

  /// Måste köras innan du använder notiser
  Future<void> initializeTimeZone() async {
    if (kIsWeb || Platform.isLinux || Platform.isWindows) {
      // Hoppa över på plattformar där det inte stöds
      return;
    }

    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      _tzInitialized = true;
    } catch (e) {
      debugPrint('Kunde inte initiera tidszon: $e');
    }
  }

  /// Schemalägg en notis 15 minuter innan `endTime`.
  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime endTime,
  }) async {
    if (!_tzInitialized) {
      debugPrint('Tidszon ej initierad – hoppar över schemaläggning.');
      return;
    }

    final reminderTime = tz.TZDateTime.from(endTime, tz.local)
        .subtract(const Duration(minutes: 15));

    await _plugin.zonedSchedule(
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
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelReminder(String id) {
    return _plugin.cancel(id.hashCode);
  }

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