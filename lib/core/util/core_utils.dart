import 'package:cloud_firestore/cloud_firestore.dart';

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
    final threeHoursInMs = const Duration(hours: 1).inMilliseconds;

    return differenceMilliseconds < threeHoursInMs;
  }

  static String removeTitleSource(String title){
    List<String>? titleList =
    title.split('-');
    String? finalTitle = titleList![0] ?? "";
    int titleLength = titleList?.length ?? 0;
    for (int i = 1; i < titleLength - 1; i++) {
      finalTitle = "${finalTitle}-${titleList![i]}";
    }
    return finalTitle??title;
  }


}