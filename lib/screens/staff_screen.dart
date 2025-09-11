import 'package:flutter/material.dart';
import '../db/staff_firestore.dart';
import '../models/staff_model.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  Future<void> _addStaffDialog() async {
    final name = TextEditingController();
    final role = TextEditingController();
    await showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Add Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: role, decoration: const InputDecoration(labelText: 'Role')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final s = StaffModel(name: name.text.trim(), role: role.text.trim());
              await StaffFirestore.add(s);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: StreamBuilder<List<StaffModel>>(
        stream: StaffFirestore.stream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final staff = snapshot.data ?? <StaffModel>[];
          if (staff.isEmpty) return const Center(child: Text('No staff'));
          return ListView.builder(
            itemCount: staff.length,
            itemBuilder: (_, i) {
              final d = staff[i];
              return Card(
                child: ListTile(
                  title: Text(d.name),
                  subtitle: Text(d.role),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      if (d.id != null) await StaffFirestore.delete(d.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStaffDialog,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
