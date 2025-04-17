import 'package:flutter/material.dart';

Future<String> promptUserForPhoneNumber(BuildContext context) async {
  final TextEditingController _controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Phone Number'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(hintText: '+1 555 555 5555'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                Navigator.of(context).pop(_controller.text.trim());
              }
            },
            child: Text('Continue'),
          ),
        ],
      );
    },
  );
  return result ?? '';
}

Future<String> promptUserForSmsCode(BuildContext context) async {
  final TextEditingController _controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Verification Code'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '6-digit code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                Navigator.of(context).pop(_controller.text.trim());
              }
            },
            child: Text('Verify'),
          ),
        ],
      );
    },
  );
  return result ?? '';
}
