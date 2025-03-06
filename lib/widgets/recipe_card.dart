// widgets/recipe_card.dart
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String image;
  final String title;
  final String calories;

  const RecipeCard({required this.image, required this.title, required this.calories});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(image, width: 150, height: 100, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(calories, style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}