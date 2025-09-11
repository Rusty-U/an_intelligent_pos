import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/payment_screen.dart';

class CounterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CounterScreen({super.key, required this.cart});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  bool _isLoading = false; // 🟢 Loading state

  double get totalAmount {
    double total = 0;
    for (var item in widget.cart) {
      total += (item['qty'] ?? 0) * (item['sellingPrice'] ?? 0);
    }
    return total;
  }

  // ✅ Save Sale Record in Firestore
  Future<void> _saveSaleRecord() async {
    final saleDoc =
        FirebaseFirestore.instance.collection('sales').doc(); // new sale doc

    await saleDoc.set({
      'items': widget.cart,
      'total': totalAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Update Stock in Inventory
  Future<void> _updateStockAfterSale() async {
    for (var item in widget.cart) {
      String itemId = item['id'];
      int soldQty = item['qty'];

      DocumentReference docRef =
          FirebaseFirestore.instance.collection('inventory').doc(itemId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Item does not exist!");
        }

        int currentStock = snapshot['stock'] ?? 0;
        int newStock = currentStock - soldQty;

        if (newStock < 0) {
          newStock = 0;
        }

        transaction.update(docRef, {'stock': newStock});
      });
    }
  }

  // ✅ Proceed to Payment
  void _proceedToPayment() async {
    setState(() {
      _isLoading = true; // 🟢 loading shuru
    });

    try {
      await _saveSaleRecord(); // Sale record save
      await _updateStockAfterSale(); // Stock update

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              cart: widget.cart,
              totalAmount: totalAmount,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 🟢 loading khatam
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Counter Screen")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                var item = widget.cart[index];
                return Card(
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      "Qty: ${item['qty']} × ${item['sellingPrice']} = ${(item['qty'] * item['sellingPrice']).toString()}",
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  totalAmount.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const CircularProgressIndicator() // 🟢 Loading show karega
              : ElevatedButton(
                  onPressed: _proceedToPayment,
                  child: const Text("Proceed to Payment"),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
