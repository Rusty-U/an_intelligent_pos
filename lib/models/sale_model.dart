class SaleModel {
  String? id; // Firestore doc id (optional)
  String itemName;
  int quantity;
  int price;
  DateTime date;

  SaleModel({
    this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String(),
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      price: (map['price'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  factory SaleModel.fromFirestore(Map<String, dynamic> map, String id) {
    return SaleModel(
      id: id,
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      price: (map['price'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}
