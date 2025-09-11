import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';

class SaleFirestore {
  static final _col = FirebaseFirestore.instance.collection('sales');

  static Future<void> add(SaleModel sale) async {
    await _col.add(sale.toMap());
  }

  static Stream<List<SaleModel>> stream() {
    return _col.orderBy('date', descending: true).snapshots().map((s) =>
      s.docs.map((d) => SaleModel.fromFirestore(d.data(), d.id)).toList());
  }

  static Future<void> delete(String id) => _col.doc(id).delete();
}
