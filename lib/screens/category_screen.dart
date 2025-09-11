import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/item_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddCategoryDialog({DocumentSnapshot? category}) {
    final nameController = TextEditingController();
    File? pickedImage;

    if (category != null) {
      nameController.text = category['name'] ?? '';
      if (category['image'] != null &&
          category['image'].toString().isNotEmpty) {
        pickedImage = File(category['image']);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title:
                  Text(category == null ? "Add New Category" : "Edit Category"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setStateDialog(() {
                          pickedImage = File(image.path);
                        });
                      }
                    },
                    child: pickedImage == null
                        ? Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.camera_alt, size: 40),
                          )
                        : Image.file(pickedImage!,
                            height: 100, width: 100, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter Category Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Category name cannot be empty"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      if (category == null) {
                        await _firestore.collection("categories").add({
                          "name": nameController.text.trim(),
                          "image": pickedImage?.path ?? "",
                        });
                      } else {
                        await _firestore
                            .collection("categories")
                            .doc(category.id)
                            .update({
                          "name": nameController.text.trim(),
                          "image": pickedImage?.path ?? "",
                        });
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text(category == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCategory(String categoryId) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                confirm = true;
                Navigator.pop(ctx);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm) {
      try {
        await _firestore.collection("categories").doc(categoryId).delete();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error deleting category: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildCategoryCard(DocumentSnapshot category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ItemScreen(categoryId: category.id)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: category["image"] != null &&
                      category["image"].toString().isNotEmpty
                  ? Image.file(File(category["image"]),
                      width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 60),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category["name"],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showAddCategoryDialog(category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(category.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("categories").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          final categories = snapshot.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(categories[index]);
            },
          );
        },
      ),
    );
  }
}
