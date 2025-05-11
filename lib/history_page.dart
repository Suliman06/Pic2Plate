import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_details_page.dart' as details;

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('history')
            .where('userId', isEqualTo: uid)
            .orderBy('viewedAt', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text("You haven’t viewed any recipes yet."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final h = docs[i].data()! as Map<String, dynamic>;
              final title    = h['title']    as String? ?? 'Untitled';
              final calories = h['calories'] as int?    ?? 0;
              final recipeId = h['recipeId'] as String;
              return ListTile(
                leading: Icon(
                  _iconForCategory(h['category'] as String? ?? ''),
                  color: Colors.green,
                ),
                title: Text(title),
                subtitle: Text("$calories kcal"),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => details.RecipeDetailsPage(
                        recipeId:      recipeId,
                        recipeName:    title,
                        description:   h['description']  as String? ?? '',
                        ingredients:   List<String>.from(h['ingredients'] ?? []),
                        steps:         List<String>.from(h['steps']       ?? []),
                        isVegetarian:  h['isVegetarian'] == true,
                        allergens:     List<String>.from(h['allergens']    ?? []),
                      ),
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

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'breakfast': return Icons.breakfast_dining;
      case 'lunch':     return Icons.lunch_dining;
      case 'dinner':    return Icons.dinner_dining;
      case 'desserts':  return Icons.icecream;
      default:          return Icons.restaurant;
    }
  }
}
