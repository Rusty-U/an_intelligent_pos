import 'package:flutter/material.dart';
import '../screens/recipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.cart,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _receivedController = TextEditingController();
  double receivedAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    double change = receivedAmount - widget.totalAmount;
    bool isPaymentValid = receivedAmount >= widget.totalAmount;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Bill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Bill:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.totalAmount.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 20),

            // Received Amount
            TextField(
              controller: _receivedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Received Amount",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  receivedAmount = double.tryParse(val) ?? 0.0;
                });
              },
            ),

            const SizedBox(height: 20),

            // Change
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Change:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(change >= 0 ? change.toStringAsFixed(2) : "0.00",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),

            const SizedBox(height: 20),

            // Warning agar amount kam hai
            if (!isPaymentValid)
              const Text(
                "⚠️ Received amount is less than total bill!",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            const Spacer(),

            // Done Button
            ElevatedButton(
              onPressed: isPaymentValid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(
                            cart: widget.cart,
                            cashReceived: receivedAmount,
                            totalAmount: widget.totalAmount,
                            change: change,
                          ),
                        ),
                      );
                    }
                  : null, // disable agar amount kam ho
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child: const Text("Done", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
