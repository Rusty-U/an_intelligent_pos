import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_model.dart';

class StaffFirestore {
  static final _col = FirebaseFirestore.instance.collection('staff');

  static Future<void> add(StaffModel staff) async {
    await _col.add(staff.toMap());
  }

  static Stream<List<StaffModel>> stream() {
    return _col.orderBy('name').snapshots().map((s) =>
      s.docs.map((d) => StaffModel.fromFirestore(d.data(), d.id)).toList());
  }

  static Future<void> delete(String id) => _col.doc(id).delete();
}
