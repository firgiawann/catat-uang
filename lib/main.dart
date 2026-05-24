import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/budget_provider.dart';
import 'widgets/theme_colors.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/profile_dialog.dart';
import 'services/notification_helper.dart';
import 'services/analytics_helper.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catat_screen.dart';
import 'screens/riwayat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize indonesian locale formatting for dates
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase Analytics silently
  await AnalyticsHelper.initialize();
  await AnalyticsHelper.logAppOpen();

  // Initialize notifications helper
  await NotificationHelper.instance.initialize();

  // Constrain orientation to portrait for high-end aesthetic lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const CatetUangApp(),
    ),
  );
}

class CatetUangApp extends StatefulWidget {
  const CatetUangApp({Key? key}) : super(key: key);

  @override
  State<CatetUangApp> createState() => _CatetUangAppState();
}

class _CatetUangAppState extends State<CatetUangApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final activeProfile = provider.activeProfile;
    final activeFlavor = activeProfile?.themeFlavor ?? "Strawberry";

    final isDark = Theme.of(context).brightness == Brightness.dark ||
        (activeProfile?.themeMode == "Gelap");
    final colors = getThemeColorFlavor(activeFlavor, isDark: isDark);

    // Apply system status bar styling dynamically matching theme flavor!
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: colors.bottomNavBg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Catet Uang',
      debugShowCheckedModeBanner: false,
      themeMode: activeProfile == null
          ? ThemeMode.system
          : (activeProfile.themeMode == "Gelap"
              ? ThemeMode.dark
              : (activeProfile.themeMode == "Terang"
                  ? ThemeMode.light
                  : ThemeMode.system)),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: _showSplash
          ? SplashScreen(
              onFinish: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : (!provider.hasCompletedOnboarding
              ? OnboardingScreen(
                  onCompleted: (name, emoji, flavor) {
                    provider.createProfile(name, emoji, flavor);
                  },
                )
              : const MainAppScreen()),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  String _currentScreen = "home";
  bool _isFabExpanded = false;

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
      floatingActionButton: _buildFAB(context, colors),
      bottomNavigationBar: ElegantBottomNav(
        activeScreen: _currentScreen,
        colors: colors,
        onTabSelect: (tab) {
          if (tab == "keluar") {
            _showExitDialog(context, colors);
          } else {
            setState(() {
              _currentScreen = tab;
              _isFabExpanded = false; // Collapse FAB when changing tabs
            });
          }
        },
      ),
      body: GestureDetector(
        onTap: () {
          if (_isFabExpanded) {
            setState(() {
              _isFabExpanded = false;
            });
          }
        },
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildScreen(context, colors),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, ThemeColorFlavor colors) {
    switch (_currentScreen) {
      case "catat":
        return CatatScreen(
          key: const ValueKey("catat"),
          colors: colors,
          onBackClick: () {
            setState(() {
              _currentScreen = "home";
            });
          },
        );
      case "riwayat":
        return RiwayatScreen(
          key: const ValueKey("riwayat"),
          colors: colors,
          onBackClick: () {
            setState(() {
              _currentScreen = "home";
            });
          },
        );
      case "home":
      default:
        return HomeScreen(
          key: const ValueKey("home"),
          colors: colors,
          onNavigateToCatat: () {
            setState(() {
              _currentScreen = "catat";
            });
          },
          onNavigateToRiwayat: () {
            setState(() {
              _currentScreen = "riwayat";
            });
          },
          onManageProfileClick: () {
            _showProfileDialog(context, colors);
          },
          onAboutClick: () {
            _showAboutDialog(context, colors);
          },
        );
    }
  }

  void _showExitDialog(BuildContext context, ThemeColorFlavor colors) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Text(
            "Keluar Aplikasi? 👋",
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.brandText),
          ),
          content: Text(
            "Apakah Kakak yakin ingin menutup aplikasi Catet Uang ini?",
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop();
              },
              child: const Text("Keluar", style: TextStyle(color: amountRed, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, ThemeColorFlavor colors) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Text(
            "Tentang Catet Uang 🪙",
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.brandText, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Aplikasi sederhana untuk melacak pengeluaran agar keuangan tetap hemat dan terkendali. Dirancang dengan cinta dan penuh keteraturan!",
                  style: TextStyle(color: colors.textPrimary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  "Semua data disimpan lokal secara aman di HP menggunakan database SQLite terenkripsi melalui Room/Sqflite.",
                  style: TextStyle(fontSize: 11, color: colors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.headerBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text("💌", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            "Catatan Penyemangat:",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: colors.brandText,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Semoga aplikasi Catet Uang ini bisa membantu Kakak mengontrol dan mengelola keuangan dengan baik ya! Jangan hemat terlalu pelit, tapi jangan boros-boros juga yaa. Semangat rajin menabung untuk masa depan cerah! ✨",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.brandText,
                          height: 1.5,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tutup", style: TextStyle(color: colors.brandText, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context, ThemeColorFlavor colors) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ProfileDialog(colors: colors);
      },
    );
  }

  Widget? _buildFAB(BuildContext context, ThemeColorFlavor colors) {
    if (_currentScreen != "home") return null;

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final activeProfile = provider.activeProfile;
    if (activeProfile == null) return null;

    final themeMode = activeProfile.themeMode; // "Sistem", "Terang", "Gelap"
    IconData themeIcon = Icons.brightness_auto_rounded;
    String themeLabel = "Tema: Sistem 🅰️";
    if (themeMode == "Terang") {
      themeIcon = Icons.light_mode_rounded;
      themeLabel = "Tema: Terang ☀️";
    } else if (themeMode == "Gelap") {
      themeIcon = Icons.dark_mode_rounded;
      themeLabel = "Tema: Gelap 🌙";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          // Sub FAB 1: Tema Toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    themeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.brandText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: "fab_theme",
                backgroundColor: colors.backgroundPolish,
                foregroundColor: colors.accent,
                onPressed: () {
                  final newMode = themeMode == "Sistem"
                      ? "Terang"
                      : (themeMode == "Terang" ? "Gelap" : "Sistem");
                  provider.updateProfile(
                    activeProfile.id!,
                    activeProfile.name,
                    activeProfile.emoji,
                    activeProfile.themeFlavor,
                    newMode,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 1500),
                      content: Text("Mode tema diubah ke: $newMode! 🎉"),
                    ),
                  );
                },
                child: Icon(themeIcon, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Sub FAB 2: Kelola
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    "Kelola",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.brandText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: "fab_kelola",
                backgroundColor: colors.headerBg,
                foregroundColor: colors.brandText,
                onPressed: () {
                  setState(() {
                    _isFabExpanded = false;
                  });
                  _showProfileDialog(context, colors);
                },
                child: const Icon(Icons.manage_accounts_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Sub FAB 3: Catat
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    "Catat",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.brandText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: "fab_catat",
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _isFabExpanded = false;
                    _currentScreen = "catat";
                  });
                },
                child: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Main FAB
        FloatingActionButton(
          heroTag: "fab_main",
          backgroundColor: colors.brandText,
          foregroundColor: Colors.white,
          onPressed: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
            });
          },
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 250),
            turns: _isFabExpanded ? 0.125 : 0,
            child: Icon(_isFabExpanded ? Icons.close : Icons.edit_note_rounded, size: 28),
          ),
        ),
      ],
    );
  }
}
