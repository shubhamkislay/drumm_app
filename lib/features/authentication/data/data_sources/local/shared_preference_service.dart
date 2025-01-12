import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService{

  late SharedPreferences prefs;

  Future<bool> isOnboarded() async{

    prefs = await SharedPreferences.getInstance();
    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;

    return isOnboarded;
  }

  void setOnboarded() async{

    prefs = await SharedPreferences.getInstance();
    prefs.setBool("isOnboarded", true);
  }
}