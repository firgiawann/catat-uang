import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/theme_colors.dart';
import '../services/notification_helper.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late String _randomMessageText;

  // ─── Pool 1: Jokes Receh ───────────────────────────────────────────────
  static const List<String> _pool1 = [
    "Kenapa dompet Kakak makin sehat?\nKarena rajin dicatat, bukan cuma dikuras! 😄",
    "Apa persamaan Kak Awan sama aplikasi ini?\nDua-duanya niat banget bantu Kakak hemat! ☁️💰",
    "Kenapa tabungan itu seperti mi instan?\nKalau dicicil sedikit, cepat matang juga! 🍜✨",
    "Fun fact: uang yang dicatat tidak kabur sendirian.\nYang kabur itu yang dibiarkan tidak dicatat! 👋💸",
  ];

  // ─── Pool 2: Pantun Singkat ────────────────────────────────────────────
  static const List<String> _pool2 = [
    "Buah mangga buah pepaya,\nRajin catat rezeki terjaga! 🍈",
    "Ada awan di langit biru,\nRajin mencatat itu keren lho! ☁️🌿",
    "Ke pasar beli tomat segar,\nAnggaran rapi hidup jadi tenang! 🍅",
    "Pagi hari minum teh hangat,\nCatat uang biar hati juga hangat! ☕",
  ];

  // ─── Pool 3: Gombalan Ringan ───────────────────────────────────────────
  static const List<String> _pool3 = [
    "Kalau Kakak adalah tabungan,\nAwan akan selalu isi secara konsisten! 😌☁️",
    "Semakin rajin mencatat,\nsemakin tenang tidur malamnya! 🌙💤",
    "Catet Uang suka sama Kakak yang disiplin.\nJangan berubah ya! 🥹",
    "Orang yang rajin catat keuangan itu...\nkeren banget, tahu! 🌸",
  ];

  // ─── Pool 4: Quotes Motivasi ───────────────────────────────────────────
  static const List<String> _pool4 = [
    "Sedikit demi sedikit, lama-lama jadi investasi.\nAyo disiplin, Kakak pasti bisa! ✨",
    "Orang kaya bukan yang banyak uangnya,\ntapi yang tahu ke mana uangnya pergi. 📊",
    "Kebebasan finansial dimulai dari\ncatatan rupiah kecil hari ini. 📝💪",
    "Disiplin hari ini,\nkebebasan di masa depan. Tetap semangat! 🎯",
  ];

  // ─── Pool 5: Apresiasi Hangat (khas ISFJ) ─────────────────────────────
  static const List<String> _pool5 = [
    "Terima kasih sudah setia mencatat!\nSetiap entri kecil adalah hadiah\nuntuk dirimu di masa depan. 💌",
    "Kamu sudah melakukan hal yang benar hari ini\nhanya dengan membuka aplikasi ini. Bangga! ☁️🌸",
    "Tidak semua orang mau repot mencatat,\ntapi Kakak mau. Itu bedanya! 🌟",
    "Aplikasi ini dibuat dengan sabar dan penuh perhatian,\nuntuk Kakak yang juga butuh ketenangan. ☁️💙",
  ];

  // ─── Pool 6: Sentuhan Personal — halus & alami ────────────────────────
  static const List<String> _pool6 = [
    "Kak Awan sengaja bikin tampilan ini senyaman mungkin.\nSemoga setiap buka app ini terasa\nseperti sambutan hangat! 🌸",
    "Semoga aplikasi kecil ini bisa bantu hidupmu\nterasa lebih teratur dan tenang ya, Kak. ☁️✨",
    "Kalau capek, boleh istirahat dulu.\nTapi keuangannya tetap dicatat ya sebelum lupa! 😄",
    "Nisa pernah bilang, rapi itu tenang.\nMakanya Catet Uang dibuat serapi mungkin. 🌿☁️",
    "Semoga siapapun yang pakai aplikasi ini\nselalu dikelilingi hal-hal baik\ndan keuangan yang sehat. 💌",
    "Ada yang selalu support di balik layar,\ndan Awan berharap itu terasa\nlewat setiap fiturnya. ☁️🫶",
  ];

  // Flat list — all 30 messages combined
  static List<String> get _allMessages =>
      [..._pool1, ..._pool2, ..._pool3, ..._pool4, ..._pool5, ..._pool6];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _randomMessageText = _allMessages[random.nextInt(_allMessages.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _startupScheduler();
  }

  Future<void> _startupScheduler() async {
    // Schedule and prompt permission
    await NotificationHelper.instance.scheduleReminders();

    // Hold 3.5s for immersive loading experience
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;
    widget.onFinish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final activeProfile = provider.activeProfile;
    final activeFlavor = activeProfile?.themeFlavor ?? "Strawberry";

    final isDark = Theme.of(context).brightness == Brightness.dark ||
        (activeProfile?.themeMode == "Gelap");
    final colors = getThemeColorFlavor(activeFlavor, isDark: isDark);

    return Scaffold(
      backgroundColor: colors.backgroundPolish,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/ic_launcher.webp',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.wallet_rounded,
                          color: colors.accent,
                          size: 64,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Catet Uang",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: colors.brandText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Catat keuangan, hemat selalu",
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _randomMessageText,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                "— Dibuat oleh Awan ☁️",
                style: TextStyle(
                  fontSize: 10,
                  color: colors.textSecondary.withOpacity(0.45),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
