import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CoreUtils{

  static bool isTimestampWithinThreeHours(Timestamp? firebaseTimestamp) {
    // Use a default older date if firebaseTimestamp is null
    firebaseTimestamp ??= Timestamp.fromDate(DateTime(2000));

    // Get the current timestamp
    final currentTimestamp = Timestamp.now();

    // Compute the difference in milliseconds
    final differenceMilliseconds = currentTimestamp.millisecondsSinceEpoch -
        firebaseTimestamp.millisecondsSinceEpoch;

    // Compare against a 3-hour Duration
    final threeHoursInMs = const Duration(hours: 2).inMilliseconds;

    return differenceMilliseconds < threeHoursInMs;
  }

  static String removeTitleSource(String title) {
    int lastDashIndex = title.lastIndexOf('-');
    if (lastDashIndex == -1) {
      // No dash found, return original
      return title;
    }
    // Everything up to (but not including) the last dash
    return title.substring(0, lastDashIndex);
  }

// 1. Returns day like "Sunday", "Monday", etc.
  static String getWeekDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

// 2. Returns time like "6:00 AM", "7:30 PM", etc.
  static String getFormattedTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

// 3. Returns date like "26th Feb"
  static String getFormattedDate(DateTime date) {
    int day = date.day;
    String ordinalSuffix = _getOrdinalSuffix(day);
    String monthAbbreviation = DateFormat('MMM').format(date);
    return '$day$ordinalSuffix $monthAbbreviation';
  }

// Helper function to determine ordinal suffix for a day
  static String _getOrdinalSuffix(int day) {
    // Special case for 11, 12, and 13
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }



}