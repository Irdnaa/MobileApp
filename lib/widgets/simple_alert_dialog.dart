import 'package:flutter/material.dart';

class SimpleAlertDialog extends StatelessWidget {
  final String title;
  final String message;

  const SimpleAlertDialog({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
