import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
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
            child: Container(color: DrummTheme.primaryItemColor(context)),
          ),
          // Logo at the center
          Center(child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Image.asset("images/drumm_logo.png",color:DrummTheme.primaryTextColor(context).withAlpha(10),width: double.maxFinite,),
          )),
        ],
      ),
    );
  }
}
