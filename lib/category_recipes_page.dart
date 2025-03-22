// Page to display recipes filtered by category (e.g., Breakfast, Lunch)
import 'package:flutter/material.dart';
import 'recipe_service.dart';
import 'recipe_details_page.dart';

class CategoryRecipesPage extends StatefulWidget {
  final String category;

  CategoryRecipesPage({required this.category});

  @override
  _CategoryRecipesPageState createState() => _CategoryRecipesPageState();
}

class _CategoryRecipesPageState extends State<CategoryRecipesPage> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    // Load recipes based on selected category
    _recipesFuture = _recipeService.getRecipesByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} Recipes"),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading recipes: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_food, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "No recipes found for ${widget.category}",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          final recipes = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),

                  // Display image or icon fallback
                  leading: recipe['image'] != null && !recipe['image'].startsWith('assets')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.restaurant, color: Colors.grey[600]),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.restaurant, color: Colors.green[700]),
                        ),

                  // Display recipe title and description
                  title: Text(
                    recipe["title"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        recipe["description"],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          // Vegetarian tag
                          if (recipe["isVegetarian"] == true)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Vegetarian",
                                style: TextStyle(fontSize: 12, color: Colors.green[800]),
                              ),
                            ),
                          SizedBox(width: 8),
                          Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            recipe["calories"] ?? "0 kcal",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // On tap, navigate to recipe details page
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeName: recipe["title"],
                          description: recipe["description"],
                          ingredients: (recipe["ingredients"] as List<dynamic>).cast<String>(),
                          steps: (recipe["steps"] as List<dynamic>).cast<String>(),
                          isVegetarian: recipe["isVegetarian"],
                          allergens: (recipe["allergens"] as List<dynamic>).cast<String>(),
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
