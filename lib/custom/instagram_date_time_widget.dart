import 'package:flutter/material.dart';

import '../theme/theme_constants.dart';

class InstagramDateTimeWidget extends StatelessWidget {
  final String publishedAt;
  double? textSize;
  FontWeight? fontWeight;

  InstagramDateTimeWidget({required this.publishedAt, this.textSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = _parseDateTime(publishedAt);
    String formattedDateTime = _formatDateTime(dateTime);

    return Text(
      formattedDateTime,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontSize: textSize??12,
        fontFamily: APP_FONT_MEDIUM,
        fontWeight: fontWeight??FontWeight.normal,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  DateTime _parseDateTime(String dateTimeString) {
    final startIndex = dateTimeString.indexOf('seconds=') + 8;
    final endIndex = dateTimeString.indexOf(',', startIndex);
    final seconds = int.parse(dateTimeString.substring(startIndex, endIndex));

    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}
