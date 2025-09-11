import 'package:flutter/material.dart';

class SaleBottomSheet extends StatelessWidget {
  final Widget child;
  const SaleBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: child,
    );
  }
}
