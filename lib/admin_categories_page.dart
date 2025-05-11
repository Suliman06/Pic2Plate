import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_pic2plate/ingredients_categories_page.dart';

class AdminCategoriesPage extends StatefulWidget {
  @override
  _AdminCategoriesPageState createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _categoryController = TextEditingController();
  bool _didSeed = false;

  @override
  void initState() {
    super.initState();
    _seedDefaults();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _seedDefaults() async {
    if (_didSeed) return;
    _didSeed = true;

    final col = _firestore.collection('ingredientCategories');
    final snapshot = await col.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final defaults = <Map<String, String>>[
      {'id': 'Meat',      'name': 'Meat',      'icon': 'lunch_dining',   'color': 'F44336'},
      {'id': 'Fruits',    'name': 'Fruits',    'icon': 'nutrition',      'color': 'FF9800'},
      {'id': 'Dairy',     'name': 'Dairy',     'icon': 'egg',            'color': '2196F3'},
      {'id': 'Grains',    'name': 'Grains & Bread','icon': 'grain',      'color': 'FFC107'},
      {'id': 'Spices',    'name': 'Spices & Herbs','icon': 'spa',        'color': '9C27B0'},
      {'id': 'Beverages', 'name': 'Beverages', 'icon': 'local_cafe',      'color': '009688'},
      {'id': 'Snacks',    'name': 'Snacks',    'icon': 'cookie',          'color': 'FFEB3B'},
      {'id': 'Seafood',   'name': 'Seafood',   'icon': 'set_meal',        'color': '2196F3'},
      {'id': 'Bakery',    'name': 'Bakery',    'icon': 'bakery_dining',   'color': '8D6E63'},
      {'id': 'Condiments','name': 'Condiments','icon': 'restaurant',      'color': '795548'},
      {'id': 'Herbs',     'name': 'Herbs',     'icon': 'eco',             'color': '388E3C'},
    ];

    for (var cat in defaults) {
      await col.doc(cat['id']).set({
        'name':  cat['name']!,
        'icon':  cat['icon']!,
        'color': cat['color']!,
      });
    }
  }

  Color _getColorFromHex(String hex) {
    var colorHex = hex.replaceAll('#', '');
    if (colorHex.length == 6) colorHex = 'FF' + colorHex;
    return Color(int.parse('0x$colorHex'));
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'eco':           return Icons.eco;
      case 'nutrition':     return Icons.food_bank;
      case 'egg':           return Icons.egg;
      case 'grain':         return Icons.grain;
      case 'lunch_dining':  return Icons.lunch_dining;
      case 'spa':           return Icons.spa;
      case 'local_cafe':    return Icons.local_cafe;
      case 'cookie':        return Icons.cookie;
      case 'set_meal':      return Icons.set_meal;
      case 'bakery_dining': return Icons.bakery_dining;
      case 'restaurant':    return Icons.restaurant;
      default:              return Icons.category;
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final name = _categoryController.text.trim();
              if (name.isNotEmpty) {
                await _firestore
                    .collection('ingredientCategories')
                    .doc(name)
                    .set({
                  'name': name,
                  'icon': 'category',
                  'color': '4CAF50',
                });
                _categoryController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('ingredientCategories').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No categories yet. Tap + to add."));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, i) {
                final doc = docs[i];
                final data = doc.data()! as Map<String, dynamic>;
                final name = data['name'] as String? ?? 'Unnamed';
                final icon = _getIconData(data['icon'] as String? ?? '');
                final color = _getColorFromHex(data['color'] as String? ?? '4CAF50');

                return InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryIngredientsPage(
                          categoryId: doc.id,
                          categoryName: name,
                          categoryColor: color,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _firestore
                                .collection('ingredientCategories')
                                .doc(doc.id)
                                .delete(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 48, color: color),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddCategoryDialog,
      ),
    );
  }
}
