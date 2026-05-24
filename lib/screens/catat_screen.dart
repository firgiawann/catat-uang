import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../widgets/theme_colors.dart';
import '../models/profile.dart';

class CatatScreen extends StatefulWidget {
  final VoidCallback onBackClick;
  final ThemeColorFlavor colors;

  const CatatScreen({
    Key? key,
    required this.onBackClick,
    required this.colors,
  }) : super(key: key);

  @override
  State<CatatScreen> createState() => _CatatScreenState();
}

class _CatatScreenState extends State<CatatScreen> {
  final _budgetController = TextEditingController(); // Dedicated budget controller
  final _amountController = TextEditingController(); // Dedicated transaction amount controller
  final _noteController = TextEditingController();

  String _selectedMonth = '';
  bool _isBudgetCardExpanded = false;
  bool _hasCheckedInitialBudget = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    _selectedMonth = provider.selectedMonth;
    _syncBudgetInput(provider);
  }

  void _syncBudgetInput(BudgetProvider provider) {
    final currentTarget = provider.currentBudget?.targetAmount ?? 0.0;
    if (currentTarget > 0.0) {
      _budgetController.text = currentTarget.toInt().toString();
    } else {
      _budgetController.clear();
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
    final targetAmount = provider.currentBudget?.targetAmount ?? 0.0;
    final totalTerpakai = provider.totalTerpakai;

    if (!_hasCheckedInitialBudget) {
      _isBudgetCardExpanded = (targetAmount == 0.0);
      _hasCheckedInitialBudget = true;
    }

    // Financial Mindfulness Coach Live preview based on TRANSACTION amount
    final double typedTxAmount = double.tryParse(_amountController.text) ?? 0.0;
    final double remainingNow = targetAmount - totalTerpakai;
    final double estimationAfter = remainingNow - typedTxAmount;

    String coachMessage = "Sisa anggaran bulanan berjalan: ${_formatRupiah(remainingNow)}";
    Color coachColor = widget.colors.brandText;
    Color coachBg = widget.colors.backgroundPolish;

    if (typedTxAmount > 0.0) {
      if (estimationAfter < 0.0) {
        coachMessage = "Peringatan: Catatan ini membuat anggaranmu minus sebesar ${_formatRupiah(estimationAfter.abs())}!";
        coachColor = amountRed;
        coachBg = softRed;
      } else {
        coachMessage = "Estimasi sisa anggaran berjalan setelah transaksi: ${_formatRupiah(estimationAfter)}";
        coachColor = widget.colors.accent;
        coachBg = widget.colors.accent.withOpacity(0.1);
      }
    }

    final List<Map<String, String>> defaultQuickTags = [
      {"label": "🍔 Makan", "value": "Makan"},
      {"label": "🧋 Jajan", "value": "Jajan"},
      {"label": "🚗 Bensin", "value": "Bensin"},
      {"label": "🛍️ Belanja", "value": "Belanja"},
      {"label": "💡 Tagihan", "value": "Tagihan"},
      {"label": "🧸 Main", "value": "Main"},
      {"label": "💰 Gaji", "value": "Gaji"},
      {"label": "🌸 Tabungan", "value": "Tabungan"}
    ];

    // Merge default and custom tags
    final List<Map<String, String>> allQuickTags = [
      ...defaultQuickTags,
      ...provider.customTags,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          _buildHeaderRow(activeProfile),
          const SizedBox(height: 16),

          Text(
            "Catat Catatan Keuangan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: widget.colors.brandText,
            ),
          ),
          const SizedBox(height: 14),

          // CARD 1: LIMIT ANGGARAN BULANAN (Collapsible/Expandable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _isBudgetCardExpanded
                ? _buildExpandedBudgetCard(provider, targetAmount, totalTerpakai)
                : _buildCollapsedBudgetCard(provider, targetAmount, totalTerpakai),
          ),
          const SizedBox(height: 18),

          // CARD 2: CATAT AKTIVITAS BARU (TRANSACTION RECORDING)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: widget.colors.border.withOpacity(0.4)),
            ),
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_shopping_cart_rounded, color: widget.colors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Catat Aktivitas Baru",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: widget.colors.brandText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nominal Transaksi (Amount Field)
                  Text(
                    "Nominal Transaksi",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.colors.backgroundPolish,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.colors.border.withOpacity(0.5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Rp. ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: widget.colors.brandText,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: widget.colors.brandText,
                            ),
                            decoration: InputDecoration(
                              hintText: "Masukkan nominal uang...",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: widget.colors.brandText.withOpacity(0.3),
                                fontWeight: FontWeight.bold,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Preset Buttons for transaction amounts
                  Row(
                    children: [
                      _buildPresetButton(10000, "+10k"),
                      const SizedBox(width: 8),
                      _buildPresetButton(25000, "+25k"),
                      const SizedBox(width: 8),
                      _buildPresetButton(50000, "+50k"),
                      const SizedBox(width: 8),
                      _buildPresetButton(100000, "+100k"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Note field (Deskripsi)
                  Text(
                    "Deskripsi & Keterangan",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    style: TextStyle(fontSize: 14, color: widget.colors.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Contoh: Beli nasi goreng, jajan kopi...",
                      hintStyle: TextStyle(color: widget.colors.textSecondary.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: widget.colors.backgroundPolish,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

                  // Horizontal Quick Tags Shortcuts (With Add Button at the end!)
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allQuickTags.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == allQuickTags.length) {
                          // Far end "+" Add Button
                          return InkWell(
                            onTap: () {
                              _showAddCustomTagDialog(provider);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.colors.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: widget.colors.accent.withOpacity(0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Icon(Icons.add_rounded, color: widget.colors.accent, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Tambah",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: widget.colors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final tag = allQuickTags[index];
                        final isCustom = index >= defaultQuickTags.length;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _noteController.text = tag["value"]!;
                            });
                          },
                          onLongPress: () {
                            if (isCustom) {
                              _showDeleteCustomTagDialog(provider, index - defaultQuickTags.length, tag["label"]!);
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCustom ? widget.colors.headerBg : widget.colors.backgroundPolish,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCustom ? widget.colors.accent.withOpacity(0.4) : widget.colors.border.withOpacity(0.3),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tag["label"]!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.colors.brandText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mindfulness financial coach preview block
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: coachBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: coachColor.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "💡",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            coachMessage,
                            style: TextStyle(
                              fontSize: 11,
                              color: coachColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save Buttons: +Pemasukan and -Pengeluaran
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softGreen,
                            side: BorderSide(color: softGreenText.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.arrow_upward_rounded, color: softGreenText, size: 16),
                          label: const Text(
                            "Masuk (+)",
                            style: TextStyle(color: softGreenText, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                          onPressed: () {
                            _addTx(provider, isExpense: false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softRed,
                            side: BorderSide(color: softRedText.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.arrow_downward_rounded, color: softRedText, size: 16),
                          label: const Text(
                            "Keluar (-)",
                            style: TextStyle(color: softRedText, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                          onPressed: () {
                            _addTx(provider, isExpense: true);
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Kembali ke Beranda Button
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

  Widget _buildCollapsedBudgetCard(
    BudgetProvider provider,
    double targetAmount,
    double totalTerpakai,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: widget.colors.border.withOpacity(0.3)),
      ),
      color: widget.colors.headerBg,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Limit Anggaran Bulanan",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Bulan: $_selectedMonth",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.colors.brandText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatRupiah(targetAmount),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: widget.colors.brandText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note_rounded, color: widget.colors.accent, size: 24),
                  tooltip: "Ubah Limit Anggaran",
                  onPressed: () {
                    setState(() {
                      _isBudgetCardExpanded = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Target: ${_formatRupiah(targetAmount)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.colors.textPrimary,
                  ),
                ),
                Text(
                  "Terpakai: ${_formatRupiah(totalTerpakai)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.colors.brandText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedBudgetCard(
    BudgetProvider provider,
    double targetAmount,
    double totalTerpakai,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: widget.colors.headerBg,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.track_changes_rounded, color: widget.colors.accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "Limit Anggaran Bulanan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: widget.colors.brandText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up_rounded, color: widget.colors.brandText, size: 20),
                  onPressed: () {
                    setState(() {
                      _isBudgetCardExpanded = false;
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 6),

            // Month Selector Row
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.colors.border.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    icon: Icon(Icons.arrow_drop_down_rounded, color: widget.colors.brandText),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.brandText,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedMonth = newValue;
                        });
                        provider.selectMonth(newValue).then((_) {
                          _syncBudgetInput(provider);
                          final target = provider.currentBudget?.targetAmount ?? 0.0;
                          setState(() {
                            _isBudgetCardExpanded = (target == 0.0);
                          });
                        });
                      }
                    },
                    items: provider.indonesianMonths
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(Icons.date_range_rounded, color: widget.colors.brandText, size: 16),
                            const SizedBox(width: 8),
                            Text("Bulan: $value"),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Input Box for Budget Limit
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.colors.border.withOpacity(0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Text(
                    "Rp. ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: widget.colors.brandText,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: widget.colors.brandText,
                      ),
                      decoration: InputDecoration(
                        hintText: "Atur target pengeluaran bulanan...",
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: widget.colors.brandText.withOpacity(0.35),
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Info Target Saldo & Terpakai
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Target: ${_formatRupiah(targetAmount)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.colors.textPrimary,
                  ),
                ),
                Text(
                  "Terpakai: ${_formatRupiah(totalTerpakai)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.colors.brandText,
                  ),
                )
              ],
            ),
            const SizedBox(height: 14),

            // Budget Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.colors.brandText.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      _showResetConfirmDialog(provider);
                    },
                    child: const Text(
                      "Mulai Baru",
                      style: TextStyle(color: softRedText, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colors.brandText,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final parsed = double.tryParse(_budgetController.text) ?? 0.0;
                      _showSaveBudgetConfirmDialog(provider, parsed);
                    },
                    child: const Text(
                      "Simpan Target",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
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

  Widget _buildPresetButton(double value, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            final current = double.tryParse(_amountController.text) ?? 0.0;
            _amountController.text = (current + value).toInt().toString();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: widget.colors.backgroundPolish,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.colors.border.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: widget.colors.brandText,
            ),
          ),
        ),
      ),
    );
  }

  void _addTx(BudgetProvider provider, {required bool isExpense}) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nominal transaksi harus lebih dari 0 ya Kak! 😊")),
      );
      return;
    }

    var note = _noteController.text.trim();
    if (note.isEmpty) {
      note = "Lainnya";
    }

    provider.addTransaction(
      amount: amount,
      note: note,
      isExpense: isExpense,
    );

    _amountController.clear();
    _noteController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isExpense
              ? "Pengeluaran berhasil dicatat! 💸 Tetap hemat ya Kak."
              : "Pemasukan berhasil dicatat! 💰 Rajin menabung selalu.",
        ),
      ),
    );

    setState(() {});
  }

  void _showResetConfirmDialog(BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Mulai Baru Bulan Ini? ⚠️",
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText),
          ),
          content: Text(
            "Apakah Kakak yakin ingin menghapus semua catatan transaksi dan target anggaran untuk bulan $_selectedMonth? Tindakan ini tidak bisa dibatalkan!",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: widget.colors.accent, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                provider.resetCurrentMonth();
                _budgetController.clear();
                Navigator.pop(context);
                setState(() {
                  _isBudgetCardExpanded = true; // Expand back since target is now reset (0)
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Data bulan $_selectedMonth berhasil dibersihkan! 🍃")),
                );
              },
              child: const Text("Hapus Semua", style: TextStyle(color: amountRed, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSaveBudgetConfirmDialog(BudgetProvider provider, double amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Atur Target Anggaran? 🎯",
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText, fontSize: 16),
          ),
          content: Text(
            "Apakah Kakak yakin ingin mengatur target anggaran bulan $_selectedMonth sebesar ${_formatRupiah(amount)}?",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: widget.colors.accent, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                provider.saveBudget(amount);
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
                setState(() {
                  _isBudgetCardExpanded = false; // Automatically collapse!
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Target anggaran bulan $_selectedMonth berhasil diatur ke ${_formatRupiah(amount)}! 🎉")),
                );
              },
              child: Text("Atur", style: TextStyle(color: widget.colors.brandText, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomTagDialog(BudgetProvider provider) {
    final emojiController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Tambah Label Kustom 🏷️",
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiController,
                maxLength: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: "Emoji",
                  hintText: "🍿, 💅, 🐈",
                  filled: true,
                  fillColor: widget.colors.backgroundPolish,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                style: TextStyle(fontSize: 14, color: widget.colors.textPrimary, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Nama Label",
                  hintText: "Bioskop, Kucing...",
                  filled: true,
                  fillColor: widget.colors.backgroundPolish,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: widget.colors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                final emoji = emojiController.text.trim();
                final labelText = labelController.text.trim();
                if (labelText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama label tidak boleh kosong Kak! 📝")),
                  );
                  return;
                }

                final finalEmoji = emoji.isEmpty ? "🏷️" : emoji;
                final tagLabel = "$finalEmoji $labelText";
                provider.addCustomTag(tagLabel, labelText);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Kategori kustom '$tagLabel' berhasil ditambahkan! 🎉")),
                );
              },
              child: Text("Tambah", style: TextStyle(color: widget.colors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCustomTagDialog(BudgetProvider provider, int customIndex, String tagLabel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Hapus Label Kustom? 🗑️",
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText, fontSize: 16),
          ),
          content: Text(
            "Apakah Kakak yakin ingin menghapus label kustom '$tagLabel'?",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: widget.colors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                provider.removeCustomTag(customIndex);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Label kustom '$tagLabel' berhasil dihapus! 🗑️")),
                );
              },
              child: const Text("Hapus", style: TextStyle(color: amountRed, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
