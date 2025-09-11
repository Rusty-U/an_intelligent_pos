import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Shop Info'),
            subtitle: Text('Name, Address, Contact'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('Blue/White (locked)'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Intelligent POS v1.0.0'),
          ),
        ],
      ),
    );
  }
}
