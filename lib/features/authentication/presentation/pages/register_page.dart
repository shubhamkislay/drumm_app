import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  String ? name;
  String ? email;
  RegisterPage({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Register Page"),),
    );
  }
}
