import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  CustomDropdownButton({
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Select",
      ),
      value: value,
      onChanged: onChanged,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please make a selection';
        }
        return null;
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
