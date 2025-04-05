// Page for selecting ingredients, saving them, and navigating to recipe search
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'recipe_service.dart';
import 'recipe_search_page.dart';

class AddIngredientsPage extends StatefulWidget {
  @override
  _AddIngredientsPageState createState() => _AddIngredientsPageState();
}

class _AddIngredientsPageState extends State<AddIngredientsPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  
  List<String> _availableIngredients = [];
  List<String> _selectedIngredients = [];
  List<String> _filteredIngredients = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load user and ingredient data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userId = user.uid;
        await _loadAvailableIngredients();
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

  // Fetch all ingredients from Firestore
  Future<void> _loadAvailableIngredients() async {
    try {
      final QuerySnapshot snapshot = 
          await FirebaseFirestore.instance.collection('ingredients').get();
      
      _availableIngredients = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList()
        ..sort();

      _filteredIngredients = List.from(_availableIngredients);
    } catch (e) {
      print('Error loading ingredients: $e');
      _availableIngredients = [];
      _filteredIngredients = [];
    }
  }

  // Get previously selected ingredients for the user
  Future<void> _loadUserIngredients(String userId) async {
    try {
      _selectedIngredients = await _recipeService.getUserIngredients(userId);
    } catch (e) {
      print('Error loading user ingredients: $e');
      _selectedIngredients = [];
    }
  }

  // Filter ingredients based on search query
  void _filterIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIngredients = List.from(_availableIngredients);
      } else {
        _filteredIngredients = _availableIngredients
            .where((ingredient) => 
                ingredient.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Add/remove ingredient from selection
  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  // Save selected ingredients to Firestore
  Future<void> _saveUserIngredients() async {
    try {
      await _recipeService.saveUserIngredients(_userId, _selectedIngredients);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingredients saved successfully')),
      );
    } catch (e) {
      print('Error saving ingredients: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ingredients')),
      );
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
          : Column(
              children: [
                // Ingredient search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search ingredients...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _filterIngredients,
                  ),
                ),
                
                // Display selected ingredients
                if (_selectedIngredients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedIngredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          backgroundColor: Colors.green[100],
                          deleteIconColor: Colors.green[800],
                          onDeleted: () async {_toggleIngredient(ingredient); await _saveUserIngredients();},
                        );
                      }).toList(),
                    ),
                  ),
                
                SizedBox(height: 8),
                
                // Ingredient list view
                Expanded(
                  child: _filteredIngredients.isEmpty
                      ? Center(child: Text("No ingredients found"))
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
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
                                title: Text(ingredient),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: Colors.green[600])
                                    : Icon(Icons.add_circle_outline, color: Colors.grey),
                                onTap: () => _toggleIngredient(ingredient),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Save ingredients button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    await _saveUserIngredients();
                  },
                  child: Text("Save Ingredients"),
                ),
              ),
              SizedBox(width: 16),
              // Navigate to recipe search page
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: EdgeInsets.symmetric(vertical: 12),
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
