import 'package:flutter/material.dart';
import 'recipe_details_page.dart'; // Import RecipeDetailsPage
import 'recipe_service.dart'; // Import RecipeService

class CategoryRecipesPage extends StatelessWidget {
  final String category;

  const CategoryRecipesPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final RecipeService recipeService = RecipeService();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: recipeService.loadRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading recipes"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No recipes found"));
          } else {
            final recipes = snapshot.data![category] ?? [];

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final recipeTitle = recipe['title'];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(recipeTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text(recipe['calories'], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    onTap: () {
                      // Navigate to RecipeDetailsPage with dynamic data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailsPage(
                            recipeName: recipeTitle,
                            description: recipe['description'],
                            ingredients: (recipe['ingredients'] as List).cast<String>(),
                            steps: (recipe['steps'] as List).cast<String>(),
                            isVegetarian: recipe['isVegetarian'],
                            allergens: (recipe['allergens'] as List).cast<String>(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}