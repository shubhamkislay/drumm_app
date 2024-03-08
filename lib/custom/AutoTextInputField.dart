import 'package:flutter/material.dart';

class AutoSizeTextField extends StatefulWidget {
  @override
  _AutoSizeTextFieldState createState() => _AutoSizeTextFieldState();
}

class _AutoSizeTextFieldState extends State<AutoSizeTextField> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically adjust font size based on container width
        double fontSize = constraints.maxWidth * 0.1;

        return TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            hintText: 'Enter text',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}