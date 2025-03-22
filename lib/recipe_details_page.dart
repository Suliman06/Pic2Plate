// Page to show full details for a selected recipe
import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatelessWidget {
  final String recipeName;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final bool isVegetarian;
  final List<String> allergens;
  
  const RecipeDetailsPage({
    required this.recipeName,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.isVegetarian,
    required this.allergens,
  });

  static List<String> ensureStringList(dynamic items) {
    if (items == null) {
      return [];
    } else if (items is String) {
      return [items];
    } else if (items is List) {
      return items.map((item) => item.toString()).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> formattedIngredients = ensureStringList(ingredients);
    final List<String> formattedSteps = ensureStringList(steps);
    final List<String> formattedAllergens = ensureStringList(allergens);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe description
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),

              // Display tags 
              Wrap(
                spacing: 10,
                children: [
                  if (isVegetarian)
                    _buildTag("Vegetarian", Colors.green),
                  for (var allergen in formattedAllergens)
                    _buildTag("Contains $allergen", Colors.red),
                ],
              ),
              SizedBox(height: 20),

              // Ingredients section
              Text(
                "Ingredients",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 10),
              ...formattedIngredients.map((ingredient) => _buildListItem(ingredient)).toList(),
              SizedBox(height: 20),

              // Steps section
              Text(
                "Steps",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 10),
              ...formattedSteps.map((step) => _buildListItem(step)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Create a tag-style chip
  Widget _buildTag(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Create a card-style list item
  Widget _buildListItem(String text) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
