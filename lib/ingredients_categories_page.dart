// Page for managing ingredient categories and selecting ingredients by category
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_ingredients_page.dart';
import 'auth_service.dart';
import 'recipe_search_page.dart';
import 'recipe_service.dart';

class IngredientCategoriesPage extends StatefulWidget {
  @override
  _IngredientCategoriesPageState createState() => _IngredientCategoriesPageState();
}

class _IngredientCategoriesPageState extends State<IngredientCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<String> _selectedIngredients = [];
  String _userId = '';
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  // Load user data and ingredient categories from Firestore
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {

      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userId = user.uid;
        
      
        _selectedIngredients = await _recipeService.getUserIngredients(_userId);
      }
      

      await _loadCategories();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load ingredient categories from Firestore or use defaults
  Future<void> _loadCategories() async {
    try {
      // Get categories from Firestore
      final QuerySnapshot snapshot = 
          await FirebaseFirestore.instance.collection('ingredientCategories').get();
      
      _categories = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] as String,
          'icon': doc['icon'] as String? ?? 'restaurant',
          'color': doc['color'] as String? ?? '4CAF50', // Default green
        };
      }).toList();

      // If no categories exist in Firestore, create default ones
      if (_categories.isEmpty) {
  _categories = [
    {'id': 'fruits', 'name': 'Fruits', 'icon': 'nutrition', 'color': 'FF9800'},
    {'id': 'vegetables', 'name': 'Vegetables', 'icon': 'eco', 'color': '4CAF50'},
    {'id': 'dairy', 'name': 'Dairy', 'icon': 'egg', 'color': '2196F3'},
    {'id': 'meat', 'name': 'Meat', 'icon': 'lunch_dining', 'color': 'F44336'},
    {'id': 'grains', 'name': 'Grains & Bread', 'icon': 'grain', 'color': 'FFC107'},
    {'id': 'spices', 'name': 'Spices & Herbs', 'icon': 'spa', 'color': '9C27B0'},
    {'id': 'beverages', 'name': 'Beverages', 'icon': 'local_cafe', 'color': '009688'},
    {'id': 'snacks', 'name': 'Snacks', 'icon': 'cookie', 'color': 'FFEB3B'},
    {'id': 'seafood', 'name': 'Seafood', 'icon': 'set_meal', 'color': '2196F3'},
    {'id': 'bakery', 'name': 'Bakery', 'icon': 'bakery_dining', 'color': '8D6E63'},
    {'id': 'condiments', 'name': 'Condiments', 'icon': 'kitchen', 'color': 'FFC107'},
    {'id': 'herbs', 'name': 'Herbs', 'icon': 'eco', 'color': '388E3C'},
  ];
}

    } catch (e) {
      print('Error loading categories: $e');
      // Default categories as fallback
      _categories = [
        {'id': 'vegetables', 'name': 'Vegetables', 'icon': 'eco', 'color': '4CAF50'},
        {'id': 'fruits', 'name': 'Fruits', 'icon': 'nutrition', 'color': 'FF9800'},
        {'id': 'dairy', 'name': 'Dairy', 'icon': 'egg', 'color': '2196F3'},
        {'id': 'other', 'name': 'Other', 'icon': 'category', 'color': '9E9E9E'},
      ];
    }
  }

  // convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor; 
    }
    return Color(int.parse('0x$hexColor'));
  }

  //  get IconData from string
  IconData _getIconData(String iconName) {
    // Map common icon names to Flutter's Material icons
    switch (iconName) {
      case 'eco': return Icons.eco;
      case 'nutrition': return Icons.food_bank;
      case 'egg': return Icons.egg;
      case 'grain': return Icons.grain;
      case 'lunch_dining': return Icons.lunch_dining;
      case 'spa': return Icons.spa;
      case 'kitchen': return Icons.kitchen;
      case 'category': return Icons.category;
      case 'apple': return Icons.apple;
      case 'grass': return Icons.grass;
      case 'local_drink': return Icons.local_drink;
      case 'cookie': return Icons.cookie;
      case 'set_meal': return Icons.set_meal;
      case 'bakery_dining': return Icons.bakery_dining;
      case 'local_cafe': return Icons.local_cafe;
      default: return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ingredients"),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search ingredients...",
                      prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Selected Ingredients Display
                  if (_selectedIngredients.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        spacing: 8,
                        children: _selectedIngredients
                            .map((ingredient) => Chip(
                                  label: Text(ingredient),
                                  deleteIcon: Icon(Icons.close),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedIngredients.remove(ingredient);
                                    });
                                  },
                                  backgroundColor: Colors.green[200],
                                ))
                            .toList(),
                      ),
                    ),
                  
                  SizedBox(height: 20),
                  
                  // Categories Title
                  Text(
                    "Categories", 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.green[800]
                    )
                  ),
                  
                  SizedBox(height: 10),
                  
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.5, 
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final Color categoryColor = _getColorFromHex(category['color']);
                        
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: categoryColor.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            elevation: 2,
                          ),
                          icon: Icon(_getIconData(category['icon'])),
                          label: Text(
                            category['name'], 
                            style: TextStyle(fontSize: 16)
                          ),
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => CategoryIngredientsPage(
                                  categoryId: category['id'],
                                  categoryName: category['name'],
                                  categoryColor: categoryColor,
                                ),
                              ),
                            ).then((value) {
                              _loadData();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CategoryIngredientsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;

  CategoryIngredientsPage({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  _CategoryIngredientsPageState createState() => _CategoryIngredientsPageState();
}

class _CategoryIngredientsPageState extends State<CategoryIngredientsPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  
  List<String> _categoryIngredients = [];
  List<String> _filteredIngredients = [];
  List<String> _selectedIngredients = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userId = user.uid;
        
        // Load category ingredients from Firestore
        await _loadCategoryIngredients();
        
        // Load user's previously selected ingredients
        await _loadUserIngredients(_userId);
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ingredients')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategoryIngredients() async {
    try {
      // Get ingredients from Firestore with category filter
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .where('categoryId', isEqualTo: widget.categoryId)
          .get();
      
      _categoryIngredients = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList()
        ..sort(); // Sort alphabetically
      
      _filteredIngredients = List.from(_categoryIngredients);
    } catch (e) {
      print('Error loading category ingredients: $e');
      _categoryIngredients = [];
      _filteredIngredients = [];
    }
  }

  Future<void> _loadUserIngredients(String userId) async {
    try {
      _selectedIngredients = await _recipeService.getUserIngredients(userId);
    } catch (e) {
      print('Error loading user ingredients: $e');
      _selectedIngredients = [];
    }
  }

  void _filterIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIngredients = List.from(_categoryIngredients);
      } else {
        _filteredIngredients = _categoryIngredients
            .where((ingredient) => 
                ingredient.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  Future<void> _saveUserIngredients() async {
    try {
      await _recipeService.saveUserIngredients(_userId, _selectedIngredients);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingredients saved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving ingredients: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save ingredients'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: widget.categoryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search ${widget.categoryName.toLowerCase()}...",
                      prefixIcon: Icon(Icons.search, color: widget.categoryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onChanged: _filterIngredients,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Selected ingredients chips
                  if (_selectedIngredients.isNotEmpty && 
                      _categoryIngredients.any((i) => _selectedIngredients.contains(i)))
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _selectedIngredients
                            .where((i) => _categoryIngredients.contains(i))
                            .map((ingredient) {
                          return Chip(
                            label: Text(ingredient),
                            backgroundColor: widget.categoryColor.withOpacity(0.2),
                            deleteIconColor: widget.categoryColor,
                            onDeleted: () => _toggleIngredient(ingredient),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  SizedBox(height: 16),
                  
                  // Category ingredients list
                  Expanded(
                    child: _filteredIngredients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.no_food, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "No ingredients found in this category",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _filteredIngredients.length,
                            itemBuilder: (context, index) {
                              final ingredient = _filteredIngredients[index];
                              final isSelected = _selectedIngredients.contains(ingredient);
                              
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    ingredient,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle, color: widget.categoryColor)
                                      : Icon(Icons.add_circle_outline, color: Colors.grey),
                                  onTap: () => _toggleIngredient(ingredient),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.categoryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                  onPressed: () async {
                    await _saveUserIngredients();
                  },
                  child: Text("Save Ingredients"),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                  onPressed: _selectedIngredients.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeSearchPage(
                                userIngredients: _selectedIngredients,
                              ),
                            ),
                          );
                        },
                  child: Text("Find Recipes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}