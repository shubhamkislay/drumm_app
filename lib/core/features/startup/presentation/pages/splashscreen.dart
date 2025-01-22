import 'package:drumm_app/config/constants.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Full-screen background color
          SizedBox.expand(
            child: Container(color: Colors.black),
          ),
          // Logo at the center
          Image.asset(
            DRUMM_LOGO,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }
}
