import 'package:flutter/material.dart';

class ShopProvider extends ChangeNotifier {
  String _shopName = "My Shop";
  String _currency = "PKR";

  String get shopName => _shopName;
  String get currency => _currency;

  void updateShopName(String name) {
    _shopName = name;
    notifyListeners();
  }

  void updateCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }
}
