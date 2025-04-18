import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.green[600],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.green),
            title: Text("Notifications"),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode, color: Colors.green),
            title: Text("Dark Mode"),
            trailing: Switch(value: false, onChanged: (value) {}),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.green),
            title: Text("Language"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.security, color: Colors.green),
            title: Text("Privacy & Security"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.green),
            title: Text("Help & Support"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}