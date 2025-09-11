import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      return ListTile(
                        title: Text(item.name),
                        subtitle:
                            Text("Rs. ${item.sellingPrice} x ${item.quantity}"),
                        trailing:
                            Text("Rs. ${item.sellingPrice * item.quantity}"),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Total: Rs. ${cart.totalPrice}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Payment Successful! Total: Rs. ${cart.totalPrice}")),
                    );
                    cart.clearCart();
                    Navigator.pop(context);
                  },
                  child: const Text("Confirm & Pay"),
                ),
              ],
            ),
    );
  }
}
