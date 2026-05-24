import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static bool _isInitialized = false;
  static FirebaseAnalytics? _analytics;

  /// Initializes Firebase Core silently and safely.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _isInitialized = true;
      debugPrint("Firebase Analytics initialized successfully and silently. ☁️");
    } catch (e) {
      debugPrint("Firebase core initialization failed (silently caught): $e");
    }
  }

  /// Logs the standard 'app_open' event silently.
  static Future<void> logAppOpen() async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logAppOpen();
      debugPrint("Firebase Event logged: app_open 📥");
    } catch (e) {
      debugPrint("Silent Firebase logAppOpen error: $e");
    }
  }

  /// Logs custom transaction_success event silently.
  static Future<void> logTransactionSuccess({
    required double amount,
    required String note,
    required bool isExpense,
    required String category,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'transaction_success',
        parameters: {
          'amount': amount,
          'note': note,
          'type': isExpense ? 'expense' : 'income',
          'category': category,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint("Firebase Custom Event logged: transaction_success 💰");
    } catch (e) {
      debugPrint("Silent Firebase logTransactionSuccess error: $e");
    }
  }
}
