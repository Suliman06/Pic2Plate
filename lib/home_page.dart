import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'widgets/category_tile.dart';
import 'widgets/recipe_card.dart';
import 'widgets/bottom_nav.dart';
import 'history_page.dart';
import 'favourites_page.dart';
import 'more_page.dart';
import 'add_ingredients_page.dart';
import 'recipe_details_page.dart';
import 'category_recipes_page.dart'; //

class HomePage extends StatefulWidget {
  final bool isPremiumUser;

  const HomePage({super.key, this.isPremiumUser = false});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    HistoryPage(),
    Container(), // Placeholder for Add Ingredients button
    FavouritesPage(),
    MorePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddIngredientsPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, "/auth");
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// HomeContent widget in home_page.dart
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Daily Calorie Intake", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Consumed: 1200 kcal", style: TextStyle(fontSize: 16)),
                Text("Goal: 2000 kcal", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          SizedBox(height: 20),

          Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              CategoryTile(
                icon: Icons.breakfast_dining,
                title: 'Breakfast',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesPage(category: 'Breakfast'),
                    ),
                  );
                },
              ),
              CategoryTile(
                icon: Icons.lunch_dining,
                title: 'Lunch',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesPage(category: 'Lunch'),
                    ),
                  );
                },
              ),
              CategoryTile(
                icon: Icons.dinner_dining,
                title: 'Dinner',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesPage(category: 'Dinner'),
                    ),
                  );
                },
              ),
              CategoryTile(
                icon: Icons.local_pizza,
                title: 'Snacks',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesPage(category: 'Snacks'),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20),

          Text("Featured Recipes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                RecipeCard(
                  image: 'https://via.placeholder.com/150',
                  title: 'Avocado Toast',
                  calories: '250 kcal',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeName: "Avocado Toast",
                          description: "A healthy and delicious breakfast option with avocado on whole-grain toast.",
                          ingredients: [
                            "1 ripe avocado",
                            "2 slices of whole-grain bread",
                            "1 tablespoon olive oil",
                            "Salt and pepper to taste",
                          ],
                          steps: [
                            "Toast the bread until golden brown.",
                            "Mash the avocado in a bowl and mix with olive oil, salt, and pepper.",
                            "Spread the avocado mixture on the toast.",
                            "Serve immediately.",
                          ],
                          isVegetarian: true,
                          allergens: [],
                        ),
                      ),
                    );
                  },
                ),
                RecipeCard(
                  image: 'https://via.placeholder.com/150',
                  title: 'Grilled Chicken',
                  calories: '400 kcal',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeName: "Grilled Chicken",
                          description: "Juicy grilled chicken breast with a side of vegetables.",
                          ingredients: [
                            "2 chicken breasts",
                            "1 tablespoon olive oil",
                            "1 teaspoon paprika",
                            "Salt and pepper to taste",
                          ],
                          steps: [
                            "Preheat the grill to medium-high heat.",
                            "Season the chicken breasts with olive oil, paprika, salt, and pepper.",
                            "Grill the chicken for 6-7 minutes on each side.",
                            "Serve with your favorite vegetables.",
                          ],
                          isVegetarian: false,
                          allergens: [],
                        ),
                      ),
                    );
                  },
                ),
                RecipeCard(
                  image: 'https://via.placeholder.com/150',
                  title: 'Vegan Salad',
                  calories: '300 kcal',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeName: "Vegan Salad",
                          description: "A refreshing salad with mixed greens, nuts, and a tangy dressing.",
                          ingredients: [
                            "2 cups mixed greens",
                            "1/4 cup walnuts",
                            "1/4 cup dried cranberries",
                            "2 tablespoons olive oil",
                            "1 tablespoon balsamic vinegar",
                          ],
                          steps: [
                            "Wash and dry the mixed greens.",
                            "Toss the greens with walnuts and dried cranberries.",
                            "Whisk together olive oil and balsamic vinegar for the dressing.",
                            "Drizzle the dressing over the salad and serve.",
                          ],
                          isVegetarian: true,
                          allergens: ["Nuts"],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}