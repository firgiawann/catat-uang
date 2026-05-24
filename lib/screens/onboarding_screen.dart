import 'package:flutter/material.dart';
import '../widgets/theme_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(String name, String emoji, String flavor) onCompleted;

  const OnboardingScreen({Key? key, required this.onCompleted}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Profile setup states
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedEmoji = "🐱";
  String _selectedFlavor = "Strawberry";

  final List<String> _emojis = const [
    "🐱", "🐻", "🐰", "🐼", "🐸", "🦊", "🐹", "🦁", "🐯", "🐨", "🦒", "🐣"
  ];
  
  final List<String> _flavors = const [
    "Strawberry", "Matcha", "Ocean", "Lavender"
  ];

  // Loading setup state
  bool _isLoading = false;
  int _loadingStep = 0;
  final List<String> _loadingTexts = [
    "Menyiapkan ruang hematmu... 💎",
    "Merias aplikasi dengan warna kesukaanmu... 🎨",
    "Mengaktifkan Awan sebagai Tour Guide setiamu... ☁️✨",
    "Membuat pertahanan hemat anti-boros... 🛡️",
    "Semua siap! Awan siap menemanimu! 🚀✨"
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showProfileSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final activeColors = getThemeColorFlavor(_selectedFlavor);
            final typedName = _nameController.text.trim();

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dialog Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("🐾🐾", style: TextStyle(fontSize: 16, color: activeColors.accent)),
                                const SizedBox(width: 6),
                                Text(
                                  "Buat Profil Baru!",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: activeColors.brandText,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Cute Warn Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: activeColors.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: activeColors.accent.withOpacity(0.12)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 34),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _getDynamicBannerMessage(typedName),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: activeColors.brandText,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Name Field
                        Text(
                          "Nama Panggilan Kamu ✍️",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: activeColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(fontSize: 14, color: activeColors.textPrimary, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: "Contoh: Budi, Sarah, ...",
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: activeColors.textSecondary.withOpacity(0.4),
                              fontWeight: FontWeight.normal,
                            ),
                            filled: true,
                            fillColor: activeColors.backgroundPolish.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: activeColors.border.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: activeColors.accent, width: 1.5),
                            ),
                            errorStyle: const TextStyle(fontSize: 10, height: 0.8),
                          ),
                          onChanged: (val) {
                            setDialogState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nama tidak boleh kosong Kak! 📝";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Horizontal Emojis Selector
                        Text(
                          "Pilih Maskot Hewan-hewan Cantik: 🐻 🐰",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: activeColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _emojis.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final emoji = _emojis[index];
                              final isSelected = _selectedEmoji == emoji;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedEmoji = emoji;
                                  });
                                  setDialogState(() {});
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected ? activeColors.headerBg : activeColors.backgroundPolish.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? activeColors.accent : activeColors.border.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Gaya Vibe Warna pills selector
                        Text(
                          "Pilih Gaya Vibe Warna Aplikasi: 🎨 🌈",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: activeColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _flavors.map((flavor) {
                            final isSelected = _selectedFlavor == flavor;
                            final flavorColors = getThemeColorFlavor(flavor);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedFlavor = flavor;
                                });
                                setDialogState(() {});
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? flavorColors.headerBg : flavorColors.backgroundPolish.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? flavorColors.accent : flavorColors.border.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: flavorColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      flavor,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: flavorColors.brandText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Mulai Kelola Catet Uang! Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColors.accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context); // Close dialog
                              _startLoadingSimulation();
                            }
                          },
                          child: const Text(
                            "Mulai Kelola Catet Uang! ✨🚀",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startLoadingSimulation() async {
    setState(() {
      _isLoading = true;
      _loadingStep = 0;
    });

    // Loop through simulated loading steps with fun alerts
    for (int i = 0; i < _loadingTexts.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        setState(() {
          _loadingStep = i;
        });
      }
    }

    // Complete onboarding!
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onCompleted(
      _nameController.text.trim(),
      _selectedEmoji,
      _selectedFlavor,
    );
  }

  String _getDynamicBannerMessage(String name) {
    if (name.isEmpty) {
      return "Halo Teman! Yuk tentukan maskot & nuansa warna kesukaanmu! 😊";
    }

    final lowerName = name.toLowerCase().trim();
    final isNisaOrNurun = lowerName.contains('nisa');
    if (lowerName == 'awan') {
      return "Halo Awan! ☁️ Siap menjadi guide keuangan terbaik hari ini? Mari buat catatan keuangan sesempurna mungkin agar bisa menyebarkan kebiasaan rapi dan tenang ke orang-orang di sekitarmu! 😉🌸";
    } else if (isNisaOrNurun) {
      return "Halo Nisa! 🌸 Bunga-bunga bermekaran menyambut langkah hematmu hari ini. Awan siap menjadi guide setiamu untuk menjaga dompetmu tetap rapi dan tenang setiap hari. Mari mulai perjalanan hemat kita! ☁️☕";
    }

    final code = name.length % 3;
    String prefix = "Wah, Kak $name!";
    if (code == 0) prefix = "Aww, Kak $name! ✨";
    if (code == 1) prefix = "Halo Kak $name! 🌸";
    if (code == 2) prefix = "Kak $name yang rajin! 💎";

    switch (_selectedEmoji) {
      case "🐱":
        return "$prefix Kucing imut ini sudah meow-meow tidak sabar menemanimu mencatat pengeluaran harian! 🐾😻";
      case "🐻":
        return "$prefix Beruang gemoy yang tangguh ini siap memeluk tabunganmu dari ancaman boros! 🐻🛡️";
      case "🐰":
        return "$prefix Kelinci lincah ini siap melompat riang menyambut setiap rupiah yang berhasil kamu hemat! 🐰✨";
      case "🐼":
        return "$prefix Panda santuy ini setuju sekali kalau mencatat uang adalah jalan pintas menuju kaya! 🐼🎋";
      case "🐸":
        return "$prefix Katak keberuntungan ini akan berbunyi riang mendatangkan energi positif bagi dompetmu! 🐸💰";
      case "🦊":
        return "$prefix Rubah cerdik ini sudah merancang trik hemat paling rahasia khusus untuk Kakak! 🦊💡";
      case "🐹":
        return "$prefix Hamster comel ini siap membantu mengumpulkan butir-butir rupiah demi masa depan! 🐹🌾";
      case "🦁":
        return "$prefix Singa gagah berani ini akan berdiri tegak menjaga pintu gerbang anggaran bulananmu! 🦁👑";
      case "🐯":
        return "$prefix Harimau pemberani ini akan langsung menerkam habis semua hasrat belanja impulsifmu! 🐯🔥";
      case "🐨":
        return "$prefix Koala manis ini berjanji akan setia mendampingi setiap langkah belanjamu agar tetap teratur! 🐨🐨";
      case "🦒":
        return "$prefix Jerapah jangkung ini bisa melihat masa depan finansialmu yang sangat cerah dari atas sini! 🦒🌟";
      case "🐣":
        return "$prefix Anak ayam lucu yang baru menetas ini siap diajak merintis celengan dari nol bersama-sama! 🐣🐣";
      default:
        return "$prefix Nama yang imut sekali! 😍 Yuk pilih maskot pelindung & vibe warna favoritmu!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColors = getThemeColorFlavor(_selectedFlavor);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: activeColors.backgroundPolish,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColors.accent),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _loadingTexts[_loadingStep],
                    key: ValueKey<int>(_loadingStep),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: activeColors.brandText,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Harap tunggu sebentar ya... 🌸",
                  style: TextStyle(
                    fontSize: 11,
                    color: activeColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: activeColors.backgroundPolish,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Catet Uang — Perkenalan 💸",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: activeColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: _showProfileSetupDialog,
                    child: Text(
                      "Lewati ➡️",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: activeColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle Slider Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Slide 1
                  _buildSliderPage(
                    title: "Selamat Datang di\nCatet Uang! 🪙",
                    desc: "Aplikasi pencatatan keuangan imu-imut, rapi, dan comel untuk memantau pemasukan dan pengeluaran harian demi masa depan hemat!",
                    imageWidget: FloatingMascotWidget(
                      child: Container(
                        width: 125,
                        height: 125,
                        decoration: BoxDecoration(
                          color: activeColors.headerBg,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: activeColors.accent.withOpacity(0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/ic_launcher.webp',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.wallet_rounded, color: activeColors.accent, size: 54);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Slide 2
                  _buildSliderPage(
                    title: "Analisis Grafik Bulat Sempurna 📊",
                    desc: "Bebas pantau persentase pengeluaran terhadap seluruh dana masuk. Lihat selisih netto di tengah lingkaran grafik secara real-time dan comel!",
                    imageWidget: Container(
                      width: 200,
                      height: 130,
                      decoration: BoxDecoration(
                        color: activeColors.headerBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tampilan Grafik Bulat Dinamis",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: activeColors.brandText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: _currentPage == 1 ? 0.625 : 0.0),
                                  duration: const Duration(milliseconds: 1400),
                                  curve: Curves.easeOutBack,
                                  builder: (context, val, child) {
                                    return CircularProgressIndicator(
                                      value: val,
                                      strokeWidth: 6,
                                      backgroundColor: amountRed,
                                      valueColor: const AlwaysStoppedAnimation<Color>(amountGreen),
                                    );
                                  },
                                ),
                                Text(
                                  "62.5%",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: activeColors.brandText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(color: amountGreen, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Masuk",
                                style: TextStyle(fontSize: 7.5, color: activeColors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(color: amountRed, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Keluar",
                                style: TextStyle(fontSize: 7.5, color: activeColors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  // Slide 3
                  _buildSliderPage(
                    title: "100% Offline & Sangat Aman 🔒",
                    desc: "Seluruh riwayat keuangan Anda dijamin privat tanpa server cloud, tanpa login, dan murni tersimpan di penyimpanan lokal handphone Anda.",
                    imageWidget: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: activeColors.headerBg,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: activeColors.accent.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: _currentPage == 2 ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, val, child) {
                          return Transform.scale(
                            scale: val,
                            child: Icon(
                              Icons.lock_rounded,
                              color: activeColors.accent,
                              size: 54,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Indicators & Buttons Row
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 12),
              child: Column(
                children: [
                  // Three Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (idx) {
                      final isSelected = _currentPage == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 16 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? activeColors.accent : activeColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      // Kembali button
                      if (_currentPage > 0) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: activeColors.border.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(Icons.arrow_back_rounded, color: activeColors.brandText, size: 14),
                            onPressed: _prevPage,
                            label: Text(
                              "Kembali",
                              style: TextStyle(
                                color: activeColors.brandText,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Lanjut / Setup Profil button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColors.accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: _currentPage == 2
                              ? _showProfileSetupDialog
                              : _nextPage,
                          child: Text(
                            _currentPage == 2 ? "Buka Setup Profil! 🎀" : "Lanjut",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderPage({
    required String title,
    required String desc,
    required Widget imageWidget,
  }) {
    final activeColors = getThemeColorFlavor(_selectedFlavor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Render dynamic image widget!
          imageWidget,
          const SizedBox(height: 36),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: activeColors.brandText,
              letterSpacing: -0.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: activeColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingMascotWidget extends StatefulWidget {
  final Widget child;
  const FloatingMascotWidget({Key? key, required this.child}) : super(key: key);

  @override
  _FloatingMascotWidgetState createState() => _FloatingMascotWidgetState();
}

class _FloatingMascotWidgetState extends State<FloatingMascotWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

