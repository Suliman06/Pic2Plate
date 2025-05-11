import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddUserPage extends StatefulWidget {
  @override
  _AdminAddUserPageState createState() => _AdminAddUserPageState();
}

class _AdminAddUserPageState extends State<AdminAddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();                           
  final _firestoreService = FirestoreService();                 
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  String _membershipTier = 'free';
  List<String> _dietPrefs = [];

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      
      final user = await _authService.signUp(_emailCtrl.text.trim(), _passCtrl.text);
      if (user == null) throw Exception('Auth sign-up failed');

      // Write full profile in Firestore
      final now = FieldValue.serverTimestamp();
      await _firestoreService.addUser(user.uid, {
        'userId':           user.uid,
        'name':             _nameCtrl.text.trim(),
        'email':            _emailCtrl.text.trim(),
        'membershipTier':   _membershipTier,
        'dietaryPreferences': _dietPrefs,
        'profileImage':     '',
        'createdAt':        now,
        'updatedAt':        now,
      });

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New User")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: Colors.red)),
                ),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[a-z]{2,4}$')
                      .hasMatch(v.toLowerCase())) return 'Invalid email';
                  return null;
                },
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
              ),
              DropdownButtonFormField<String>(
                value: _membershipTier,
                decoration: InputDecoration(labelText: "Tier"),
                items: ['free','premium','admin']
                    .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t[0].toUpperCase() + t.substring(1)),
                    ))
                    .toList(),
                onChanged: (t) => setState(() { _membershipTier = t!; }),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Vegetarian','Vegan','Gluten-Free','Dairy-Free']
                    .map((pref) => FilterChip(
                          label: Text(pref),
                          selected: _dietPrefs.contains(pref),
                          onSelected: (on) {
                            setState(() {
                              if (on) _dietPrefs.add(pref);
                              else _dietPrefs.remove(pref);
                            });
                          },
                        ))
                    .toList(),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? CircularProgressIndicator()
                    : Text("Create User"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
