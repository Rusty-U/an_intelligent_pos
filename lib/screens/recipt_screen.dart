import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'home_screen.dart';
import 'today_screen.dart';

class ReceiptScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final double cashReceived;
  final double totalAmount;
  final double change;
  final bool readOnly;

  ReceiptScreen({
    super.key,
    required this.cart,
    required this.cashReceived,
    required this.totalAmount,
    required this.change,
    this.readOnly = false,
  });

  // Thermal printer instance
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSettingsAndReceipt(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!;
        final shopName = data['shopName'] ?? '';
        final cashierName = data['cashierName'] ?? '';
        final receiptNo = data['receiptNo'] ?? '';
        final headerNote = data['headerNote'] ?? '';
        final footerNote = data['footerNote'] ?? '';
        final address = data['address'] ?? '';
        final phone = data['phone'] ?? '';
        final tax = data['tax'] ?? '';
        final logoUrl = data['logoUrl'] ?? '';

        String dateStr =
            DateFormat('dd MMM yyyy - hh:mm a').format(DateTime.now());

        bool isPaymentValid = cashReceived >= totalAmount;

        return Scaffold(
          appBar: AppBar(title: const Text('Receipt')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ----------- HEADER -------------
                Center(
                  child: Column(
                    children: [
                      if (logoUrl.isNotEmpty)
                        Image.network(logoUrl, height: 60, fit: BoxFit.contain),
                      Text(shopName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if (address.isNotEmpty) Text(address),
                      if (phone.isNotEmpty) Text('Phone: $phone'),
                      if (tax.isNotEmpty) Text('GST: $tax'),
                      if (headerNote.isNotEmpty) Text(headerNote),
                      const Divider(thickness: 1),
                      Text('Receipt# $receiptNo'),
                      Text('Date: $dateStr'),
                      Text('By: $cashierName'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ----------- TABLE HEADER ----------
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: Text('Item')),
                      Expanded(flex: 2, child: Text('Qty')),
                      Expanded(flex: 2, child: Text('Price')),
                      Expanded(flex: 2, child: Text('Total')),
                    ],
                  ),
                ),
                const Divider(thickness: 1),

                // ----------- CART ITEMS ----------
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final itemName = item['name'] ?? '';
                      final itemQty = item['qty'] ?? 0;
                      final itemPrice = item['sellingPrice'] ?? 0.0;
                      final itemTotal = itemQty * itemPrice;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text(itemName)),
                            Expanded(flex: 2, child: Text('$itemQty')),
                            Expanded(
                                flex: 2,
                                child: Text(itemPrice.toStringAsFixed(2))),
                            Expanded(
                                flex: 2,
                                child: Text(itemTotal.toStringAsFixed(2))),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Divider(thickness: 1),

                // ----------- SUMMARY ------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(totalAmount.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cash Received:'),
                    Text(cashReceived.toStringAsFixed(2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Change:'),
                    Text(change.toStringAsFixed(2)),
                  ],
                ),

                const SizedBox(height: 16),

                if (!isPaymentValid)
                  const Text(
                    "⚠️ Received amount is less than total bill!",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),

                if (footerNote.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  Text(footerNote),
                ],

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _printReceipt(
                          shopName,
                          cashierName,
                          receiptNo,
                          dateStr,
                          cart,
                          totalAmount,
                          cashReceived,
                          change,
                          headerNote,
                          footerNote),
                      child: const Text('Print'),
                    ),
                    ElevatedButton(
                      onPressed: isPaymentValid
                          ? () async {
                              final receiptData = {
                                'cart': cart,
                                'totalAmount': totalAmount,
                                'cashReceived': cashReceived,
                                'change': change,
                                'date': DateTime.now(),
                                'shopName': shopName,
                                'cashierName': cashierName,
                                'receiptNo': receiptNo,
                                'headerNote': headerNote,
                                'footerNote': footerNote,
                                'address': address,
                                'phone': phone,
                                'tax': tax,
                                'logoUrl': logoUrl,
                              };

                              try {
                                await FirebaseFirestore.instance
                                    .collection('receipts')
                                    .add(receiptData);

                                if (!context.mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error saving receipt: $e')),
                                );
                              }
                            }
                          : null,
                      child: const Text('Done'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        try {
                          final firestore = FirebaseFirestore.instance;

                          // 1. Inventory update (stock wapas add karna)
                          for (var item in cart) {
                            final itemId = item['id'];
                            final qty = item['qty'] ?? 0;

                            if (itemId != null) {
                              final docRef =
                                  firestore.collection('inventory').doc(itemId);
                              final docSnap = await docRef.get();

                              if (docSnap.exists) {
                                final currentStock = docSnap['stock'] ?? 0;
                                await docRef
                                    .update({'stock': currentStock + qty});
                              }
                            }
                          }

                          // 2. Today sale se minus karna
                          final todayDoc = firestore
                              .collection('salesSummary')
                              .doc(DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()));
                          final todaySnap = await todayDoc.get();

                          if (todaySnap.exists) {
                            final currentTotal = todaySnap['totalSales'] ?? 0.0;
                            await todayDoc.update(
                                {'totalSales': currentTotal - totalAmount});
                          }

                          // 3. Receipt delete karna
                          final receipts = await firestore
                              .collection('receipts')
                              .where('receiptNo', isEqualTo: receiptNo)
                              .get();

                          for (var doc in receipts.docs) {
                            await firestore
                                .collection('receipts')
                                .doc(doc.id)
                                .delete();
                          }

                          if (!context.mounted) return;

                          // 🔥 Redirect to TodayScreen instead of HomeScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TodayScreen()),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Return successful, stock updated.")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Return failed: $e")),
                          );
                        }
                      },
                      child: const Text("Return"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// -------- PRINT FUNCTIONALITY ------------
  void _printReceipt(
    String shopName,
    String cashierName,
    String receiptNo,
    String dateStr,
    List<Map<String, dynamic>> cart,
    double totalAmount,
    double cashReceived,
    double change,
    String headerNote,
    String footerNote,
  ) async {
    bool? isConnected = await bluetooth.isConnected;

    if (isConnected!) {
      // agar printer connected nahi hai
      // user ko setting screen me bhejna chahiye
      // ya snackbar show kar dena chahiye
      return;
    }

    bluetooth.printNewLine();
    bluetooth.printCustom(shopName, 3, 1);
    if (headerNote.isNotEmpty) bluetooth.printCustom(headerNote, 1, 1);
    bluetooth.printCustom("Receipt# $receiptNo", 1, 0);
    bluetooth.printCustom("Date: $dateStr", 1, 0);
    bluetooth.printCustom("Cashier: $cashierName", 1, 0);
    bluetooth.printNewLine();

    bluetooth.printLeftRight("Item", "Total", 1);
    bluetooth.printCustom("-----------------------------", 1, 1);

    for (var item in cart) {
      final name = item['name'] ?? '';
      final qty = item['qty'] ?? 0;
      final price = item['sellingPrice'] ?? 0.0;
      final total = qty * price;

      bluetooth.printCustom("$name  x$qty  @${price.toStringAsFixed(2)}", 1, 0);
      bluetooth.printLeftRight("", total.toStringAsFixed(2), 1);
    }

    bluetooth.printCustom("-----------------------------", 1, 1);

    bluetooth.printLeftRight("TOTAL", totalAmount.toStringAsFixed(2), 2);
    bluetooth.printLeftRight("Cash", cashReceived.toStringAsFixed(2), 1);
    bluetooth.printLeftRight("Change", change.toStringAsFixed(2), 1);

    bluetooth.printNewLine();
    if (footerNote.isNotEmpty) bluetooth.printCustom(footerNote, 1, 1);
    bluetooth.printCustom("Thank You!", 2, 1);
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }

  /// -------- SETTINGS FETCHER ------------
  Future<Map<String, dynamic>> _getSettingsAndReceipt() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('receiptSettings')
        .doc('default')
        .get();

    final settingsData = snapshot.exists ? snapshot.data()! : {};

    // Generate receipt number dynamically
    final receiptNo = 'R-${DateTime.now().millisecondsSinceEpoch}';

    return {
      'shopName': settingsData['shopName'] ?? 'An Intelligent POS',
      'cashierName': settingsData['cashierName'] ?? 'Cashier',
      'receiptNo': receiptNo,
      'headerNote': settingsData['headerNote'] ?? '',
      'footerNote': settingsData['footerNote'] ?? '',
      'address': settingsData['address'] ?? '',
      'phone': settingsData['phone'] ?? '',
      'tax': settingsData['tax'] ?? '',
      'logoUrl': settingsData['logoUrl'] ?? '',
    };
  }
}
