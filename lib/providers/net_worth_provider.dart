import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetWorthProvider with ChangeNotifier {
  double _totalNetWorth = 0.0;

  double get totalNetWorth => _totalNetWorth;

  Future<void> loadTotalNetWorth() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accountList = prefs.getStringList('accounts') ?? [];
    _totalNetWorth = accountList.fold(0.0, (total, account) {
      final data = account.split(',');
      return total + double.parse(data[1]);
    });
    notifyListeners(); // Notify listeners to update UI
  }

  Future<void> updateNetWorth(double amount) async {
    _totalNetWorth += amount;
    notifyListeners(); // Notify listeners to update UI
    // Optionally, save to local storage if needed
  }
}
