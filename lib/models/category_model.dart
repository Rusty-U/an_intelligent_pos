class CategoryModel {
  String? id; // Firestore document ID
  String name; // Category name (e.g. "Beverages")
  String? description; // Optional description
  String? imageUrl; // Category image (optional)

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  /// Convert CategoryModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }
}
