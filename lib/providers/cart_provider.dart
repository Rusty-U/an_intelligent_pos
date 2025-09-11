import 'package:flutter/foundation.dart';
import '../models/item_model.dart';

class CartProvider with ChangeNotifier {
  final List<ItemModel> _items = [];

  List<ItemModel> get items => _items;

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += item.sellingPrice * item.quantity;
    }
    return total;
  }

  void addItem(ItemModel newItem) {
    // Agar item already cart me hai to quantity increase karo
    final index = _items.indexWhere((item) => item.id == newItem.id);
    if (index >= 0) {
      _items[index].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
