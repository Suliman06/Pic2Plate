// Page to display recipes matched to the user's selected ingredients
import 'package:flutter/material.dart';
import 'recipe_service.dart';
import 'recipe_details_page.dart' as details;
import 'utils.dart';

class RecipeSearchPage extends StatefulWidget {
  final List<String> userIngredients;

  RecipeSearchPage({required this.userIngredients});

  @override
  _RecipeSearchPageState createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    print('Searching for recipes with ingredients: ${widget.userIngredients}');
    _recipesFuture = _loadRankedRecipes();
  }

  Future<List<Map<String, dynamic>>> _loadRankedRecipes() async {
    List<Map<String, dynamic>> recipes = await _recipeService.searchRecipesByIngredients(widget.userIngredients);

    List<Map<String, dynamic>> rankedRecipes = recipes.map((recipe) {
      List<String> ingredients = ensureStringList(recipe["ingredients"]);
      int matchCount = ingredients.where((ingredient) => widget.userIngredients.contains(ingredient)).length;

      return {
        ...recipe,
        'matchCount': matchCount,
        'totalIngredients': ingredients.length,
      };
    }).toList();

    rankedRecipes.sort((a, b) => b['matchCount'].compareTo(a['matchCount']));

    return rankedRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes You Can Make"),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 20),
                    Text("Error loading recipes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    SizedBox(height: 10),
                    Text(snapshot.error.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[700]), textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Go Back"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food, size: 80, color: Colors.grey),
                    SizedBox(height: 20),
                    Text("No recipes found with your ingredients.", style: TextStyle(fontSize: 18, color: Colors.grey[700]), textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Add More Ingredients"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final rankedRecipes = snapshot.data!;
          // Display list of recipe cards
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: rankedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = rankedRecipes[index];
              List<String> ingredients = ensureStringList(recipe["ingredients"]);
              List<String> steps = ensureStringList(recipe["steps"]);
              List<String> allergens = ensureStringList(recipe["allergens"]);

              bool isPerfectMatch = recipe['matchCount'] == widget.userIngredients.length;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                color: isPerfectMatch ? Colors.green[100] : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: recipe['image'] != null && !recipe['image'].toString().startsWith('assets')
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      recipe['image'].toString(),
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
                  title: Text(
                    recipe["title"].toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        recipe["description"].toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
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
                            recipe["calories"]?.toString() ?? "0 kcal",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Matches ${recipe['matchCount']} of ${widget.userIngredients.length} ingredients",
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => details.RecipeDetailsPage(
                          recipeId: recipe['id'] ?? '',
                          recipeName: recipe["title"].toString(),
                          description: recipe["description"].toString(),
                          ingredients: ingredients,
                          steps: steps,
                          isVegetarian: recipe["isVegetarian"] ?? false,
                          allergens: allergens,
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

List<String> ensureStringList(dynamic items) {
  if (items == null) return [];
  if (items is String) return [items];
  if (items is List) return items.map((e) => e.toString()).toList();
  return [];
}