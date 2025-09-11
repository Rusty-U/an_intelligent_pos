import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemScreen extends StatelessWidget {
  final String categoryId;
  const ItemScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(categoryId: categoryId),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("inventory")
            .where("categoryId", isEqualTo: categoryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No items found"));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                    "Cost: ${item['costPrice']} | Selling: ${item['sellingPrice']} | Stock: ${item['stock']} | Barcode: ${item['barcode'] ?? 'N/A'}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Item"),
                          content: Text(
                              "Are you sure you want to delete '${item['name']}'?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await FirebaseFirestore.instance
                              .collection("inventory")
                              .doc(item.id)
                              .delete();
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error deleting item: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditItemScreen(
                          itemId: item.id,
                          data: item.data() as Map<String, dynamic>,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final String categoryId;
  const AddItemScreen({super.key, required this.categoryId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  String generateBarcode() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> addItem() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Item name cannot be empty"),
            backgroundColor: Colors.red),
      );
      return;
    }

    String barcode = barcodeController.text.isEmpty
        ? generateBarcode()
        : barcodeController.text;

    try {
      await FirebaseFirestore.instance.collection("inventory").add({
        "name": nameController.text.trim(),
        "costPrice": double.tryParse(costPriceController.text) ?? 0,
        "sellingPrice": double.tryParse(sellingPriceController.text) ?? 0,
        "stock": int.tryParse(stockController.text) ?? 0,
        "barcode": barcode,
        "categoryId": widget.categoryId,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error adding item: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Item Name")),
              const SizedBox(height: 10),
              TextField(
                controller: costPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cost Price"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Selling Price"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  labelText: "Barcode (leave empty for auto-generate)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: addItem, child: const Text("Add Item")),
            ],
          ),
        ),
      ),
    );
  }
}

class EditItemScreen extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> data;
  const EditItemScreen({super.key, required this.itemId, required this.data});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController nameController;
  late TextEditingController costPriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController stockController;
  late TextEditingController barcodeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    costPriceController =
        TextEditingController(text: widget.data['costPrice'].toString());
    sellingPriceController =
        TextEditingController(text: widget.data['sellingPrice'].toString());
    stockController =
        TextEditingController(text: widget.data['stock'].toString());
    barcodeController =
        TextEditingController(text: widget.data['barcode'] ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    costPriceController.dispose();
    sellingPriceController.dispose();
    stockController.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  Future<void> updateItem() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Item name cannot be empty"),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("inventory")
          .doc(widget.itemId)
          .update({
        "name": nameController.text.trim(),
        "costPrice": double.tryParse(costPriceController.text) ?? 0,
        "sellingPrice": double.tryParse(sellingPriceController.text) ?? 0,
        "stock": int.tryParse(stockController.text) ?? 0,
        "barcode": barcodeController.text.isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : barcodeController.text,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error updating item: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Item Name")),
            const SizedBox(height: 10),
            TextField(
                controller: costPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cost Price")),
            const SizedBox(height: 10),
            TextField(
                controller: sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Selling Price")),
            const SizedBox(height: 10),
            TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock")),
            const SizedBox(height: 10),
            TextField(
                controller: barcodeController,
                decoration: const InputDecoration(labelText: "Barcode")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: updateItem, child: const Text("Update")),
          ],
        ),
      ),
    );
  }
}
