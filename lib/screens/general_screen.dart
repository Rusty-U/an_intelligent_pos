import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/shop_provider.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    final shopController = TextEditingController(text: shopProvider.shopName);
    final currencyController =
        TextEditingController(text: shopProvider.currency);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Shop Name
            TextField(
              controller: shopController,
              decoration: const InputDecoration(
                labelText: "Shop Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // ✅ Currency
            TextField(
              controller: currencyController,
              decoration: const InputDecoration(
                labelText: "Currency",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            // ✅ Dark Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode", style: TextStyle(fontSize: 18)),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (val) {
                    themeProvider.toggleTheme(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Save shop details
                shopProvider.updateShopName(shopController.text.trim());
                shopProvider.updateCurrency(currencyController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings saved!")),
                );
              },
              child: const Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
