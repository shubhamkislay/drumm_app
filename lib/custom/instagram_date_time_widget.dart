import 'package:flutter/material.dart';

class InstagramDateTimeWidget extends StatelessWidget {
  final String publishedAt;

  InstagramDateTimeWidget({required this.publishedAt});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = _parseDateTime(publishedAt);
    String formattedDateTime = _formatDateTime(dateTime);

    return Text(
      formattedDateTime,
      style: TextStyle(
        fontSize: 12,
        //fontFamily: "rubik",
        color: Colors.white54
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
