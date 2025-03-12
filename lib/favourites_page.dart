import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.green[600],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text("Avocado Toast"),
            subtitle: Text("250 kcal"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to recipe details
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text("Grilled Chicken"),
            subtitle: Text("400 kcal"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to recipe details
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text("Vegan Salad"),
            subtitle: Text("300 kcal"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to recipe details
            },
          ),
        ],
      ),
    );
  }
}