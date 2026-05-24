import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../widgets/theme_colors.dart';
import '../services/notification_helper.dart';
import '../models/profile.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCatat;
  final VoidCallback onNavigateToRiwayat;
  final VoidCallback onManageProfileClick;
  final VoidCallback onAboutClick;
  final ThemeColorFlavor colors;

  const HomeScreen({
    Key? key,
    required this.onNavigateToCatat,
    required this.onNavigateToRiwayat,
    required this.onManageProfileClick,
    required this.onAboutClick,
    required this.colors,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Badge unlocked recently for popup animation
  String? _justUnlockedBadge;
  int _tourStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BudgetProvider>(context, listen: false);
      if (provider.currentTransactions.isEmpty) {
        setState(() {
          _tourStep = 1;
        });
      }
    });
  }

  String _formatRupiah(double value) {
    if (value == 0.0) return "Rp0";
    final isNegative = value < 0;
    final formatter = NumberFormat("#,###", "id_ID");
    final formatted = "Rp${formatter.format(value.abs()).replaceAll(',', '.')}";
    return isNegative ? "-$formatted" : formatted;
  }

  String _getTimeGreeting(String name) {
    final hour = DateTime.now().hour;
    final isNisa = name.toLowerCase().contains('nisa');
    final rng = Random();

    if (hour >= 5 && hour < 11) {
      // Pagi (05:00 - 10:59)
      final options = [
        "Selamat pagi, $name! ☀️ Semangat hari ini!",
        "Pagi, $name! 🌸 Awali hari dengan catatan keuangan yang rapi!",
        "Semangat pagi $name! ☕ Secangkir kopi dan rencana hemat hari ini!",
        "Pagi indah untuk $name! 🍃 Yuk konsisten catat belanjaan!",
        "Selamat pagi $name! 🌻 Hari baru, semangat baru, tabungan baru!",
        "Pagi Kak $name! 🍳 Sudah sarapan? Catat dulu pengeluaran sarapanmu ya!",
        "Pagi $name! ☁️ Awan siap memandu harimu dengan grafik keuangan yang rapi! 📈",
        "Pagi $name! 🧸 Awan ingetin: Menghemat hari ini adalah investasi kecil untuk ketenangan hari esok! 🌈",
        if (isNisa) ...[
          "Selamat pagi Nisa! ☀️ Awan bangga banget kamu udah bangun sepagi ini! Semangat buat hari produktifmu ya, Awan selalu support dari belakang! 🌸✨",
          "Pagi Nisa! ☀️ Secangkir teh hangat dan embun pagi yang segar siap menemani awal langkah rapimu hari ini! 🌸☕",
          "Pagi Nisa! ☀️ Awan nemu koin Rp500 di saku celana tadi, lumayan buat nambah celengan! Semangat ya hari ini! 😂🌸",
          "Selamat pagi Nurun Nisa! ☀️ Bangun pagi dengan senyuman dan dompet yang rapi adalah kunci kebahagiaan hari ini! Semangat! 🌿💖",
        ] else ...[
          "Pagi $name! ☀️ Ssst... Ada koin keberuntungan di saku celanamu hari ini! 😂🍀",
          "Pagi $name! ☁️ Awan-awan berarak membawa kabar bahwa dompetmu aman hari ini! 🍃",
        ]
      ];
      return options[rng.nextInt(options.length)];
    } else if (hour >= 11 && hour < 15) {
      // Siang (11:00 - 14:59)
      final options = [
        "Halo $name! 🌤️ Jangan lupa makan siang ya!",
        "Siang, $name! 🍉 Tetap teratur catat pengeluaran makan siangmu!",
        "Halo $name! 🍹 Istirahat siang yang nyaman dan tetap hemat!",
        "Siang Kak $name! 🍛 Sudah isi energi? Dompetnya dijaga juga ya!",
        "Halo $name! 🌤️ Ingat batas anggaran belanja siang ini!",
        "Siang, $name! 🌸 Cuaca cerah, catatan keuangan juga harus cerah!",
        "Siang $name! ☁️ Awan di langit menyerupai mangkok mie ayam... Lapar ya? Catat ya! 🍜",
        "Siang $name! 🌸 Pesan Awan: Jangan lupa ambil napas dalam-dalam, istirahat sejenak, dan tersenyum! ✨",
        if (isNisa) ...[
          "Halo Nisa! 🌤️ Awan di sini mau ingetin: makan siang tepat waktu ya, kurangi jajan hari ini! 🍹🌸",
          "Halo Nisa! 🌤️ Siang yang cerah! Jangan lupa makan siang tepat waktu dan kurangi jajan ya! 🍹🌸",
          "Siang Nisa! 🌸 Awan ingetin: Istirahat yang cukup di sela-sela aktivitasmu, dan jangan telat makan! 🍱✨",
        ] else ...[
          "Halo $name! 🌤️ Kak Awan ingetin makan siang tepat waktu ya, kurangi jajan manis! 🍹🍀",
        ]
      ];
      return options[rng.nextInt(options.length)];
    } else if (hour >= 15 && hour < 19) {
      // Sore (15:00 - 18:59)
      final options = [
        "Sore, $name! 🌇 Hari yang produktif?",
        "Sore Kak $name! 🍂 Waktunya rekap tipis-tipis pengeluaran hari ini!",
        "Sore, $name! ☕ Secangkir teh hangat untuk nemenin catat uang!",
        "Sore indah, $name! 🌾 Gimana sisa anggaran belanjamu hari ini?",
        "Sore, $name! 🌇 Senja yang hangat untuk jiwa yang hemat!",
        "Halo $name! 🍃 Angin sore berembus membawa ketenangan bagi dompetmu!",
        "Sore $name! ☁️ Warna langit sore ini jingga cantik banget, secantik grafik tabunganmu! 📈",
        "Sore $name! 🍀 Tips dari Awan: Hemat itu bukan pelit, tapi cara menghargai masa depanmu! 😉",
        if (isNisa) ...[
          "Sore Nisa! 🌇 Awan baru selesai merapikan pembukuan nih, yuk catat belanjaan sore ini biar dompet tetap rapi! ☁️🌸",
          "Sore Nisa! 🌇 Langit senja berhias awan lembut sore ini, saat yang pas untuk merekap catatan belanjamu! ☁️🌸",
          "Sore Kak Nisa! 🌇 Awan ingetin buat catat ongkos pulang atau jajan sore tadi sebelum lupa ya! 🌸🍃",
        ] else ...[
          "Sore $name! 🌇 Kak Awan baru kelar merapikan pembukuan nih, yuk rekap sore ini! ☁️🍀",
        ]
      ];
      return options[rng.nextInt(options.length)];
    } else if (hour >= 19 && hour < 23) {
      // Malam (19:00 - 22:59)
      final options = [
        "Hai $name! 🌙 Udah catat pengeluaran hari ini?",
        "Malam, $name! 🍵 Waktu terbaik untuk merapikan pembukuan harian!",
        "Hai Kak $name! ⭐ Hari yang luar biasa! Mari tutup dengan catatan yang rapi!",
        "Malam Kak $name! 🛌 Sebelum tidur, yuk cek apakah semua pengeluaran tercatat!",
        "Malam, $name! 🌌 Dompet aman, pikiran tenang, tidur pun nyenyak!",
        "Hai $name! 🍃 Santai sejenak dan rekap pengeluaran malam ini!",
        "Malam $name! ☁️ Awan malam bertabur bintang menemani pembukuanmu yang rapi!",
        "Malam $name! ✨ Pesan hangat Awan: Tidur yang nyenyak dimulai dari keuangan yang rapi dan hati yang tenang! 🤫🛌",
        if (isNisa) ...[
          "Malam Nisa! 🌙 Awan ingetin buat catat struk belanjaan hari ini sebelum tidur ya, biar tidurmu nyenyak! 💤🌸",
          "Malam Nisa! 🌙 Angin malam berhembus lembut membawa ketenangan, yuk rekap belanjaanmu sebelum beristirahat! ☁️🌸",
          "Malam Nisa! 🌙 Hayo, ada jajan online yang belum dicatat sore tadi? Awan siap nemenin rekap kok! 😂🌸",
          "Malam Nisa! 🌙 Jangan kebanyakan scroll TikTok malam-malam ya, dicatat dulu belanjanya terus tidur! 😂🌸",
        ] else ...[
          "Malam $name! 🌙 Kak Awan nemu struk belanjaan keselip, buruan dicatat sebelum lupa! 😂🍀",
        ]
      ];
      return options[rng.nextInt(options.length)];
    } else if (hour >= 23 || hour < 3) {
      // Tengah Malam / Awal Dini Hari (23:00 - 02:59)
      final options = [
        "$name masih up? 🦉 Jaga kesehatan juga ya!",
        "Malam larut, $name! ⭐ Jangan lupa istirahat yang cukup!",
        "Hai $name! 🌌 Sunyinya malam paling pas buat merenungi tabungan harian!",
        "Malam Kak $name! 🦉 Masih sibuk? Luangkan 5 detik untuk catat pengeluaran terakhir!",
        "$name belum tidur? 🛌 Anggaranmu aman kok, yuk tidur!",
        "Midnight $name! ☁️ Bintang-bintang berbisik agar Kakak lekas tidur nyenyak! 🛌",
        "Malam larut $name! 🌸 Awan ingetin: Begadang boleh saja, asal jangan begadang sambil checkout belanjaan online ya! 💸😂",
        if (isNisa) ...[
          "Tengah malam Nisa! 🦉 Awan pantau jam segini masih up... Simpan HP-nya dulu yuk, jangan keasyikan scroll TikTok terus! 😂🌸",
          "Tengah malam Nisa! 🦉 Tumben belum tidur? Malam sudah larut banget lho, yuk tidur nyenyak biar besok pagi segar! 💤🌸",
          "Malam larut Nisa! 🌸 Tumben belum tidur? Lagi mikirin anggaran belanja atau asyik scroll TikTok nih? 😂 Awan ingetin istirahat ya! ☁️🌸",
          "Dini hari Nisa! 🌸 Awan selalu siap nemenin rekap kapan pun kamu butuh bantuan mencatat. Sleep tight! ☁️✨",
        ] else ...[
          "Tengah malam $name! 🦉 Kak Awan masih pantau nih, jangan scroll e-commerce terus ya! 😂🍀",
        ]
      ];
      return options[rng.nextInt(options.length)];
    } else {
      // Dini Hari Akhir (03:00 - 04:59)
      final options = [
        "Dini hari sunyi, $name! 🌌 Semangat buat yang terbangun lebih awal!",
        "Subuh hampir tiba, $name! ❄️ Udara dini hari sangat menenangkan!",
        "Dini hari produktif, $name! ✨ Rencana besar dimulai dari jam sesunyi ini!",
        "Hai $name! 🛌 Masih terjaga atau baru bangun? Sukses selalu!",
        "Dini hari $name! ☁️ Dinginnya malam akan segera berganti fajar pembuka rezeki!",
        "Dini hari Kak $name! ⭐ Awan ingetin: Ambil napas dalam-dalam dan istirahatlah yang cukup ya! ☕",
        if (isNisa) ...[
          "Dini hari Nisa! 🌸 Tumben belum tidur di jam sunyi ini? Awan selalu siap siaga nemenin pembukuanmu kapan pun kok! ☁️✨",
          "Dini hari Nisa! 🌸 Keheningan malam membawa kedamaian, mari tidur cukup agar esok hari terasa segar dan berenergi! ☁️✨",
        ] else ...[
          "Dini hari $name! 🍀 Kak Awan selalu siap nemenin rekap kapanpun Kakak butuh bantuan! ☁️✨",
        ]
      ];
      return options[rng.nextInt(options.length)];
    }
  }

  void _showBadgeUnlocked(BuildContext context, String emoji, String title) {
    final isPencetus = title == "Pencetus Ide";
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: widget.colors.bottomNavBg,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(isPencetus ? "Penghargaan Kehormatan Emas 👑" : "Badge Baru! 🎉",
                style: TextStyle(fontSize: 13, color: widget.colors.textSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.colors.brandText)),
            const SizedBox(height: 8),
            Text(
                isPencetus
                    ? "Terinspirasi dari ide awal dan dorongan luar biasa darimu untuk menciptakan aplikasi pembukuan yang manis, praktis, dan menenangkan. Terima kasih telah memicu terwujudnya Catet Uang! 🌸☁️✨"
                    : "Kamu berhasil membuka badge baru!\nTerus semangat mencatat! 🌸",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: widget.colors.textSecondary, height: 1.5)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Sip!", style: TextStyle(color: widget.colors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final activeProfile = provider.activeProfile;
    final transactions = provider.currentTransactions;
    final budget = provider.currentBudget;

    final double targetAmount = budget?.targetAmount ?? 0.0;
    final double totalMasuk = provider.totalPemasukan;
    final double totalKeluar = provider.totalTerpakai;
    final double saldoSisa = provider.saldo;

    final double sisaAnggaran = targetAmount - totalKeluar;
    final double sisaPercent = targetAmount > 0.0
        ? ((sisaAnggaran / targetAmount) * 100).clamp(0.0, 100.0)
        : 0.0;

    final double progressValue = targetAmount > 0.0
        ? (totalKeluar / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    final recentTransactions = transactions.take(3).toList();

    // ── Pemula Hemat ─────────────────────────────────────────
    final bool firstEntry = transactions.isNotEmpty;
    final bool morningCompleted = transactions.any((tx) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      return date.hour < 11;
    });
    final bool balancedCompleted =
        transactions.any((tx) => !tx.isExpense) && transactions.any((tx) => tx.isExpense);
    final bool budgetCompleted = targetAmount > 0.0;

    // ── Pejuang Hemat ─────────────────────────────────────────
    final bool fiveEntries = transactions.length >= 5;
    final bool fifteenEntries = transactions.length >= 15;
    final bool masterCompleted = targetAmount > 0.0 && sisaPercent >= 30.0;
    final bool saldoPositif = totalMasuk > totalKeluar && totalMasuk > 0;

    // ── Misi Misterius Easter Eggs ────────────────────────────
    final bool midnightEntry = transactions.any((tx) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      return date.hour >= 0 && date.hour < 1;
    });
    final bool subuhEntry = transactions.any((tx) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      return date.hour < 6;
    });
    final bool hematEkstrem = targetAmount > 0.0 && sisaPercent >= 80.0;
    final bool bosKeuangan = totalMasuk >= 10000000;

    // ── Komitmen Hemat (Days Active) ──────────────────────────
    final uniqueDays = transactions.map((tx) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      return "${date.year}-${date.month}-${date.day}";
    }).toSet().length;

    final bool active2Days = uniqueDays >= 2;
    final bool active5Days = uniqueDays >= 5;
    final bool active7Days = uniqueDays >= 7;
    final bool active30Days = uniqueDays >= 30;

    final isNisa = (activeProfile?.name ?? '').toLowerCase().contains('nisa');
    final int totalBadges = isNisa ? 17 : 16;
    final int completedMissions = [
      firstEntry, morningCompleted, balancedCompleted, budgetCompleted,
      fiveEntries, fifteenEntries, masterCompleted, saldoPositif,
      midnightEntry, subuhEntry, hematEkstrem, bosKeuangan,
      active2Days, active5Days, active7Days, active30Days,
      if (isNisa) true,
    ].where((m) => m).length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          _buildHeaderRow(activeProfile),
          const SizedBox(height: 12),

          // Mini Profile Banner
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.colors.headerBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${activeProfile?.emoji ?? '🐱'} ${activeProfile?.name ?? 'Sobat Hemat'}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: widget.colors.brandText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.colors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      activeProfile?.themeFlavor ?? "Strawberry",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: widget.colors.accent,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic Greeting Header right above Ringkasan Keuangan
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 4.0),
            child: Text(
              _getTimeGreeting(activeProfile?.name ?? 'Sobat Hemat'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: widget.colors.brandText,
              ),
            ),
          ),

          // Ringkasan Keuangan Card
          _buildFinancialCard(
            saldoSisa,
            targetAmount,
            totalKeluar,
            progressValue,
            sisaPercent,
            sisaAnggaran,
            totalMasuk,
            provider.selectedMonth,
          ),
          const SizedBox(height: 16),

          // Riwayat Terakhir Card
          _buildRecentTransactionsCard(recentTransactions),
          const SizedBox(height: 16),

          // Misi & Badge Card
          _buildMissionsCard(context, completedMissions, totalBadges,
            firstEntry, morningCompleted, balancedCompleted, budgetCompleted,
            fiveEntries, fifteenEntries, masterCompleted, saldoPositif,
            midnightEntry, subuhEntry, hematEkstrem, bosKeuangan,
            active2Days, active5Days, active7Days, active30Days),
          const SizedBox(height: 16),

          // Notification simulator Card
          _buildNotificationSimulatorCard(context),
          const SizedBox(height: 16),

          // Gentle Encouragement Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              "Mari rapi-rapi kelola pengeluaran harianmu dengan bijak, hemat selalu ya! 🌸",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: widget.colors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
          ),
        ),
        if (_tourStep > 0) _buildTourOverlay(),
      ],
    );
  }

  Widget _buildHeaderRow(Profile? activeProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onManageProfileClick,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.colors.headerBg,
                  child: Text(
                    activeProfile?.emoji ?? "🐱",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, Kak! 👋",
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Catet Uang",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: widget.colors.brandText,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: widget.onManageProfileClick,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.colors.bottomNavBg,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.favorite_rounded, color: widget.colors.accent, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onAboutClick,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.colors.bottomNavBg,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.info_rounded, color: widget.colors.brandText, size: 20),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildFinancialCard(
      double saldoSisa,
      double targetAmount,
      double totalKeluar,
      double progressValue,
      double sisaPercent,
      double sisaAnggaran,
      double totalMasuk,
      String selectedMonth) {
    Color progressColor = amountGreen;
    if (progressValue > 0.9) {
      progressColor = amountRed;
    } else if (progressValue > 0.7) {
      progressColor = const Color(0xFFFF9800);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.colors.bottomNavBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: widget.colors.accent, size: 16),
              const SizedBox(width: 6),
              Text(
                "Ringkasan Keuangan • $selectedMonth",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.textSecondary,
                ),
              )
            ],
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Saldo Sisa",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatRupiah(saldoSisa),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: saldoSisa >= 0.0 ? amountGreen : amountRed,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Target Anggaran",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    targetAmount > 0.0 ? _formatRupiah(targetAmount) : "Belum diatur",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: widget.colors.brandText,
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 18),

          if (targetAmount > 0.0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sisa Anggaran Belanja",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.colors.textSecondary,
                  ),
                ),
                Text(
                  "${sisaPercent.toInt()}% sisa (${_formatRupiah(sisaAnggaran)})",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                )
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: widget.colors.progressTrack,
                child: FractionallySizedBox(
                  widthFactor: progressValue,
                  alignment: Alignment.centerLeft,
                  child: Container(color: progressColor),
                ),
              ),
            )
          ] else ...[
            GestureDetector(
              onTap: widget.onNavigateToCatat,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.colors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: widget.colors.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Atur Target Anggaran Bulan Ini di Menu Catat!",
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],

          const SizedBox(height: 12),
          Divider(color: widget.colors.border.withOpacity(0.3)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: amountGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Total Masuk (+)",
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.colors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(totalMasuk),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: amountGreen,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: widget.colors.border.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: amountRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Total Keluar (-)",
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.colors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(totalKeluar),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: amountRed,
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsCard(List<Transaction> recents) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.colors.bottomNavBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Riwayat Terakhir",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: widget.colors.brandText,
                ),
              ),
              GestureDetector(
                onTap: widget.onNavigateToRiwayat,
                child: Row(
                  children: [
                    Text(
                      "Lihat Selengkapnya",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.colors.accent,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right_rounded, color: widget.colors.accent, size: 16),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          if (recents.isEmpty) ...[
            Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                "Belum ada transaksi di bulan ini ✨",
                style: TextStyle(
                  fontSize: 11,
                  color: widget.colors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tx = recents[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.colors.backgroundPolish.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: (tx.isExpense ? amountRed : amountGreen).withOpacity(0.15),
                        child: Text(
                          tx.isExpense ? "💸" : "💰",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tx.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.colors.brandText,
                          ),
                        ),
                      ),
                      Text(
                        "${tx.isExpense ? '-' : '+'}${_formatRupiah(tx.amount)}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: tx.isExpense ? amountRed : amountGreen,
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ]
        ],
      ),
    );
  }

  Widget _buildMissionsCard(
    BuildContext context,
    int completed, int total,
    bool firstEntry, bool morningDone, bool balancedDone, bool budgetDone,
    bool fiveEntries, bool fifteenEntries, bool masterDone, bool saldoPositif,
    bool midnightDone, bool subuhDone, bool hematEkstrem, bool bosKeuangan,
    bool active2Days, bool active5Days, bool active7Days, bool active30Days,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.colors.bottomNavBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text("🏆", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text("Misi & Badge Hemat",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: widget.colors.brandText)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.colors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$completed/$total",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.colors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category 1: Pemula Hemat
          _buildCategoryLabel("🌱 Pemula Hemat"),
          const SizedBox(height: 8),
          Row(children: [
            _buildBadgeItem(context, "🪙", "Langkah Pertama", "Catat transaksimu", firstEntry, false),
            _buildBadgeItem(context, "🌅", "Disiplin Pagi", "Catat < jam 11", morningDone, false),
            _buildBadgeItem(context, "⚖️", "Seimbang", "Masuk & Keluar", balancedDone, false),
            _buildBadgeItem(context, "🎯", "Set Target", "Atur anggaran", budgetDone, false),
          ]),
          const SizedBox(height: 14),

          // Category 2: Pejuang Hemat
          _buildCategoryLabel("🔥 Pejuang Hemat"),
          const SizedBox(height: 8),
          Row(children: [
            _buildBadgeItem(context, "🥇", "Rajin Mencatat", "Catat 5x", fiveEntries, false),
            _buildBadgeItem(context, "👑", "Juara Hemat", "Sisa ≥30%", masterDone, false),
            _buildBadgeItem(context, "🎓", "Ahli Keuangan", "Catat 15x", fifteenEntries, false),
            _buildBadgeItem(context, "💚", "Saldo Positif", "Masuk>Keluar", saldoPositif, false),
          ]),
          const SizedBox(height: 14),

          // Category 3: Komitmen Hemat
          _buildCategoryLabel("📅 Komitmen Hemat"),
          const SizedBox(height: 8),
          Row(children: [
            _buildBadgeItem(context, "🪵", "2 Hari Aktif", "Gunakan 2 hari", active2Days, false),
            _buildBadgeItem(context, "📅", "5 Hari Aktif", "Gunakan 5 hari", active5Days, false),
            _buildBadgeItem(context, "🗓️", "7 Hari Aktif", "Gunakan 7 hari", active7Days, false),
            _buildBadgeItem(context, "🏆", "30 Hari Aktif", "Gunakan 30 hari", active30Days, false),
          ]),
          const SizedBox(height: 14),

          // Category 4: Misi Misterius
          _buildCategoryLabel("🌟 Misi Misterius"),
          const SizedBox(height: 8),
          Row(children: [
            _buildBadgeItem(context, "🦅", "???", "???", midnightDone, true),
            _buildBadgeItem(context, "🌄", "???", "???", subuhDone, true),
            _buildBadgeItem(context, "💎", "???", "???", hematEkstrem, true),
            _buildBadgeItem(context, "🏦", "???", "???", bosKeuangan, true),
          ]),
          if (Provider.of<BudgetProvider>(context, listen: false).activeProfile?.name.toLowerCase().contains('nisa') ?? false) ...[
            const SizedBox(height: 14),
            _buildCategoryLabel("👑 Penghargaan Kehormatan"),
            const SizedBox(height: 8),
            Row(children: [
              _buildBadgeItem(context, "👑", "Pencetus Ide", "Inspirator App", true, false),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryLabel(String label) {
    return Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: widget.colors.textSecondary));
  }

  Widget _buildBadgeItem(BuildContext context, String emoji, String title, String desc, bool isUnlocked, bool isMystery) {
    final displayTitle = (isMystery && !isUnlocked) ? "???" : title;
    final displayDesc = (isMystery && !isUnlocked) ? "Rahasia" : desc;
    final displayEmoji = (isMystery && !isUnlocked) ? "🔒" : emoji;

    return Expanded(
      child: GestureDetector(
        onTap: isUnlocked ? () => _showBadgeUnlocked(context, emoji, title) : null,
        child: AnimatedOpacity(
          opacity: isUnlocked ? 1.0 : 0.38,
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUnlocked ? widget.colors.headerBg : widget.colors.backgroundPolish,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? widget.colors.accent : widget.colors.border.withOpacity(0.3),
                    width: isUnlocked ? 2.0 : 1.0,
                  ),
                  boxShadow: isUnlocked ? [
                    BoxShadow(color: widget.colors.accent.withOpacity(0.25), blurRadius: 8, spreadRadius: 1),
                  ] : null,
                ),
                alignment: Alignment.center,
                child: Text(displayEmoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 5),
              Text(displayTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: widget.colors.brandText)),
              Text(displayDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600, color: widget.colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSimulatorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.colors.bottomNavBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text("🔔", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                "Akurasi Pengingat Harian",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: widget.colors.brandText,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Pengingat otomatis dijadwalkan secara acak di waktu istirahat (2x sehari: Siang & Malam) untuk menjaga kedisiplinan mencatat Kakak.",
            style: TextStyle(
              fontSize: 11,
              color: widget.colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.colors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            onPressed: () async {
              await NotificationHelper.instance.triggerInstantPreview();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Simulasi pengingat terkirim! 📲 Cek bilah notifikasi HP Kakak.")),
              );
            },
            child: const Text(
              "Simulasikan & Kirim Notifikasi 📲",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTourOverlay() {
    String title = "";
    String content = "";
    Alignment alignment = Alignment.center;
    IconData icon = Icons.cloud_rounded;

    if (_tourStep == 1) {
      title = "Halo! Kenalin, Aku Awan! ☁️✨";
      content = "Aku adalah tour guide pribadimu di Catet Uang!\n\nAku siap nemenin, ngingetin, dan bantu pantau pembukuanmu setiap hari biar rapi dan fikiranmu tetap tenang. Yuk, kita keliling sebentar melihat fitur-fitur di aplikasi ini! 🌸";
      alignment = Alignment.center;
      icon = Icons.cloud_rounded;
    } else if (_tourStep == 2) {
      title = "📊 Ringkasan Keuangan";
      content = "Di bagian atas ini adalah tempat memantau Anggaran Bulanan, Saldo, dan Grafik Keuanganmu secara real-time!\n\nSemua perubahan transaksimu akan terpantau otomatis oleh Awan di sini. ☁️📈";
      alignment = Alignment.topCenter;
      icon = Icons.donut_large_rounded;
    } else if (_tourStep == 3) {
      title = "🏆 Misi & Komitmen Hemat";
      content = "Geser ke bawah untuk melihat 16+ misi seru!\n\nMisi ini dirancang khusus untuk menantang tingkat kedisiplinanmu. Selesaikan tantangannya untuk membuka piala/badge cantik! 🎖️🍀";
      alignment = Alignment.center;
      icon = Icons.emoji_events_rounded;
    } else if (_tourStep == 4) {
      title = "✍️ Catat Transaksi Baru";
      content = "Siap mencoba?\n\nTekan tombol pensil di tengah navigasi bawah untuk langsung mencatat pengeluaran atau pemasukan secara kilat hanya dalam 5 detik! 🚀";
      alignment = Alignment.bottomCenter;
      icon = Icons.edit_rounded;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _tourStep = (_tourStep + 1) % 5;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        width: double.infinity,
        height: double.infinity,
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.colors.bottomNavBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: widget.colors.accent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.accent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: widget.colors.accent, size: 28),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: widget.colors.brandText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.colors.textSecondary,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tourStep == 4 ? "Mulai Catat Sekarang! 🎉" : "Ketuk untuk Lanjut 🐾",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.colors.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: widget.colors.accent, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
