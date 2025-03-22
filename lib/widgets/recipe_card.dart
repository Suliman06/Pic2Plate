// widgets/recipe_card.dart
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String image;
  final String title;
  final String calories;
  final VoidCallback onTap;

  const RecipeCard({
    required this.image,
    required this.title,
    required this.calories,
    required this.onTap,
  });

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = _isNetworkImage(image);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: isNetwork
                  ? Image.network(
                      image,
                      width: 150,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      image,
                      width: 150,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(calories, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
