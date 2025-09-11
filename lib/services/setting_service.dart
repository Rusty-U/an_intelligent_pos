// settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _shopNameKey = 'shop_name';
  static const _cashierNameKey = 'cashier_name';
  static const _lastReceiptNoKey = 'last_receipt_no';

  // Shop Name
  static Future<String> getShopName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shopNameKey) ?? "An Intelligent POS";
  }

  static Future<void> setShopName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shopNameKey, name);
  }

  // Cashier Name
  static Future<String> getCashierName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cashierNameKey) ?? "Cashier";
  }

  static Future<void> setCashierName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cashierNameKey, name);
  }

  // Last Receipt No
  static Future<int> getLastReceiptNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastReceiptNoKey) ?? 0;
  }

  static Future<void> setLastReceiptNo(int no) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReceiptNoKey, no);
  }

  // ✅ Utility Function: Generate Receipt Number
  static Future<String> generateReceiptNo() async {
    final cashierName = await getCashierName();
    final lastNo = await getLastReceiptNo();
    int newNo = lastNo + 1;

    // Cashier initials (first letters of first two words)
    final parts = cashierName.split(' ');
    String initials = '';
    if (parts.length >= 2) {
      initials = parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    } else if (parts.isNotEmpty) {
      initials = parts[0][0].toUpperCase();
    } else {
      initials = 'CS'; // Default
    }

    await setLastReceiptNo(newNo);
    return "$initials-$newNo";
  }
}
