import 'package:flutter/material.dart';
import '../screens/category_screen.dart'; // ✅ Categories ka screen (alag file)

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        centerTitle: true,
      ),
      body:
          const CategoryScreen(), // ✅ yahan tumhari categories wali file load ho rahi hai
    );
  }
}
