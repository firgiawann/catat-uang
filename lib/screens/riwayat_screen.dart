import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/profile.dart';
import '../widgets/theme_colors.dart';
import '../widgets/donut_chart.dart';

class RiwayatScreen extends StatefulWidget {
  final VoidCallback onBackClick;
  final ThemeColorFlavor colors;

  const RiwayatScreen({
    Key? key,
    required this.onBackClick,
    required this.colors,
  }) : super(key: key);

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  DateTime _selectedDate = DateTime.now();

  // Category constants
  static const String catKuliner = "Kuliner";
  static const String catBelanja = "Belanja";
  static const String catTransport = "Transportasi";
  static const String catTagihan = "Tagihan";
  static const String catHiburan = "Hiburan";
  static const String catLainnya = "Lain-lain";

  final List<Map<String, dynamic>> _categoriesList = const [
    {"name": catKuliner, "emoji": "🍔", "color": Color(0xFFFF9F43)},
    {"name": catBelanja, "emoji": "🛍️", "color": Color(0xFF9B5DE5)},
    {"name": catTransport, "emoji": "🚗", "color": Color(0xFF00BBF9)},
    {"name": catTagihan, "emoji": "💡", "color": Color(0xFF00F5D4)},
    {"name": catHiburan, "emoji": "🧸", "color": Color(0xFFF15BB5)},
    {"name": catLainnya, "emoji": "🌸", "color": Color(0xFFFEC5BB)},
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    _searchController.text = provider.searchQuery;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset > 60 && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (offset <= 60 && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    }
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _guessCategory(String noteText) {
    final lower = noteText.toLowerCase();
    
    final kulinerKeys = ["makan", "minum", "seblak", "boba", "bakso", "kopi", "warteg", "nasgor", "sate", "mie", "snack", "gacoan", "angkringan", "kuliner", "pecel", "ayam", "lauk", "jajan"];
    if (kulinerKeys.any((k) => lower.contains(k))) return catKuliner;

    final belanjaKeys = ["shopee", "tokped", "mall", "baju", "celana", "skincare", "kosmetik", "sepatu", "tas", "belanja", "supermarket", "minimarket", "alfa", "indo", "beli", "checkout", "co"];
    if (belanjaKeys.any((k) => lower.contains(k))) return catBelanja;

    final transportKeys = ["gojek", "grab", "bensin", "parkir", "angkot", "bus", "ojek", "kereta", "tiket", "travel", "pertamina", "shell"];
    if (transportKeys.any((k) => lower.contains(k))) return catTransport;

    final tagihanKeys = ["wifi", "listrik", "pulsa", "kost", "air", "bpjs", "indihome", "netflix", "premium", "langganan", "token", "tagihan", "spp"];
    if (tagihanKeys.any((k) => lower.contains(k))) return catTagihan;

    final hiburanKeys = ["bioskop", "game", "nonton", "cinema", "healing", "wisata", "pantai", "karaoke", "playstation", "warnet", "topup", "novel", "komik"];
    if (hiburanKeys.any((k) => lower.contains(k))) return catHiburan;

    return catLainnya;
  }

  String _formatRupiah(double value) {
    if (value == 0.0) return "Rp0";
    final isNegative = value < 0;
    final formatter = NumberFormat("#,###", "id_ID");
    final formatted = "Rp${formatter.format(value.abs()).replaceAll(',', '.')}";
    return isNegative ? "-$formatted" : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final activeProfile = provider.activeProfile;
    final selectedMonth = provider.selectedMonth;

    final budgetTarget = provider.currentBudget?.targetAmount ?? 0.0;
    final totalTerpakai = provider.totalTerpakai;
    final totalPemasukan = provider.totalPemasukan;

    // Aggregates for filter
    final transactions = provider.filteredTransactions;
    final allMonthTransactions = provider.currentTransactions;

    // Filter transactions to show only the selected day's transactions
    final dailyTransactions = transactions.where((tx) {
      final txDate = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      return txDate.year == _selectedDate.year &&
             txDate.month == _selectedDate.month &&
             txDate.day == _selectedDate.day;
    }).toList();

    final double progressFraction = budgetTarget > 0.0
        ? (totalTerpakai / budgetTarget).clamp(0.0, 1.0)
        : 0.0;

    final int sisaProgressPercent = budgetTarget > 0.0
        ? (((budgetTarget - totalTerpakai) / budgetTarget) * 100).clamp(0.0, 100.0).toInt()
        : 100;

    final isOverBudget = totalTerpakai > budgetTarget;

    // Spend Analysis calculations based on EXPENDITURES
    final expenseTransactions = allMonthTransactions.where((tx) => tx.isExpense).toList();
    final totalExpense = expenseTransactions.fold(0.0, (sum, tx) => sum + tx.amount);

    // Grouping spending categories
    List<Map<String, dynamic>> categorySpendInfo = [];
    if (totalExpense > 0.0) {
      for (final cat in _categoriesList) {
        final double sum = allMonthTransactions
            .where((tx) => tx.isExpense && _guessCategory(tx.note) == cat["name"])
            .fold(0.0, (s, tx) => s + tx.amount);

        if (sum > 0.0) {
          categorySpendInfo.add({
            "name": cat["name"],
            "emoji": cat["emoji"],
            "color": cat["color"] as Color,
            "amount": sum,
            "percentage": ((sum / totalExpense) * 100).toInt()
          });
        }
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          _buildHeaderRow(activeProfile),
          const SizedBox(height: 12),

          Text(
            "Riwayat Transaksi",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: widget.colors.brandText,
            ),
          ),
          const SizedBox(height: 12),

          // Collapsible Summary Card Block using AnimatedCrossFade with bouncy magnet curves
          AnimatedCrossFade(
            firstChild: _buildExpandedCard(
              provider,
              budgetTarget,
              totalPemasukan,
              totalTerpakai,
              progressFraction,
              sisaProgressPercent,
              isOverBudget,
            ),
            secondChild: _buildCollapsedCard(
              provider,
              totalPemasukan,
              totalTerpakai,
            ),
            crossFadeState: _isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 350),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.fastOutSlowIn,
          ),

          // Analisis Pengeluaran Card
          if (categorySpendInfo.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              "Analisis Pengeluaran",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.colors.brandText,
              ),
            ),
            const SizedBox(height: 6),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: widget.colors.border.withOpacity(0.4)),
              ),
              color: Colors.white,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Segmented Color Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 12,
                        child: Row(
                          children: categorySpendInfo.map((cat) {
                            final double pct = (cat["amount"] as double) / totalExpense;
                            return Expanded(
                              flex: (pct * 1000).toInt().clamp(1, 1000),
                              child: Container(color: cat["color"] as Color),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Detail list
                    Column(
                      children: categorySpendInfo.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: cat["color"] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${cat['emoji']} ${cat['name']}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: widget.colors.textPrimary,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "${_formatRupiah(cat['amount'] as double)} (${cat['percentage']}%)",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: widget.colors.accent,
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 13, color: widget.colors.textPrimary, fontWeight: FontWeight.w600),
            onChanged: (val) => provider.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: "Cari transaksi...",
              hintStyle: TextStyle(color: widget.colors.textSecondary.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.normal),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              prefixIcon: Icon(Icons.search_rounded, color: widget.colors.textSecondary, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.colors.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.colors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter type chips
          Row(
            children: ["Semua", "Pemasukan", "Pengeluaran"].map((type) {
              final isSelected = provider.filterType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : widget.colors.brandText,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: widget.colors.accent,
                  backgroundColor: widget.colors.bottomNavBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isSelected ? Colors.transparent : widget.colors.border.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  showCheckmark: false,
                  onSelected: (_) {
                    provider.setFilterType(type);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Date Navigator Header
          _buildDateNavigator(widget.colors),
          const SizedBox(height: 12),

          // Ledger Title Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Riwayat Hari Ini",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.brandText,
                ),
              ),
              Text(
                "Jumlah: ${dailyTransactions.length}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: widget.colors.accent,
                ),
              )
            ],
          ),
          const SizedBox(height: 10),

          // Ledger list filtered by day
          if (dailyTransactions.isEmpty) ...[
            Container(
              height: 140,
              alignment: Alignment.center,
              child: Text(
                "Tidak ada catatan transaksi hari ini.\nYuk hemat! 🌸",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            )
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = dailyTransactions[index];
                final dateStr = DateFormat("dd MMM, HH:mm", "id_ID")
                    .format(DateTime.fromMillisecondsSinceEpoch(tx.timestamp));

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: widget.colors.progressTrack),
                  ),
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: (tx.isExpense ? amountRed : amountGreen).withOpacity(0.12),
                          child: Icon(
                            tx.isExpense ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                            color: tx.isExpense ? amountRed : amountGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.note,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: widget.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.colors.textSecondary,
                                ),
                              )
                            ],
                          ),
                        ),
                        Text(
                          "${tx.isExpense ? '-' : '+'}${_formatRupiah(tx.amount)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: tx.isExpense ? amountRed : amountGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            color: widget.colors.textSecondary.withOpacity(0.6),
                            size: 16,
                          ),
                          onPressed: () {
                            provider.deleteTransaction(tx.id!);
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          ],
          const SizedBox(height: 24),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: widget.colors.border, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: widget.onBackClick,
            child: Text(
              "Kembali ke Beranda",
              style: TextStyle(color: widget.colors.textSecondary, fontWeight: FontWeight.bold),
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
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: widget.colors.headerBg,
              child: Text(
                activeProfile?.emoji ?? "🐱",
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hai ${activeProfile?.name ?? 'Teman'}",
                  style: TextStyle(
                    fontSize: 12,
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
            )
          ],
        ),
      ],
    );
  }

  Widget _buildMonthPillDropdown(BudgetProvider provider) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: widget.colors.bottomNavBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.colors.border.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: provider.selectedMonth,
            icon: Icon(Icons.arrow_drop_down_rounded, color: widget.colors.brandText, size: 16),
            isDense: true,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.colors.brandText,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.selectMonth(newValue);
              }
            },
            items: provider.indonesianMonths
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSideIndicator({
    required String title,
    required double amount,
    required Color indicatorColor,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: widget.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatRupiah(amount),
              style: TextStyle(
                fontSize: 13,
                color: indicatorColor,
                fontWeight: FontWeight.w900,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildExpandedCard(
    BudgetProvider provider,
    double budgetTarget,
    double totalPemasukan,
    double totalTerpakai,
    double progressFraction,
    int sisaProgressPercent,
    bool isOverBudget,
  ) {
    return Card(
      key: const ValueKey("expanded_rekap_card"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: widget.colors.border.withOpacity(0.4)),
      ),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: _toggleCollapse,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Rekap Keuanganmu",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: widget.colors.brandText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.info_outline_rounded, color: widget.colors.textSecondary.withOpacity(0.6), size: 14),
                        ],
                      ),
                      Text(
                        "Periode ${provider.selectedMonth}",
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  _buildMonthPillDropdown(provider)
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DonutChart(
                    pemasukan: totalPemasukan,
                    pengeluaran: totalTerpakai,
                    colors: widget.colors,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSideIndicator(
                        title: "Pemasukan",
                        amount: totalPemasukan,
                        indicatorColor: amountGreen,
                      ),
                      const SizedBox(height: 8),
                      _buildSideIndicator(
                        title: "Pengeluaran",
                        amount: totalTerpakai,
                        indicatorColor: amountRed,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: widget.colors.border.withOpacity(0.3)),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sisa Anggaran: $sisaProgressPercent%",
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.colors.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Status: ${isOverBudget ? 'BOROS' : 'AMAN'}",
                    style: TextStyle(
                      fontSize: 11,
                      color: isOverBudget ? amountRed : amountGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 8,
                  color: widget.colors.progressTrack,
                  child: FractionallySizedBox(
                    widthFactor: progressFraction,
                    alignment: Alignment.centerLeft,
                    child: Container(color: widget.colors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Batas: ${_formatRupiah(budgetTarget)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Terpakai: ${_formatRupiah(totalTerpakai)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedCard(
    BudgetProvider provider,
    double totalPemasukan,
    double totalTerpakai,
  ) {
    return Card(
      key: const ValueKey("collapsed_rekap_card"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.colors.border.withOpacity(0.4)),
      ),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: _toggleCollapse,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              Text("📊", style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rekap Keuangan (Ketuk untuk Detail)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: widget.colors.brandText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "Masuk: ",
                          style: TextStyle(fontSize: 10, color: widget.colors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatRupiah(totalPemasukan),
                          style: const TextStyle(fontSize: 10, color: amountGreen, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Keluar: ",
                          style: TextStyle(fontSize: 10, color: widget.colors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatRupiah(totalTerpakai),
                          style: const TextStyle(fontSize: 10, color: amountRed, fontWeight: FontWeight.w900),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildMonthPillDropdown(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigator(ThemeColorFlavor colors) {
    final now = DateTime.now();
    String dateLabel = "";

    final diff = DateTime(now.year, now.month, now.day).difference(
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
    ).inDays;

    if (diff == 0) {
      dateLabel = "Hari Ini • ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate)}";
    } else if (diff == 1) {
      dateLabel = "Kemarin • ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate)}";
    } else if (diff == -1) {
      dateLabel = "Besok • ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate)}";
    } else {
      dateLabel = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(_selectedDate);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bottomNavBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.brandText, size: 16),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: Text(
              dateLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: colors.brandText,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: colors.brandText, size: 16),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }
}
