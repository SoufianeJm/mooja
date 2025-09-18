import 'package:flutter/foundation.dart';
import '../state/state_validator.dart';

/// Debug utilities for monitoring app state and navigation
class AppDebug {
  /// Print current app state for debugging
  static Future<void> printCurrentState() async {
    if (!kDebugMode) return;

    print('=== APP STATE DEBUG ===');
    final state = await StateValidator.getStateSummary();
    state.forEach((key, value) {
      print('$key: $value');
    });
    print('=======================');
  }

  /// Validate state and print results
  static Future<void> validateAndPrint() async {
    if (!kDebugMode) return;

    print('=== STATE VALIDATION ===');
    final isValid = await StateValidator.isValid();
    print('State is valid: $isValid');

    if (!isValid) {
      print('State is invalid, attempting recovery...');
      await StateValidator.recover();
      print('Recovery completed');
    }
    print('========================');
  }

  /// Print navigation guard info
  static void printNavigationInfo(String from, String to, String reason) {
    if (!kDebugMode) return;

    print('=== NAVIGATION DEBUG ===');
    print('From: $from');
    print('To: $to');
    print('Reason: $reason');
    print('========================');
  }
}
