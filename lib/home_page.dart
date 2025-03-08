import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'widgets/category_tile.dart'; // Import CategoryTile
import 'widgets/recipe_card.dart'; // Import RecipeCard
import 'history_page.dart'; // Import HistoryPage
import 'favourites_page.dart'; // Import FavouritesPage
import 'more_page.dart'; // Import MorePage

class HomePage extends StatefulWidget {
  final bool isPremiumUser;

  const HomePage({Key? key, this.isPremiumUser = false}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0; // Track the selected index for bottom navigation

  // List of pages to display
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(isPremiumUser: widget.isPremiumUser), // Dashboard
      HistoryPage(), // History
      FavouritesPage(), // Favourites
    ];
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Navigate to the MorePage when "More" tab is clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MorePage()),
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
      body: _pages[_selectedIndex], // Display selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Highlight selected item
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Handle item taps
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

// Home Content with Premium User Check
class HomeContent extends StatelessWidget {
  final bool isPremiumUser;

  const HomeContent({Key? key, required this.isPremiumUser}) : super(key: key);

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

          if (isPremiumUser) ...[
            Text("🎉 You are a Premium User! 🎉", style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 20),
          ],

          Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              CategoryTile(icon: Icons.breakfast_dining, title: 'Breakfast', color: Colors.orange),
              CategoryTile(icon: Icons.lunch_dining, title: 'Lunch', color: Colors.green),
              CategoryTile(icon: Icons.dinner_dining, title: 'Dinner', color: Colors.blue),
              CategoryTile(icon: Icons.local_pizza, title: 'Snacks', color: Colors.purple),
            ],
          ),
          SizedBox(height: 20),

          Text("Featured Recipes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                RecipeCard(image: 'https://via.placeholder.com/150', title: 'Avocado Toast', calories: '250 kcal'),
                RecipeCard(image: 'https://via.placeholder.com/150', title: 'Grilled Chicken', calories: '400 kcal'),
                RecipeCard(image: 'https://via.placeholder.com/150', title: 'Vegan Salad', calories: '300 kcal'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
