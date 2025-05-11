import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _normalizeIngredientsList(dynamic ingredients) {
    if (ingredients == null) {
      return [];
    } else if (ingredients is String) {
      return [ingredients];
    } else if (ingredients is List) {
      return ingredients.map((item) => item.toString()).toList();
    } else {
      return [];
    }
  }

  // Load all recipes and group by category
  Future<Map<String, dynamic>> loadRecipes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('recipes').get();
      Map<String, dynamic> recipesByCategory = {};

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> recipeData = doc.data() as Map<String, dynamic>;
        String category = recipeData['category'] ?? 'Uncategorized';

        if (!recipesByCategory.containsKey(category)) {
          recipesByCategory[category] = [];
        }

        recipesByCategory[category].add({
          'id': doc.id,
          'title': recipeData['title'] ?? 'Unknown Recipe',
          'description': recipeData['description'] ?? '',
          'ingredients': _normalizeIngredientsList(recipeData['ingredients']),
          'steps': _normalizeIngredientsList(recipeData['steps']),
          'isVegetarian': recipeData['isVegetarian'] ?? false,
          'allergens': _normalizeIngredientsList(recipeData['allergens']),
          'calories': recipeData['calories'] ?? '0 kcal',
          'image': recipeData['image'] ?? 'assets/images/default-recipe.png',
          'category': category,
        });
      }

      return recipesByCategory;
    } catch (e) {
      print('Error loading recipes: $e');
      return {};
    }
  }

  // Search recipes by provided list of ingredients
  Future<List<Map<String, dynamic>>> searchRecipesByIngredients(List<String> ingredients) async {
    try {
      List<Map<String, dynamic>> matchedRecipes = [];
      List<String> normalizedUserIngredients = ingredients
          .map((ingredient) => ingredient.toLowerCase().trim())
          .toList();

      QuerySnapshot querySnapshot = await _firestore.collection('recipes').get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> recipeData = doc.data() as Map<String, dynamic>;
        List<String> recipeIngredients = _normalizeIngredientsList(recipeData['ingredients'])
            .map((ingredient) => ingredient.toLowerCase().trim())
            .toList();

        bool containsAnyIngredient = normalizedUserIngredients.any((ingredient) {
          return recipeIngredients.any((recipeIngredient) =>
          recipeIngredient.contains(ingredient) || ingredient.contains(recipeIngredient));
        });

        if (containsAnyIngredient) {
          matchedRecipes.add({
            'id': doc.id,
            'title': recipeData['title'] ?? 'Unknown Recipe',
            'description': recipeData['description'] ?? '',
            'ingredients': _normalizeIngredientsList(recipeData['ingredients']),
            'steps': _normalizeIngredientsList(recipeData['steps']),
            'isVegetarian': recipeData['isVegetarian'] ?? false,
            'allergens': _normalizeIngredientsList(recipeData['allergens']),
            'calories': recipeData['calories'] ?? '0 kcal',
            'image': recipeData['image'] ?? 'assets/images/default-recipe.png',
            'category': recipeData['category'] ?? 'Uncategorized',
          });
        }
      }

      return matchedRecipes;
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  // Fetch all recipes matching a specific category
  Future<List<Map<String, dynamic>>> getRecipesByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recipes')
          .where('category', isEqualTo: category)
          .get();

      List<Map<String, dynamic>> categoryRecipes = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> recipeData = doc.data() as Map<String, dynamic>;

        categoryRecipes.add({
          'id': doc.id,
          'title': recipeData['title'] ?? 'Unknown Recipe',
          'description': recipeData['description'] ?? '',
          'ingredients': _normalizeIngredientsList(recipeData['ingredients']),
          'steps': _normalizeIngredientsList(recipeData['steps']),
          'isVegetarian': recipeData['isVegetarian'] ?? false,
          'allergens': _normalizeIngredientsList(recipeData['allergens']),
          'calories': recipeData['calories'] ?? '0 kcal',
          'image': recipeData['image'] ?? 'assets/images/default-recipe.png',
          'category': recipeData['category'] ?? category,
        });
      }

      return categoryRecipes;
    } catch (e) {
      print('Error getting recipes by category: $e');
      return [];
    }
  }

  // Save selected ingredients for a user to Firestore
  Future<void> saveUserIngredients(String userId, List<String> ingredients) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'ingredients': ingredients,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user ingredients: $e');
      throw e;
    }
  }

  // Retrieve saved user ingredients from Firestore
  Future<List<String>> getUserIngredients(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        return _normalizeIngredientsList(userData['ingredients']);
      }

      return [];
    } catch (e) {
      print('Error getting user ingredients: $e');
      return [];
    }
  }
}