import 'package:flutter/material.dart';
import '../service/currency_input.dart';

class CustomInputDialog extends StatelessWidget {
  final String title;
  final String labelText;
  final String initialValue;
  final void Function(double value) onSubmitted;

  const CustomInputDialog({
    required this.title,
    required this.labelText,
    required this.initialValue,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText),
        keyboardType: TextInputType.number,
        inputFormatters: [CurrencyInputFormatter()],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            final raw = controller.text.replaceAll(',', '');
            final parsed = double.tryParse(raw);
            if (parsed != null && parsed >= 0) {
              onSubmitted(parsed);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
