import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class InventoryFirestore {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('inventory');

  /// Add or Update item
  Future<void> add(ItemModel item) async {
    await _collection.doc(item.id).set(item.toFirestore());
  }

  /// Stream all items
  Stream<List<ItemModel>> stream() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  /// Stream items by category
  Stream<List<ItemModel>> streamByCategory(String categoryId) {
    return _collection
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Delete item
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
