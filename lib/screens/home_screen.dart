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
        // Easter Eggs:
        isNisa 
            ? "Pagi Nisa! ☀️ Ssst... Kak Awan nemu koin Rp500 di saku celana tadi! 😂🌸" 
            : "Pagi $name! ☀️ Ssst... Ada koin keberuntungan di saku celanamu hari ini! 😂🍀",
        "Pagi $name! ☁️ Awan-awan berarak membawa kabar bahwa dompetmu aman hari ini! 🍃",
        "Pagi $name! 🧸 Kata Nisa: Menghemat hari ini adalah investasi kebahagiaan besok! 🌈",
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
        // Easter Eggs:
        isNisa 
            ? "Halo Nisa! 🌤️ Kak Awan ingetin makan siang tepat waktu ya, kurangi jajan boba! 🍹🌸" 
            : "Halo $name! 🌤️ Kak Awan ingetin makan siang tepat waktu ya, kurangi jajan manis! 🍹🍀",
        "Siang $name! ☁️ Awan di langit menyerupai mangkok mie ayam... Lapar ya? Catat ya! 🍜",
        "Siang $name! 🌸 Nisa bilang: Jangan lupa ambil napas dalam-dalam dan tersenyum! ✨",
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
        // Easter Eggs:
        isNisa 
            ? "Sore Nisa! 🌇 Kak Awan baru kelar beres-beres nih, yuk rekap pengeluaran sore ini! ☁️🌸" 
            : "Sore $name! 🌇 Kak Awan baru kelar merapikan pembukuan nih, yuk rekap sore ini! ☁️🍀",
        "Sore $name! ☁️ Warna langit sore ini jingga cantik banget, secantik grafik tabunganmu! 📈",
        "Sore $name! 🍀 Pesan Nisa: Hemat itu bukan pelit, tapi peduli masa depan! 😉",
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
        // Easter Eggs:
        isNisa 
            ? "Malam Nisa! 🌙 Kak Awan nemu struk belanjaan di meja, buruan dicatat sebelum lupa! 😂🌸" 
            : "Malam $name! 🌙 Kak Awan nemu struk belanjaan keselip, buruan dicatat sebelum lupa! 😂🍀",
        "Malam $name! ☁️ Awan malam bertabur bintang menemani pembukuanmu yang rapi!",
        "Malam $name! ✨ Kata Nisa: Tidur nyenyak dimulai dari keuangan yang tidak berisik! 🤫🛌",
      ];
      return options[rng.nextInt(options.length)];
    } else if (hour >= 23 || hour < 3) {
      // Tengah Malam (23:00 - 02:59)
      final options = [
        "$name masih up? 🦉 Jaga kesehatan juga ya!",
        "Malam larut, $name! ⭐ Jangan lupa istirahat yang cukup!",
        "Hai $name! 🌌 Sunyinya malam paling pas buat merenungi tabungan harian!",
        "Malam Kak $name! 🦉 Masih sibuk? Luangkan 5 detik untuk catat pengeluaran terakhir!",
        "$name belum tidur? 🛌 Anggaranmu aman kok, yuk tidur!",
        // Easter Eggs:
        isNisa 
            ? "Tengah malam Nisa! 🦉 Kak Awan masih pantau nih, jangan scroll e-commerce terus ya! 😂🌸" 
            : "Tengah malam $name! 🦉 Kak Awan masih pantau nih, jangan scroll e-commerce terus ya! 😂🍀",
        "Midnight $name! ☁️ Bintang-bintang berbisik agar Kakak lekas tidur nyenyak! 🛌",
        "Malam larut $name! 🌸 Kata Nisa: Begadang boleh saja, asal jangan begadang belanjain saldo! 💸😂",
      ];
      return options[rng.nextInt(options.length)];
    } else {
      // Dini Hari (03:00 - 04:59)
      final options = [
        "Dini hari sunyi, $name! 🌌 Semangat buat yang terbangun lebih awal!",
        "Subuh hampir tiba, $name! ❄️ Udara dini hari sangat menenangkan!",
        "Dini hari produktif, $name! ✨ Rencana besar dimulai dari jam sesunyi ini!",
        "Hai $name! 🛌 Masih terjaga atau baru bangun? Sukses selalu!",
        // Easter Eggs:
        isNisa 
            ? "Dini hari Nisa! 🌸 Kak Awan selalu siap nemenin rekap kapanpun Kakak butuh bantuan! ☁️✨" 
            : "Dini hari $name! 🍀 Kak Awan selalu siap nemenin rekap kapanpun Kakak butuh bantuan! ☁️✨",
        "Dini hari $name! ☁️ Dinginnya malam akan segera berganti hangatnya fajar pembuka rezeki!",
        "Dini hari Kak $name! ⭐ Nisa ingetin: Minum air putih hangat dulu biar segar ya! ☕",
      ];
      return options[rng.nextInt(options.length)];
    }
  }

  void _showBadgeUnlocked(BuildContext context, String emoji, String title) {
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
            Text("Badge Baru! 🎉",
                style: TextStyle(fontSize: 13, color: widget.colors.textSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.colors.brandText)),
            const SizedBox(height: 8),
            Text("Kamu berhasil membuka badge baru!\nTerus semangat mencatat! 🌸",
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

    final int totalBadges = 16;
    final int completedMissions = [
      firstEntry, morningCompleted, balancedCompleted, budgetCompleted,
      fiveEntries, fifteenEntries, masterCompleted, saldoPositif,
      midnightEntry, subuhEntry, hematEkstrem, bosKeuangan,
      active2Days, active5Days, active7Days, active30Days,
    ].where((m) => m).length;

    return SingleChildScrollView(
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
          const SizedBox(height: 24),
        ],
      ),
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
}
