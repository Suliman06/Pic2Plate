import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_ingredients_page.dart';
import 'auth_service.dart';
import 'recipe_search_page.dart';
import 'recipe_service.dart';
import 'secrets.dart';
import 'vision_service.dart';

final visionService = VisionService(apiKey: googleVisionApiKey);

class IngredientCategoriesPage extends StatefulWidget {
  @override
  _IngredientCategoriesPageState createState() => _IngredientCategoriesPageState();
}

class _IngredientCategoriesPageState extends State<IngredientCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<String> _selectedIngredients = [];
  List<String> _allIngredients = [];
  List<String> _filteredAllIngredients = [];
  String _userId = '';
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load user data, ingredient categories, and all ingredients from Firestore
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
      await _loadAllIngredients();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load all ingredients from Firestore
  Future<void> _loadAllIngredients() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('ingredients').get();
      _allIngredients = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toList()
        ..sort();
      _filteredAllIngredients = List.from(_allIngredients);
    } catch (e) {
      print('Error loading all ingredients: $e');
      _allIngredients = [];
      _filteredAllIngredients = [];
    }
  }

Future<void> _loadCategories() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('ingredientCategories')
        .orderBy('name')
        .get();

    final cats = snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return {
        'id':       doc.id,
        'name':     data['name']  ?? doc.id,
        'icon':     data['icon']  ?? 'category',
        'color':    data['color'] ?? '4CAF50',
      };
    }).toList();

    setState(() {
      _categories = cats;
    });
  } catch (e) {
    print('Error loading categories: $e');
    // Optional fallback to defaults
    setState(() {
      _categories = [
        {'id': 'fruits',      'name': 'Fruits',      'icon': 'nutrition',      'color': 'FF9800'},
        {'id': 'vegetables',  'name': 'Vegetables',  'icon': 'eco',            'color': '4CAF50'},
        {'id': 'dairy',       'name': 'Dairy',       'icon': 'egg',            'color': '2196F3'},
        {'id': 'other',       'name': 'Other',       'icon': 'category',       'color': '9E9E9E'},
      ];
    });
  }
}
String _beautify(String id) {
  if (id.isEmpty) return id;
  return id[0].toUpperCase() + id.substring(1);
}
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }

  IconData _getIconData(String iconName) {
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
        SnackBar(content: Text('Ingredients saved successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ingredients'), backgroundColor: Colors.red),
      );
    }
  }

  // Filter all ingredients based on the search query
  void _filterAllIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAllIngredients = List.from(_allIngredients);
      } else {
        _filteredAllIngredients = _allIngredients
            .where((ingredient) =>
                ingredient.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Camera button callback
  void _onCameraButtonPressed() async {
    final imageFile = await visionService.pickImage();
    if (imageFile != null) {
      List<String> labels = await visionService.detectLabels(imageFile);
      if (labels.isNotEmpty) {
        if (_allIngredients.isEmpty) {
          await _loadAllIngredients();
        }
        String? matchedIngredient;
        // Look for a match by comparing each detected label with database ingredients
        for (var label in labels) {
          for (var ingredient in _allIngredients) {
            if (ingredient.toLowerCase() == label.toLowerCase()) {
              matchedIngredient = ingredient;
              break;
            }
          }
          if (matchedIngredient != null) break;
        }
        
        if (matchedIngredient != null) {
          // Ask the user to confirm adding the detected ingredient
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Confirm Ingredient"),
              content: Text("We detected \"$matchedIngredient\". Do you want to add it?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("No"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Yes"),
                ),
              ],
            ),
          );
          if (confirm == true) {
            if (!_selectedIngredients.contains(matchedIngredient)) {
              setState(() {
                _selectedIngredients.add(matchedIngredient!);
              });
              await _saveUserIngredients();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$matchedIngredient added!"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("None of the detected ingredients are in our database."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No labels detected."),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                          onChanged: _filterAllIngredients,
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.green[600]),
                        onPressed: _onCameraButtonPressed,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
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
                                  onDeleted: () async {
                                    _toggleIngredient(ingredient);
                                    await _saveUserIngredients();
                                  },
                                  backgroundColor: Colors.green[200],
                                ))
                            .toList(),
                      ),
                    ),
                  SizedBox(height: 20),
                  
                  if (_searchController.text.isEmpty) ...[
                    Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 10),
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(_getIconData(category['icon'])),
                            label: Text(
                              category['name'],
                              style: TextStyle(fontSize: 16),
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
                  ]
                   else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredAllIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = _filteredAllIngredients[index];
                          return ListTile(
                            title: Text(ingredient),
                            onTap: () {
                              _toggleIngredient(ingredient);
                              _saveUserIngredients();
                            },
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
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                      borderRadius: BorderRadius.circular(15),
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
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userId = user.uid;
        await _loadCategoryIngredients();
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
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .where('categoryId', isEqualTo: widget.categoryId)
          .get();
      
      _categoryIngredients = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList()
        ..sort();
      
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
                            onDeleted: () async {
                              _toggleIngredient(ingredient);
                              await _saveUserIngredients();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  SizedBox(height: 16),
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
                      borderRadius: BorderRadius.circular(15),
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
                      borderRadius: BorderRadius.circular(15),
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