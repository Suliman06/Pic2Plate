// recipe_service.dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RecipeService {
  // Helper function to load recipes from the JSON file
  Future<Map<String, dynamic>> loadRecipes() async {
    String jsonString = await rootBundle.loadString('assets/recipes.json');
    return jsonDecode(jsonString);
  }
}