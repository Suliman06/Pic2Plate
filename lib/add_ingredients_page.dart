import 'package:flutter/material.dart';
import 'recipe_search_page.dart';

class AddIngredientsPage extends StatefulWidget {
  @override
  _AddIngredientsPageState createState() => _AddIngredientsPageState();
}

class _AddIngredientsPageState extends State<AddIngredientsPage> {
  List<String> selectedIngredients = []; // Stores selected ingredients

  void _addIngredient(String ingredient) {
    if (!selectedIngredients.contains(ingredient)) {
      setState(() {
        selectedIngredients.add(ingredient);
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      selectedIngredients.remove(ingredient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ingredients"),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
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
            if (selectedIngredients.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.green[50],
                child: Wrap(
                  spacing: 8,
                  children: selectedIngredients
                      .map((ingredient) => Chip(
                    label: Text(ingredient),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () => _removeIngredient(ingredient),
                    backgroundColor: Colors.green[200],
                  ))
                      .toList(),
                ),
              ),

            SizedBox(height: 20),

            // Categories Section
            Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two columns for categories
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5, // Make buttons wider
                children: [
                  _categoryButton(context, "Fruits", Icons.apple, Colors.orange),
                  _categoryButton(context, "Vegetables", Icons.grass, Colors.green),
                  _categoryButton(context, "Dairy", Icons.local_drink, Colors.blue),
                  _categoryButton(context, "Meat", Icons.lunch_dining, Colors.red),
                  _categoryButton(context, "Grains", Icons.grain, Colors.brown),
                  _categoryButton(context, "Spices", Icons.spa, Colors.purple),
                  _categoryButton(context, "Beverages", Icons.local_cafe, Colors.teal),
                  _categoryButton(context, "Snacks", Icons.cookie, Colors.amber),
                  _categoryButton(context, "Seafood", Icons.set_meal, Colors.blue[800]!),
                  _categoryButton(context, "Bakery", Icons.bakery_dining, Colors.brown[400]!),
                  _categoryButton(context, "Condiments", Icons.kitchen, Colors.orange[800]!),
                  _categoryButton(context, "Herbs", Icons.eco, Colors.green[800]!),
                ],
              ),
            ),

            // Search Recipes Button
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                icon: Icon(Icons.search),
                label: Text("Search Recipes"),
                onPressed: () {
                  if (selectedIngredients.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeSearchPage(userIngredients: selectedIngredients),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select at least one ingredient."),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(BuildContext context, String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
      ),
      icon: Icon(icon),
      label: Text(label, style: TextStyle(fontSize: 16)), // Larger text
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryPage(category: label)),
        ).then((selectedIngredient) {
          if (selectedIngredient != null) {
            _addIngredient(selectedIngredient);
          }
        });
      },
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({required this.category});

  @override
  Widget build(BuildContext context) {
    List<String> items = _getItemsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(items[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              trailing: IconButton(
                icon: Icon(Icons.add, color: Colors.green[600]),
                onPressed: () {
                  Navigator.pop(context, items[index]); // Return selected ingredient
                },
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getItemsByCategory(String category) {
    switch (category) {
      case "Fruits":
        return ["Apple", "Banana", "Orange", "Mango", "Strawberry", "Pineapple", "Grapes", "Watermelon"];
      case "Vegetables":
        return ["Carrot", "Broccoli", "Lettuce", "Pepper", "Tomato", "Cucumber", "Spinach", "Potato"];
      case "Dairy":
        return ["Milk", "Cheese", "Yogurt", "Butter", "Cream", "Cottage Cheese", "Sour Cream", "Whipped Cream"];
      case "Meat":
        return ["Chicken", "Beef", "Pork", "Fish", "Lamb", "Turkey", "Duck", "Bacon"];
      case "Grains":
        return ["Rice", "Oats", "Quinoa", "Barley", "Wheat", "Corn", "Buckwheat", "Rye"];
      case "Spices":
        return ["Salt", "Pepper", "Cumin", "Turmeric", "Cinnamon", "Paprika", "Ginger", "Garlic Powder"];
      case "Beverages":
        return ["Water", "Coffee", "Tea", "Juice", "Soda", "Smoothie", "Milkshake", "Energy Drink"];
      case "Snacks":
        return ["Chips", "Cookies", "Crackers", "Popcorn", "Nuts", "Granola Bar", "Chocolate", "Trail Mix"];
      case "Seafood":
        return ["Shrimp", "Crab", "Lobster", "Salmon", "Tuna", "Cod", "Squid", "Oysters"];
      case "Bakery":
        return ["Bread", "Croissant", "Bagel", "Muffin", "Cake", "Donut", "Pie", "Cookies"];
      case "Condiments":
        return ["Ketchup", "Mustard", "Mayonnaise", "Soy Sauce", "Hot Sauce", "BBQ Sauce", "Vinegar", "Honey"];
      case "Herbs":
        return ["Basil", "Cilantro", "Parsley", "Thyme", "Rosemary", "Oregano", "Mint", "Dill"];
      default:
        return [];
    }
  }
}
