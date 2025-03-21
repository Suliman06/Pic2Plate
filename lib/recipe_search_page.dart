import 'package:flutter/material.dart';
import 'recipe_service.dart';  // Import the RecipeService
import 'recipe_details_page.dart';

class RecipeSearchPage extends StatefulWidget {
  final List<String> userIngredients;

  RecipeSearchPage({required this.userIngredients});

  @override
  _RecipeSearchPageState createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  late Future<Map<String, dynamic>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    // Load the recipes from the service
    _recipesFuture = RecipeService().loadRecipes();
  }

  // Helper function to filter recipes based on user ingredients
  List<Map<String, dynamic>> getFilteredRecipes(Map<String, dynamic> allRecipes) {
    List<Map<String, dynamic>> filteredRecipes = [];

    allRecipes.forEach((category, recipes) {
      for (var recipe in recipes) {
        // Normalize user ingredients and recipe ingredients to lowercase for case-insensitive comparison
        List<String> normalizedUserIngredients = widget.userIngredients
            .map((ingredient) => ingredient.toLowerCase().trim())
            .toList();

        // Ensure that the recipe ingredients are cast to List<String> explicitly
        List<String> normalizedRecipeIngredients = (recipe["ingredients"] as List<dynamic>)
            .map((e) => e.toString().toLowerCase().trim())
            .toList();

        // Check if the recipe contains all the ingredients the user has entered
        bool containsAllIngredients = normalizedUserIngredients.every((ingredient) {
          return normalizedRecipeIngredients.contains(ingredient);
        });

        // If the recipe contains all user ingredients, add it to the filtered list
        if (containsAllIngredients) {
          filteredRecipes.add(recipe);
        }
      }
    });

    return filteredRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes You Can Make"),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading recipes'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No recipes found."));
          }

          final filteredRecipes = getFilteredRecipes(snapshot.data!);

          return filteredRecipes.isEmpty
              ? Center(child: Text("No recipes found with your ingredients."))
              : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    recipe["title"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    recipe["description"],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeName: recipe["title"],
                          description: recipe["description"],
                          ingredients: (recipe["ingredients"] as List<dynamic>)
                              .cast<String>(),
                          steps: (recipe["steps"] as List<dynamic>)
                              .cast<String>(),
                          isVegetarian: recipe["isVegetarian"],
                          allergens: (recipe["allergens"] as List<dynamic>)
                              .cast<String>(),
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
}
