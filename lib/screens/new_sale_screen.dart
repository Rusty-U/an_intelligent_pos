import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/counter_screen.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  List<Map<String, dynamic>> cart = [];

  // ✅ Fetch items from inventory based on categoryId
  void openCategory(String categoryId, String categoryName) {
    final itemsRef = FirebaseFirestore.instance
        .collection('inventory')
        .where('categoryId', isEqualTo: categoryId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: itemsRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                "Error fetching items: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No items found."));
                      }

                      final items = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var item = items[index];
                          var itemData = item.data() as Map<String, dynamic>;

                          final name = itemData['name'] ?? 'Unnamed Item';
                          final sellingPrice =
                              (itemData['sellingPrice'] ?? 0).toDouble();
                          final costPrice =
                              (itemData['costPrice'] ?? 0).toDouble();
                          final stock = (itemData['stock'] ?? 0).toInt();
                          final barcode = itemData['barcode'] ?? '';

                          int initialQty = 0;
                          int cartIndex =
                              cart.indexWhere((e) => e['id'] == item.id);
                          if (cartIndex != -1) {
                            initialQty = cart[cartIndex]['qty'];
                          }

                          return ItemTile(
                            itemId: item.id,
                            categoryId: categoryId,
                            cart: cart,
                            initialQty: initialQty,
                            item: {
                              'name': name,
                              'sellingPrice': sellingPrice,
                              'costPrice': costPrice,
                              'stock': stock,
                              'barcode': barcode,
                            },
                            onQtyChanged: (val) {
                              int index =
                                  cart.indexWhere((e) => e['id'] == item.id);
                              if (val > 0) {
                                if (index != -1) {
                                  cart[index]['qty'] = val;
                                } else {
                                  cart.add({
                                    'id': item.id,
                                    'name': name,
                                    'sellingPrice': sellingPrice,
                                    'costPrice': costPrice,
                                    'barcode': barcode,
                                    'qty': val,
                                    'stock': stock,
                                    'categoryId': categoryId,
                                  });
                                }
                              } else if (index != -1) {
                                cart.removeAt(index);
                              }
                              setState(() {});
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Save Sale to Firestore
  Future<void> saveSale() async {
    if (cart.isEmpty) return;

    double total = 0;
    for (var item in cart) {
      total += item['sellingPrice'] * item['qty'];
    }

    final saleDoc =
        FirebaseFirestore.instance.collection('sales').doc(); // new sale doc

    await saleDoc.set({
      'items': cart,
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Update stock for each item
    for (var item in cart) {
      final itemRef =
          FirebaseFirestore.instance.collection('inventory').doc(item['id']);

      await itemRef.update({
        'stock': item['stock'] - item['qty'],
      });
    }

    setState(() {
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Sale saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesRef = FirebaseFirestore.instance.collection('categories');

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoriesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          final categories = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                var cat = categories[index];
                var catData = cat.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () => openCategory(cat.id, catData['name']),
                  child: Card(
                    color: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (catData['imageUrl'] != null &&
                            catData['imageUrl'].toString().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              catData['imageUrl'],
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        else
                          const Icon(Icons.category,
                              size: 50, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          catData['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: cart.isEmpty
          ? null
          : SizedBox(
              width: double.infinity,
              height: 60,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CounterScreen(cart: cart),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                label: const Text(
                  'Go to Counter',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }
}

class ItemTile extends StatefulWidget {
  final String categoryId;
  final String itemId;
  final Map<String, dynamic> item;
  final Function(int) onQtyChanged;
  final int initialQty;
  final List<Map<String, dynamic>> cart;

  const ItemTile({
    super.key,
    required this.itemId,
    required this.categoryId,
    required this.item,
    required this.onQtyChanged,
    required this.cart,
    this.initialQty = 0,
  });

  @override
  State<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  late int currentQty;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    currentQty = widget.initialQty;
    controller = TextEditingController(text: currentQty.toString());
  }

  void updateQty(int newQty) {
    int stock = widget.item['stock'] != null
        ? int.tryParse(widget.item['stock'].toString()) ?? 0
        : 0;

    if (newQty < 0) newQty = 0;
    if (newQty > stock) newQty = stock;

    setState(() {
      currentQty = newQty;
      controller.text = newQty.toString();
    });

    widget.onQtyChanged(newQty);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(widget.item['name']),
        subtitle: Text(
            "Price: ${widget.item['sellingPrice']} | Stock: ${widget.item['stock']}"),
        trailing: SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => updateQty(currentQty - 1),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    int qty = int.tryParse(val) ?? 0;
                    updateQty(qty);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => updateQty(currentQty + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
