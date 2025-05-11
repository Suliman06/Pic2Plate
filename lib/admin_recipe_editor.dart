import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRecipeEditor extends StatefulWidget {
  final String? recipeId;

  const AdminRecipeEditor({super.key, this.recipeId});

  @override
  _AdminRecipeEditorState createState() => _AdminRecipeEditorState();
}

class _AdminRecipeEditorState extends State<AdminRecipeEditor> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  bool _isVegetarian = false;
  String _allergens = '';
  String _category = 'Breakfast';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _caloriesController = TextEditingController();
    _ingredientsController = TextEditingController();
    _stepsController = TextEditingController();

    if (widget.recipeId != null) {
      _loadRecipeData();
    }
  }

  Future<void> _loadRecipeData() async {
    final doc = await _firestore.collection('recipes').doc(widget.recipeId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['title'] ?? data['name'] ?? '';
        _descriptionController.text = doc['description'];
        _caloriesController.text = doc['calories'].toString();
        _ingredientsController.text = (doc['ingredients'] as List).join('\n');
        _stepsController.text = (doc['steps'] as List).join('\n');
        _isVegetarian = doc['isVegetarian'] ?? false;
        _allergens = (doc['allergens'] as List).join(', ');
        _category = doc['category'] ?? 'Breakfast';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeId == null ? 'Add Recipe' : 'Edit Recipe'),
        actions: [
          if (widget.recipeId != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Recipe Name"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 2,
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: "Calories"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              SwitchListTile(
                title: const Text("Vegetarian"),
                value: _isVegetarian,
                onChanged: (value) => setState(() => _isVegetarian = value),
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: "Ingredients (one per line)",
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: "Steps (one per line)",
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _allergens,
                decoration: const InputDecoration(
                  labelText: "Allergens (comma separated)",
                ),
                onChanged: (value) => _allergens = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text("Save Recipe"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeData = {
        'title': _nameController.text,
        'description': _descriptionController.text,
        'calories': int.parse(_caloriesController.text),
        'ingredients': _ingredientsController.text.split('\n'),
        'steps': _stepsController.text.split('\n'),
        'isVegetarian': _isVegetarian,
        'allergens': _allergens.split(',').map((e) => e.trim()).toList(),
        'category': _category,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        if (widget.recipeId == null) {
          await _firestore.collection('recipes').add(recipeData);
        } else {
          await _firestore.collection('recipes').doc(widget.recipeId).update(recipeData);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: $e')),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Recipe"),
          content: const Text("Are you sure you want to delete this recipe?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _firestore.collection('recipes').doc(widget.recipeId).delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
}