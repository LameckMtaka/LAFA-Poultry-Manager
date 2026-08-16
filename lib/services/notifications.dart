import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Dar_es_Salaam'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await plugin.initialize(const InitializationSettings(android: android, iOS: darwin));
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  NotificationDetails get details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'poultry_alarms',
          'Poultry Alarms',
          channelDescription: 'Incubation na vaccination reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

  int _id(String seed, int suffix) => (seed.hashCode.abs() % 1000000) * 100 + suffix;

  Future<void> _schedule(int id, String title, String body, DateTime date) async {
    final now = DateTime.now();
    var when = DateTime(date.year, date.month, date.day, 7, 0);
    if (when.isBefore(now)) return;
    await plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleIncubation(PoultryBatch b) async {
    await _schedule(_id(b.id, 8), 'Candling leo — ${b.name}', 'Siku ya 8: chunguza kiini cha yai na tenga fertile, infertile na suspect.', b.setDate.add(const Duration(days: 8)));
    await _schedule(_id(b.id, 18), 'Shusha mayai leo — ${b.name}', 'Siku ya 18: hamishia mayai kwenye hatching tray / lockdown.', b.setDate.add(const Duration(days: 18)));
    await _schedule(_id(b.id, 21), 'Hatch day — ${b.name}', 'Siku ya 21: leo ndiyo siku kuu ya kutotolesha.', b.setDate.add(const Duration(days: 21)));
    await _schedule(_id(b.id, 22), 'Toa vifaranga — ${b.name}', 'Siku ya 22: kagua hatch na toa vifaranga salama.', b.setDate.add(const Duration(days: 22)));
  }

  Future<void> scheduleVaccines(ChickBatch c) async {
    final schedule = vaccineSchedule(c);
    for (var i = 0; i < schedule.length; i++) {
      final v = schedule[i];
      await _schedule(_id(c.id, 30 + i), 'Chanjo: ${v.title}', '${c.name}: ${v.dayLabel}. Leo ni siku ya chanjo iliyopangwa.', v.date);
    }
  }

  Future<void> cancelBatch(String batchId) async {
    for (final suffix in [8, 18, 21, 22]) {
      await plugin.cancel(_id(batchId, suffix));
    }
  }

  Future<void> showTest() async {
    await plugin.show(99999999, 'LAFA Poultry Manager', 'Alarm na notification zinafanya kazi.', details);
  }
}
