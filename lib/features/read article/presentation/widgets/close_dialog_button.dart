import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class CloseDialogButton extends StatelessWidget {
  CloseDialogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.selection);
        context.pop();
      },
      child: Container(
        height: 36,
        width: 36,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: DrummTheme.primaryDarkItemColor.withAlpha(150),
            borderRadius: BorderRadius.circular(24)),
        child: Icon(
          color: DrummTheme.primaryTextColorDark,
          Icons.keyboard_arrow_down_rounded,
        ),
      ),
    );
  }
}
