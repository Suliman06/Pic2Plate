import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.green[600],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.breakfast_dining, color: Colors.green),
            title: Text("Breakfast - Avocado Toast"),
            subtitle: Text("250 kcal"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.lunch_dining, color: Colors.green),
            title: Text("Lunch - Grilled Chicken"),
            subtitle: Text("400 kcal"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.dinner_dining, color: Colors.green),
            title: Text("Dinner - Vegan Salad"),
            subtitle: Text("300 kcal"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}