import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/profile.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import '../services/widget_helper.dart';
import '../services/analytics_helper.dart';

class BudgetProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  // Changed from late to nullable to avoid LateInitializationError race condition
  SharedPreferences? _prefs;

  // Raw States
  List<Profile> _allProfiles = [];
  Profile? _activeProfile;
  String _selectedMonth = '';
  MonthlyBudget? _currentBudget;
  List<Transaction> _currentTransactions = [];

  // Inputs/Filters
  String _searchQuery = '';
  String _filterType = 'Semua'; // 'Semua', 'Pemasukan', 'Pengeluaran'

  // Lists
  List<String> _indonesianMonths = [];

  // Getters
  List<Profile> get allProfiles => _allProfiles;
  Profile? get activeProfile => _activeProfile;
  String get selectedMonth => _selectedMonth;
  MonthlyBudget? get currentBudget => _currentBudget;
  List<Transaction> get currentTransactions => _currentTransactions;
  List<String> get indonesianMonths => _indonesianMonths;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;

  // Onboarding check
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // Custom tags
  List<Map<String, String>> _customTags = [];
  List<Map<String, String>> get customTags => _customTags;

  BudgetProvider() {
    _selectedMonth = _getCurrentMonthString();
    _generateIndonesianMonths();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = _prefs!.getBool('has_completed_onboarding_v5') ?? false;

      // Load custom tags with guard against corrupt data
      final savedTags = _prefs!.getStringList('custom_tags_v1');
      if (savedTags != null) {
        _customTags = savedTags
            .where((t) => t.contains('|'))
            .map((t) {
              final parts = t.split('|');
              if (parts.length >= 2) {
                return {"label": parts[0], "value": parts[1]};
              }
              return <String, String>{};
            })
            .where((m) => m.isNotEmpty)
            .toList();
      } else {
        _customTags = [];
      }

      await loadAllData();
    } catch (e) {
      debugPrint('[BudgetProvider] _initPrefs error: $e');
    }
  }

  void _generateIndonesianMonths() {
    List<String> months = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      DateTime prevMonth = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('yyyy-MM').format(prevMonth));
    }
    _indonesianMonths = months;
  }

  String _getCurrentMonthString() {
    return DateFormat('yyyy-MM').format(DateTime.now());
  }

  // --- Core Aggregates ---

  double get totalPemasukan {
    return _currentTransactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalTerpakai {
    return _currentTransactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get saldo => totalPemasukan - totalTerpakai;

  List<Transaction> get filteredTransactions {
    return _currentTransactions.where((tx) {
      final matchesQuery = _searchQuery.isEmpty ||
          tx.note.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterType == 'Semua' ||
          (_filterType == 'Pemasukan' && !tx.isExpense) ||
          (_filterType == 'Pengeluaran' && tx.isExpense);
      return matchesQuery && matchesFilter;
    }).toList();
  }

  // --- Load Data Pipeline ---

  Future<void> loadAllData() async {
    // Guard: prefs must be initialized before loading
    if (_prefs == null) return;

    try {
      _allProfiles = await _db.getAllProfiles();

      // 1. Determine active profile
      final savedId = _prefs!.getInt('active_profile_id');
      if (savedId != null && _allProfiles.any((p) => p.id == savedId)) {
        _activeProfile = _allProfiles.firstWhere((p) => p.id == savedId);
      } else if (_allProfiles.isNotEmpty) {
        _activeProfile = _allProfiles.first;
        await _prefs!.setInt('active_profile_id', _activeProfile!.id!);
      } else {
        _activeProfile = null;
      }

      // Reset onboarding if there are no profiles in DB (destructive reset safety)
      if (_allProfiles.isEmpty && _hasCompletedOnboarding) {
        _hasCompletedOnboarding = false;
        await _prefs!.setBool('has_completed_onboarding_v5', false);
      }

      // 2. Fetch specific month information if profile is active
      if (_activeProfile != null) {
        _currentBudget = await _db.getBudgetForMonth(_selectedMonth, _activeProfile!.id!);
        _currentTransactions = await _db.getTransactionsForMonth(_selectedMonth, _activeProfile!.id!);
      } else {
        _currentBudget = null;
        _currentTransactions = [];
      }

      notifyListeners();
      WidgetHelper.triggerUpdate();
    } catch (e) {
      debugPrint('[BudgetProvider] loadAllData error: $e');
    }
  }

  // --- Setters with notify ---

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> selectMonth(String month) async {
    _selectedMonth = month;
    if (_activeProfile != null) {
      try {
        _currentBudget = await _db.getBudgetForMonth(_selectedMonth, _activeProfile!.id!);
        _currentTransactions = await _db.getTransactionsForMonth(_selectedMonth, _activeProfile!.id!);
      } catch (e) {
        debugPrint('[BudgetProvider] selectMonth error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> selectProfile(int id) async {
    await _prefs?.setInt('active_profile_id', id);
    await loadAllData();
  }

  // --- DB Mutators ---

  Future<void> createProfile(String name, String emoji, String flavor) async {
    try {
      final profile = Profile(
        name: name,
        emoji: emoji,
        themeFlavor: flavor,
        themeMode: 'Sistem',
      );
      final newId = await _db.insertProfile(profile);
      await _prefs?.setBool('has_completed_onboarding_v5', true);
      _hasCompletedOnboarding = true;
      await selectProfile(newId);
    } catch (e) {
      debugPrint('[BudgetProvider] createProfile error: $e');
    }
  }

  Future<void> updateProfile(int id, String name, String emoji, String flavor, String themeMode) async {
    try {
      final profile = Profile(
        id: id,
        name: name,
        emoji: emoji,
        themeFlavor: flavor,
        themeMode: themeMode,
      );
      await _db.updateProfile(profile);
      await loadAllData();
    } catch (e) {
      debugPrint('[BudgetProvider] updateProfile error: $e');
    }
  }

  Future<void> deleteProfile(int id) async {
    try {
      await _db.deleteProfile(id);
      if (_activeProfile?.id == id) {
        await _prefs?.remove('active_profile_id');
      }
      await loadAllData();
    } catch (e) {
      debugPrint('[BudgetProvider] deleteProfile error: $e');
    }
  }

  Future<void> saveBudget(double amount) async {
    if (_activeProfile == null) return;
    try {
      final budget = MonthlyBudget(
        month: _selectedMonth,
        profileId: _activeProfile!.id!,
        targetAmount: amount,
      );
      await _db.insertBudget(budget);
      await loadAllData();
    } catch (e) {
      debugPrint('[BudgetProvider] saveBudget error: $e');
    }
  }

  Future<void> resetCurrentMonth() async {
    if (_activeProfile == null) return;
    try {
      await _db.resetMonth(_selectedMonth, _activeProfile!.id!);
      await loadAllData();
    } catch (e) {
      debugPrint('[BudgetProvider] resetCurrentMonth error: $e');
    }
  }

  Future<void> addTransaction({required double amount, required String note, required bool isExpense}) async {
    if (_activeProfile == null) return;
    try {
      final finalNote = note.trim().isEmpty ? "Lainnya" : note.trim();
      final tx = Transaction(
        month: _selectedMonth,
        profileId: _activeProfile!.id!,
        amount: amount,
        isExpense: isExpense,
        note: finalNote,
        timestamp: _calculateTimestamp(),
      );
      await _db.insertTransaction(tx);
      await loadAllData();
      
      // Silently log transaction success event to Firebase Analytics
      await AnalyticsHelper.logTransactionSuccess(
        amount: amount,
        note: finalNote,
        isExpense: isExpense,
        category: finalNote.contains('|') ? finalNote.split('|').last.trim() : finalNote,
      );
    } catch (e) {
      debugPrint('[BudgetProvider] addTransaction error: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _db.deleteTransaction(id);
      await loadAllData();
    } catch (e) {
      debugPrint('[BudgetProvider] deleteTransaction error: $e');
    }
  }

  int _calculateTimestamp() {
    final currentMonth = _getCurrentMonthString();
    if (_selectedMonth == currentMonth) {
      return DateTime.now().millisecondsSinceEpoch;
    } else {
      // For past months: generate a timestamp somewhere in the middle of that month
      // to avoid all entries having identical timestamps, which breaks ordering
      try {
        final parsed = DateFormat('yyyy-MM').parse(_selectedMonth);
        final daysInMonth = DateTime(parsed.year, parsed.month + 1, 0).day;
        final randomDay = (DateTime.now().millisecondsSinceEpoch % daysInMonth) + 1;
        final midMonthDate = DateTime(parsed.year, parsed.month, randomDay, 12, 0);
        return midMonthDate.millisecondsSinceEpoch;
      } catch (_) {
        return DateTime.now().millisecondsSinceEpoch;
      }
    }
  }

  Future<void> addCustomTag(String label, String value) async {
    try {
      _customTags.add({"label": label, "value": value});
      final listToSave = _customTags.map((t) => "${t['label']}|${t['value']}").toList();
      await _prefs?.setStringList('custom_tags_v1', listToSave);
      notifyListeners();
    } catch (e) {
      debugPrint('[BudgetProvider] addCustomTag error: $e');
    }
  }

  Future<void> removeCustomTag(int index) async {
    if (index >= 0 && index < _customTags.length) {
      try {
        _customTags.removeAt(index);
        final listToSave = _customTags.map((t) => "${t['label']}|${t['value']}").toList();
        await _prefs?.setStringList('custom_tags_v1', listToSave);
        notifyListeners();
      } catch (e) {
        debugPrint('[BudgetProvider] removeCustomTag error: $e');
      }
    }
  }
}
