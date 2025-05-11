import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils.dart';
import 'recipe_details_page.dart' as details;

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Not logged in!
      return Scaffold(
        appBar: AppBar(title: Text("Favorites"), backgroundColor: Colors.green[600]),
        body: Center(child: Text("You must be signed in to see favorites.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Favorites')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, favSnap) {
          if (favSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!favSnap.hasData || favSnap.data!.docs.isEmpty) {
            return Center(child: Text("No favorites yet.\nTap the ❤️ on a recipe to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])));
          }

          final favDocs = favSnap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favDocs.length,
            itemBuilder: (context, i) {
              final fav = favDocs[i].data() as Map<String, dynamic>;
              final recipeId = fav['recipeId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('recipes')
                    .doc(recipeId)
                    .get(),
                builder: (context, recipeSnap) {
                  if (recipeSnap.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!recipeSnap.hasData || !recipeSnap.data!.exists) {
                    return ListTile(
                      leading: Icon(Icons.error, color: Colors.red),
                      title: Text("Recipe not found"),
                    );
                  }

                  final data = recipeSnap.data!.data()! as Map<String, dynamic>;
                  final title    = data['title'] ?? data['name'] ?? 'Unnamed Recipe';
                  final description = data['description'] ?? '';
                  final calories = (data['calories'] ?? 0).toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(Icons.favorite, color: Colors.red),
                      title: Text(title),
                      subtitle: Text('$calories kcal'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => details.RecipeDetailsPage(
                              recipeId: recipeSnap.data!.id,
                              recipeName: title,
                              description: description,
                              ingredients: ensureStringList(data['ingredients']),
                              steps:       ensureStringList(data['steps']),
                              isVegetarian: data['isVegetarian'] == true,
                              allergens:    ensureStringList(data['allergens']),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
