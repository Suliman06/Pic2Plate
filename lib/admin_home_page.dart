import 'package:flutter/material.dart';
import 'admin_nav_bar.dart';
import 'admin_recipes_page.dart';
import 'admin_users_page.dart';
import 'admin_categories_page.dart';
import 'admin_recipe_editor.dart';
import 'settings_page.dart';
import '../auth_service.dart';
import 'admin_add_user.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  // Admin pages for navigation
  final List<Widget> _pages = [
    AdminDashboard(),
    AdminRecipesPage(),
    AdminUsersPage(),
    AdminCategoriesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, "/auth");
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Admin dashboard content
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Admin Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildStatCard("Total Users", "1,234", Icons.people, Colors.blue),
              _buildStatCard("Total Recipes", "567", Icons.restaurant, Colors.green),
              _buildStatCard("Categories", "12", Icons.category, Colors.orange),
              _buildStatCard("Active Today", "89", Icons.trending_up, Colors.purple),
            ],
          ),
          const SizedBox(height: 30),

          // Quick actions
          const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text("Add Recipe"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminRecipeEditor()),
                  );
                },
              ),
           ActionChip(
  avatar: Icon(Icons.person_add, size: 18),
  label: const Text("Add User"),
     onPressed: () async {
   final created = await Navigator.push<bool>(
    context,
      MaterialPageRoute(builder: (_) => AdminAddUserPage()),
    );
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User successfully created!")),
      );
    }   },


              ),
              ActionChip(
                avatar: const Icon(Icons.category, size: 18),
                label: const Text("Add Category"),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AdminCategoriesPage()),
  );
},

              ),
              ActionChip(
                avatar: const Icon(Icons.settings, size: 18),
                label: const Text("Settings"),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SettingsPage()),
  );
},

              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}