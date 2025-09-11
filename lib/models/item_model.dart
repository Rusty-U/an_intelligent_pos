class ItemModel {
  String id; // Firestore document ID
  String categoryId; // jis category me ye item belong karta hai
  String name; // item ka naam
  double costPrice; // item ka kharidne ka rate
  double sellingPrice; // item ka bechne ka rate
  int quantity; // stock available
  String? barcode; // optional

  ItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    this.barcode,
  });

  /// Convert ItemModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'barcode': barcode,
    };
  }

  /// Create ItemModel from Firestore document
  factory ItemModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return ItemModel(
      id: docId,
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      barcode: map['barcode'],
    );
  }
}
