import 'package:flutter/material.dart';

void showPremiumPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Go Premium!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text("Try a 30-day premium pass for free!"),
        actions: [
          TextButton(
            child: Text("No Thanks"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text("Try Free"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}