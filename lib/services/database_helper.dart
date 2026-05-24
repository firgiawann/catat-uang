import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/profile.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as app;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dompet_pintar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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

  // --- Profiles Operations ---

  Future<List<Profile>> getAllProfiles() async {
    final db = await instance.database;
    final result = await db.query('profiles');
    return result.map((json) => Profile.fromMap(json)).toList();
  }

  Future<int> insertProfile(Profile profile) async {
    final db = await instance.database;
    return await db.insert(
      'profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await instance.database;
    return await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    final db = await instance.database;
    // Cascade manually
    await db.delete('monthly_budgets', where: 'profileId = ?', whereArgs: [id]);
    await db.delete('transactions', where: 'profileId = ?', whereArgs: [id]);
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  // --- Budgets Operations ---

  Future<MonthlyBudget?> getBudgetForMonth(String month, int profileId) async {
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

  Future<int> insertBudget(MonthlyBudget budget) async {
    final db = await instance.database;
    return await db.insert(
      'monthly_budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Transactions Operations ---

  Future<List<app.Transaction>> getTransactionsForMonth(String month, int profileId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'month = ? AND profileId = ?',
      whereArgs: [month, profileId],
      orderBy: 'timestamp DESC',
    );
    return result.map((json) => app.Transaction.fromMap(json)).toList();
  }

  Future<int> insertTransaction(app.Transaction tx) async {
    final db = await instance.database;
    return await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> resetMonth(String month, int profileId) async {
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

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
