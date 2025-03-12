// widgets/category_tile.dart
import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap; // Add this line

  const CategoryTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap, // Use the onTap callback
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}