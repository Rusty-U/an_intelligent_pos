import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const ItemTile({super.key, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(title: Text(title), subtitle: Text(subtitle), onTap: onTap),
    );
  }
}
