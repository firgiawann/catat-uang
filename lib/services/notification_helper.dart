import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationTemplate {
  final String title;
  final String body;

  const NotificationTemplate(this.title, this.body);
}

class NotificationHelper {
  static final NotificationHelper instance = NotificationHelper._init();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationHelper._init();

  // ── Sesi Siang (11:00–13:00) ───────────────────────────────────────────
  final List<NotificationTemplate> siangTemplates = const [
    NotificationTemplate("Udah jajan apa hari ini? 🍜", "Jangan lupa catat pengeluaran siang ini ya, Kak! Cuma 10 detik kok!"),
    NotificationTemplate("Anggaran siangmu aman? 📊", "Yuk cek sisa anggaranmu sekarang dan catat yang belum tercatat!"),
    NotificationTemplate("Halo dari Catet Uang! ☕", "Waktunya rekap pengeluaran pagi tadi. Biar makin rapi!"),
    NotificationTemplate("Jangan biarkan struk menghilang! 🧾", "Struk makan siangmu belum dicatat? Yuk, masukkan sekarang!"),
    NotificationTemplate("5 detik catat, 5 tahun manfaat 💰", "Satu catatan kecil hari ini bisa jadi keputusan besar besok!"),
    NotificationTemplate("Catet Uang kangen! 🥹", "Sudah lama tidak mencatat? Yuk mulai lagi dari sekarang!"),
    NotificationTemplate("Siang produktif, dompet aman! 🌤️", "Jangan biarkan pengeluaran siang ini lolos dari catatan ya!"),
  ];

  // ── Sesi Malam (19:00–21:00) ──────────────────────────────────────────
  final List<NotificationTemplate> malamTemplates = const [
    NotificationTemplate("Sebelum tidur, catat dulu! 🌙", "Biar besok pagi tenang, rekap pengeluaran hari ini dulu ya Kak!"),
    NotificationTemplate("Closing day: rekap hari ini! ✅", "Hari yang produktif butuh rekap yang rapi. Yuk catat!"),
    NotificationTemplate("Dompet bilang: dicatat dulu! 😄", "Tolong dicatat dulu sebelum istirahat ya. Cuma sebentar kok!"),
    NotificationTemplate("Hari ini produktif? 🌟", "Buktikan dengan catatan keuangan yang lengkap! Yuk buka Catet Uang!"),
    NotificationTemplate("Satu catatan malam ini 🌸", "Satu catatan sekarang, besok lebih tenang dan rapi. Yuk!"),
    NotificationTemplate("Pengingat malam yang hangat ☁️", "Awan di sini ingin mengingatkan: catat pengeluaranmu dulu yuk sebelum tidur!"),
    NotificationTemplate("Dompet sehat, tidur nyenyak 💤", "Rekap hari ini supaya besok tidak ada yang terlupakan!"),
  ];

  // Backward-compatible combined list
  List<NotificationTemplate> get templates => [...siangTemplates, ...malamTemplates];

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    // No-op for now; hook in navigation or analytics if needed.
  }

  Future<void> triggerInstantPreview() async {
    final random = Random();
    final template = templates[random.nextInt(templates.length)];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'catet_uang_reminder_channel',
      'Pengingat Catet Uang',
      channelDescription: 'Saluran notifikasi untuk mengingatkan pencatatan keuangan',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final id = random.nextInt(100000);

    await _notificationsPlugin.show(
      id: id,
      title: template.title,
      body: template.body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  /// Schedule in-app notifications: 1 siang + 1 malam each day the app is opened.
  Future<void> scheduleReminders() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final now = DateTime.now();
      final random = Random();

      // Sesi Siang: 11:00 – 13:00 (schedule if before 11 today)
      if (now.hour < 11) {
        final siangMinutes = 11 * 60 + random.nextInt(120); // 11:00–13:00
        final siangTime = DateTime(now.year, now.month, now.day,
            siangMinutes ~/ 60, siangMinutes % 60);
        final siangTemplate = siangTemplates[random.nextInt(siangTemplates.length)];
        await _scheduleOnce(1001, siangTemplate, siangTime);
      }

      // Sesi Malam: 19:00 – 21:00 (schedule if before 19 today)
      if (now.hour < 19) {
        final malamMinutes = 19 * 60 + random.nextInt(120); // 19:00–21:00
        final malamTime = DateTime(now.year, now.month, now.day,
            malamMinutes ~/ 60, malamMinutes % 60);
        final malamTemplate = malamTemplates[random.nextInt(malamTemplates.length)];
        await _scheduleOnce(1002, malamTemplate, malamTime);
      }
    } catch (e) {
      debugPrint('[NotificationHelper] scheduleReminders error: $e');
    }
  }

  Future<void> _scheduleOnce(int id, NotificationTemplate template, DateTime scheduledTime) async {
    try {
      final delay = scheduledTime.difference(DateTime.now());
      if (delay.isNegative) return;

      Future.delayed(delay, () async {
        final random = Random();
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'catet_uang_reminder_channel',
          'Pengingat Catet Uang',
          channelDescription: 'Saluran notifikasi untuk mengingatkan pencatatan keuangan',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );
        await _notificationsPlugin.show(
          id: id + random.nextInt(100),
          title: template.title,
          body: template.body,
          notificationDetails: const NotificationDetails(android: androidDetails),
        );
      });
    } catch (e) {
      debugPrint('[NotificationHelper] _scheduleOnce error: $e');
    }
  }
}

// ignore: implementation_imports
void debugPrint(String s) {
  // ignore: avoid_print
  print(s);
}
