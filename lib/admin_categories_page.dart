import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoriesPage extends StatefulWidget {
  @override
  _AdminCategoriesPageState createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddCategoryDialog(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var category = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  leading: Icon(_getCategoryIcon(category['icon'])),
                  title: Text(category['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(category.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'breakfast': return Icons.breakfast_dining;
      case 'lunch': return Icons.lunch_dining;
      case 'dinner': return Icons.dinner_dining;
      case 'snacks': return Icons.local_pizza;
      default: return Icons.category;
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Category"),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: "Category Name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                _categoryController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                if (_categoryController.text.isNotEmpty) {
                  _firestore.collection('categories').add({
                    'name': _categoryController.text,
                    'icon': 'category', // Default icon
                  });
                  _categoryController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _firestore.collection('categories').doc(categoryId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}