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

  @override
  Widget build(BuildContext context) {
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
              // Recipe Description
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),

              // Allergens and Vegetarian Tags
              Wrap(
                spacing: 10,
                children: [
                  if (isVegetarian)
                    _buildTag("Vegetarian", Colors.green),
                  for (var allergen in allergens)
                    _buildTag("Contains $allergen", Colors.red),
                ],
              ),
              SizedBox(height: 20),

              // Ingredients Section
              Text(
                "Ingredients",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 10),
              ...ingredients.map((ingredient) => _buildListItem(ingredient)).toList(),
              SizedBox(height: 20),

              // Steps Section
              Text(
                "Steps",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 10),
              ...steps.map((step) => _buildListItem(step)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a tag
  Widget _buildTag(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Helper method to build a list item
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