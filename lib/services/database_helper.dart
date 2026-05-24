import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path_helper;
import '../models/profile.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as app;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sql.Database? _database;

  DatabaseHelper._init();

  Future<sql.Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError("SQLite is not supported on web. Use SharedPreferences fallback.");
    }
    if (_database != null) return _database!;
    _database = await _initDB('dompet_pintar.db');
    return _database!;
  }

  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final fullPath = path_helper.join(dbPath, filePath);

    return await sql.openDatabase(
      fullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        themeFlavor TEXT NOT NULL,
        themeMode TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE monthly_budgets (
        month TEXT NOT NULL,
        profileId INTEGER NOT NULL,
        targetAmount REAL NOT NULL,
        PRIMARY KEY (month, profileId)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        profileId INTEGER NOT NULL,
        amount REAL NOT NULL,
        isExpense INTEGER NOT NULL,
        note TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  // --- Web Helper Fallbacks ---

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // --- Profiles Operations ---

  Future<List<Profile>> getAllProfiles() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final data = prefs.getString('web_profiles') ?? '[]';
      final List decoded = json.decode(data);
      return decoded.map((json) => Profile.fromMap(json)).toList();
    } else {
      final db = await instance.database;
      final result = await db.query('profiles');
      return result.map((json) => Profile.fromMap(json)).toList();
    }
  }

  Future<int> insertProfile(Profile profile) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final list = await getAllProfiles();
      
      int nextId = 1;
      if (list.isNotEmpty) {
        nextId = list.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      }
      
      final newProfile = Profile(
        id: profile.id ?? nextId,
        name: profile.name,
        emoji: profile.emoji,
        themeFlavor: profile.themeFlavor,
        themeMode: profile.themeMode,
      );
      
      list.removeWhere((p) => p.id == newProfile.id);
      list.add(newProfile);
      
      final data = json.encode(list.map((p) => p.toMap()).toList());
      await prefs.setString('web_profiles', data);
      return newProfile.id!;
    } else {
      final db = await instance.database;
      return await db.insert(
        'profiles',
        profile.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> updateProfile(Profile profile) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final list = await getAllProfiles();
      list.removeWhere((p) => p.id == profile.id);
      list.add(profile);
      
      final data = json.encode(list.map((p) => p.toMap()).toList());
      await prefs.setString('web_profiles', data);
      return 1;
    } else {
      final db = await instance.database;
      return await db.update(
        'profiles',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
    }
  }

  Future<int> deleteProfile(int id) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      
      // Profiles
      final profiles = await getAllProfiles();
      profiles.removeWhere((p) => p.id == id);
      await prefs.setString('web_profiles', json.encode(profiles.map((p) => p.toMap()).toList()));
      
      // Cascade manual: Budgets
      final budgetsData = prefs.getString('web_budgets') ?? '[]';
      final List decodedBudgets = json.decode(budgetsData);
      decodedBudgets.removeWhere((b) => b['profileId'] == id);
      await prefs.setString('web_budgets', json.encode(decodedBudgets));
      
      // Cascade manual: Transactions
      final txData = prefs.getString('web_transactions') ?? '[]';
      final List decodedTx = json.decode(txData);
      decodedTx.removeWhere((tx) => tx['profileId'] == id);
      await prefs.setString('web_transactions', json.encode(decodedTx));
      
      return 1;
    } else {
      final db = await instance.database;
      await db.delete('monthly_budgets', where: 'profileId = ?', whereArgs: [id]);
      await db.delete('transactions', where: 'profileId = ?', whereArgs: [id]);
      return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    }
  }

  // --- Budgets Operations ---

  Future<MonthlyBudget?> getBudgetForMonth(String month, int profileId) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final data = prefs.getString('web_budgets') ?? '[]';
      final List decoded = json.decode(data);
      final list = decoded.map((json) => MonthlyBudget.fromMap(json)).toList();
      
      for (final budget in list) {
        if (budget.month == month && budget.profileId == profileId) {
          return budget;
        }
      }
      return null;
    } else {
      final db = await instance.database;
      final result = await db.query(
        'monthly_budgets',
        where: 'month = ? AND profileId = ?',
        whereArgs: [month, profileId],
      );
      if (result.isNotEmpty) {
        return MonthlyBudget.fromMap(result.first);
      }
      return null;
    }
  }

  Future<int> insertBudget(MonthlyBudget budget) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final data = prefs.getString('web_budgets') ?? '[]';
      final List decoded = json.decode(data);
      final list = decoded.map((json) => MonthlyBudget.fromMap(json)).toList();
      
      list.removeWhere((b) => b.month == budget.month && b.profileId == budget.profileId);
      list.add(budget);
      
      await prefs.setString('web_budgets', json.encode(list.map((b) => b.toMap()).toList()));
      return 1;
    } else {
      final db = await instance.database;
      return await db.insert(
        'monthly_budgets',
        budget.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    }
  }

  // --- Transactions Operations ---

  Future<List<app.Transaction>> getTransactionsForMonth(String month, int profileId) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final data = prefs.getString('web_transactions') ?? '[]';
      final List decoded = json.decode(data);
      final list = decoded.map((json) => app.Transaction.fromMap(json)).toList();
      
      final filtered = list.where((tx) => tx.month == month && tx.profileId == profileId).toList();
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filtered;
    } else {
      final db = await instance.database;
      final result = await db.query(
        'transactions',
        where: 'month = ? AND profileId = ?',
        whereArgs: [month, profileId],
        orderBy: 'timestamp DESC',
      );
      return result.map((json) => app.Transaction.fromMap(json)).toList();
    }
  }

  Future<int> insertTransaction(app.Transaction tx) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final data = prefs.getString('web_transactions') ?? '[]';
      final List decoded = json.decode(data);
      final list = decoded.map((json) => app.Transaction.fromMap(json)).toList();
      
      int nextId = 1;
      if (list.isNotEmpty) {
        nextId = list.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      }
      
      final newTx = app.Transaction(
        id: tx.id ?? nextId,
        month: tx.month,
        profileId: tx.profileId,
        amount: tx.amount,
        isExpense: tx.isExpense,
        note: tx.note,
        timestamp: tx.timestamp,
      );
      
      list.removeWhere((t) => t.id == newTx.id);
      list.add(newTx);
      
      await prefs.setString('web_transactions', json.encode(list.map((t) => t.toMap()).toList()));
      return newTx.id!;
    } else {
      final db = await instance.database;
      return await db.insert(
        'transactions',
        tx.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final data = prefs.getString('web_transactions') ?? '[]';
      final List decoded = json.decode(data);
      final list = decoded.map((json) => app.Transaction.fromMap(json)).toList();
      
      list.removeWhere((t) => t.id == id);
      await prefs.setString('web_transactions', json.encode(list.map((t) => t.toMap()).toList()));
      return 1;
    } else {
      final db = await instance.database;
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> resetMonth(String month, int profileId) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      
      // Transactions
      final txData = prefs.getString('web_transactions') ?? '[]';
      final List decodedTx = json.decode(txData);
      final txs = decodedTx.map((json) => app.Transaction.fromMap(json)).toList();
      txs.removeWhere((tx) => tx.month == month && tx.profileId == profileId);
      await prefs.setString('web_transactions', json.encode(txs.map((t) => t.toMap()).toList()));
      
      // Budgets
      final budgetsData = prefs.getString('web_budgets') ?? '[]';
      final List decodedBudgets = json.decode(budgetsData);
      final budgets = decodedBudgets.map((json) => MonthlyBudget.fromMap(json)).toList();
      budgets.removeWhere((b) => b.month == month && b.profileId == profileId);
      await prefs.setString('web_budgets', json.encode(budgets.map((b) => b.toMap()).toList()));
    } else {
      final db = await instance.database;
      await db.delete(
        'transactions',
        where: 'month = ? AND profileId = ?',
        whereArgs: [month, profileId],
      );
      await db.delete(
        'monthly_budgets',
        where: 'month = ? AND profileId = ?',
        whereArgs: [month, profileId],
      );
    }
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
