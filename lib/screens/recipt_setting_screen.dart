import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ------------------ Receipt Settings Screen ------------------
class ReceiptSettingsScreen extends StatefulWidget {
  const ReceiptSettingsScreen({super.key});

  @override
  State<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends State<ReceiptSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _headerNoteController = TextEditingController();
  final TextEditingController _footerNoteController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  final CollectionReference settingsRef =
      FirebaseFirestore.instance.collection('receiptSettings');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final snapshot = await settingsRef.doc('default').get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      _shopNameController.text = data['shopName'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _headerNoteController.text = data['headerNote'] ?? '';
      _footerNoteController.text = data['footerNote'] ?? '';
      _logoUrlController.text = data['logoUrl'] ?? '';
      _taxController.text = data['tax'] ?? '';
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      await settingsRef.doc('default').set({
        'shopName': _shopNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'headerNote': _headerNoteController.text,
        'footerNote': _footerNoteController.text,
        'logoUrl': _logoUrlController.text,
        'tax': _taxController.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _headerNoteController,
                decoration: const InputDecoration(labelText: 'Header Note'),
              ),
              TextFormField(
                controller: _footerNoteController,
                decoration: const InputDecoration(labelText: 'Footer Note'),
              ),
              TextFormField(
                controller: _logoUrlController,
                decoration: const InputDecoration(labelText: 'Logo URL'),
              ),
              TextFormField(
                controller: _taxController,
                decoration: const InputDecoration(labelText: 'GST/Tax ID'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
