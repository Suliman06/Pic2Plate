import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AdminNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Recipes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}