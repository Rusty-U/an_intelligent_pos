class StaffModel {
  String? id;
  String name;
  String role;

  StaffModel({this.id, required this.name, required this.role});

  Map<String, dynamic> toMap() => {'name': name, 'role': role};

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      name: map['name'] ?? '',
      role: map['role'] ?? 'staff',
    );
  }

  factory StaffModel.fromFirestore(Map<String, dynamic> map, String id) {
    return StaffModel(id: id, name: map['name'] ?? '', role: map['role'] ?? 'staff');
  }
}
