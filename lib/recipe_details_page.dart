import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

List<String> ensureStringList(dynamic items) {
  if (items == null) return [];
  if (items is String) return [items];
  if (items is List) return items.map((e) => e.toString()).toList();
  return [];
}

class RecipeDetailsPage extends StatefulWidget {
  final String recipeId;
  final String recipeName;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final bool isVegetarian;
  final List<String> allergens;

  const RecipeDetailsPage({
    required this.recipeId,
    required this.recipeName,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.isVegetarian,
    required this.allergens,
  });

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage>
    with SingleTickerProviderStateMixin {
  bool isFavourite = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    checkIfFavourite();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> checkIfFavourite() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('Favorites')
        .where('userId', isEqualTo: uid)
        .where('recipeId', isEqualTo: widget.recipeId)
        .get();

    setState(() {
      isFavourite = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> toggleFavourite() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef = FirebaseFirestore.instance.collection('Favorites');

    final snapshot = await favRef
        .where('userId', isEqualTo: uid)
        .where('recipeId', isEqualTo: widget.recipeId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites')),
      );
    } else {
      await favRef.add({
        'userId': uid,
        'recipeId': widget.recipeId,
        'addedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites')),
      );
    }

    _animationController.forward().then((_) => _animationController.reverse());
    checkIfFavourite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeName),
        backgroundColor: Colors.green[600],
        actions: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: IconButton(
              icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: toggleFavourite,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipeName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (widget.isVegetarian)
                  _buildTag("Vegetarian", Colors.green),
                for (var allergen in widget.allergens)
                  _buildTag("Contains $allergen", Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Ingredients",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]),
            ),
            const SizedBox(height: 10),
            ...widget.ingredients.map(_buildListItem).toList(),
            const SizedBox(height: 30),
            Text(
              "Steps",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]),
            ),
            const SizedBox(height: 10),
            ...widget.steps.map(_buildListItem).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: TextStyle(color: Colors.white),
    );
  }

  Widget _buildListItem(String text) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text(text),
      ),
    );
  }
}


class FavouritesPage extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Favorites')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final favDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final recipeId = favDocs[index]['recipeId'];
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('recipes')
                    .doc(recipeId)
                    .get(),
                builder: (context, recipeSnap) {
                  if (!recipeSnap.hasData) return Container();
                  final recipe = recipeSnap.data!;

                  return ListTile(
                    leading: Icon(Icons.favorite, color: Colors.red),
                    title: Text(recipe['description'] ?? 'No description'),
                    subtitle: Text("${recipe['calories']} kcal"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailsPage(
                            recipeId: recipe.id,
                            recipeName: recipe['title'] ?? 'Recipe',
                            description: recipe['description'] ?? '',
                            ingredients: ensureStringList(recipe['ingredients']),
                            steps: ensureStringList(recipe['steps']),
                            isVegetarian: recipe['isVegetarian'] == 'true',
                            allergens: ensureStringList(recipe['allergens']),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}