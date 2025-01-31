import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  VoidCallback onPressed;
  SearchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36,
        width: 36,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Image.asset('images/search_btn.png',
            color: DrummTheme.primaryTextColor(context),
            fit: BoxFit.contain),
      ),
    );
  }
}
