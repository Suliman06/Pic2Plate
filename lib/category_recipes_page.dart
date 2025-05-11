
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_details_page.dart' as details;
import 'widgets/recipe_card.dart';

Future<void> _recordHistory(Map<String, dynamic> recipe) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('history').add({
    'userId'      : uid,
    'recipeId'    : recipe['id'],
    'title'       : recipe['title'],
    'calories'    : recipe['calories'],
    'description' : recipe['description'],
    'ingredients' : recipe['ingredients'],
    'steps'       : recipe['steps'],
    'isVegetarian': recipe['isVegetarian'],
    'allergens'   : recipe['allergens'],
    'viewedAt'    : FieldValue.serverTimestamp(),
  });
}

class CategoryRecipesPage extends StatelessWidget {
  final String category;
  const CategoryRecipesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final catQuery = _capitalize(category);
    final recipesStream = FirebaseFirestore.instance
        .collection('recipes')
        .where('category', isEqualTo: catQuery)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('$catQuery Recipes'),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: recipesStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_food, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No recipes found for $catQuery',
                      style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc  = docs[i];
              final data = doc.data()! as Map<String, dynamic>;
              final recipe = {
                'id'          : doc.id,
                'title'       : data['title']       as String? ?? 'Untitled',
                'description' : data['description'] as String? ?? '',
                'calories'    : data['calories']    ?? 0,
                'image'       : data['image']       as String? ?? '',
                'ingredients' : List<String>.from(data['ingredients'] ?? []),
                'steps'       : List<String>.from(data['steps']       ?? []),
                'isVegetarian': data['isVegetarian'] == true,
                'allergens'   : List<String>.from(data['allergens']    ?? []),
              };

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: recipe['image'] != ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderIcon(),
                          ),
                        )
                      : _placeholderIcon(),
                  title: Text(recipe['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(recipe['description'],
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (recipe['isVegetarian'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Vegetarian',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.green)),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('${recipe['calories']} kcal',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () async {
                    await _recordHistory(recipe);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => details.RecipeDetailsPage(
                          recipeId:      recipe['id'],
                          recipeName:    recipe['title'],
                          description:   recipe['description'],
                          ingredients:   recipe['ingredients'],
                          steps:         recipe['steps'],
                          isVegetarian:  recipe['isVegetarian'],
                          allergens:     recipe['allergens'],
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

  Widget _placeholderIcon() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.restaurant, color: Colors.grey),
      );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
