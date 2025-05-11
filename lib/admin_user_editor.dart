import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserEditor extends StatefulWidget {
  final String userId;

  const AdminUserEditor({super.key, required this.userId});

  @override
  _AdminUserEditorState createState() => _AdminUserEditorState();
}

class _AdminUserEditorState extends State<AdminUserEditor> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _membershipTier = 'Free';
  List<String> _dietaryPreferences = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final doc = await _firestore.collection('Users').doc(widget.userId).get();
  if (!doc.exists) return;

  final rawTier = (doc.data()?['membershipTier'] as String?) ?? 'Free';
  final properTier = rawTier.length > 0
      ? rawTier[0].toUpperCase() + rawTier.substring(1).toLowerCase()
      : 'Free';

  setState(() {
    _nameController.text       = doc['name']    ?? '';
    _emailController.text      = doc['email']   ?? '';
    _membershipTier            = properTier;
    _dietaryPreferences        = List<String>.from(doc['dietaryPreferences'] ?? []);
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                enabled: false, // Email shouldn't be editable
              ),
              DropdownButtonFormField<String>(
                value: _membershipTier,
                items: ['Free', 'Premium', 'Admin']
                    .map((tier) => DropdownMenuItem(
                  value: tier,
                  child: Text(tier),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _membershipTier = value!),
                decoration: const InputDecoration(labelText: "Membership Tier"),
              ),
              const SizedBox(height: 16),
              const Text("Dietary Preferences", style: TextStyle(fontSize: 16)),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text("Vegetarian"),
                    selected: _dietaryPreferences.contains("Vegetarian"),
                    onSelected: (selected) => _togglePreference("Vegetarian", selected),
                  ),
                  FilterChip(
                    label: const Text("Vegan"),
                    selected: _dietaryPreferences.contains("Vegan"),
                    onSelected: (selected) => _togglePreference("Vegan", selected),
                  ),
                  FilterChip(
                    label: const Text("Gluten-Free"),
                    selected: _dietaryPreferences.contains("Gluten-Free"),
                    onSelected: (selected) => _togglePreference("Gluten-Free", selected),
                  ),
                  FilterChip(
                    label: const Text("Dairy-Free"),
                    selected: _dietaryPreferences.contains("Dairy-Free"),
                    onSelected: (selected) => _togglePreference("Dairy-Free", selected),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePreference(String preference, bool selected) {
    setState(() {
      if (selected) {
        _dietaryPreferences.add(preference);
      } else {
        _dietaryPreferences.remove(preference);
      }
    });
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('Users').doc(widget.userId).update({
          'name': _nameController.text,
          'membershipTier': _membershipTier,
          'dietaryPreferences': _dietaryPreferences,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving user: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}