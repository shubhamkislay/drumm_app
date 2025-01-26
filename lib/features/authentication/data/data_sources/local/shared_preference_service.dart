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

  Future<bool> selectedBands() async{

    prefs = await SharedPreferences.getInstance();
    bool selectedBands = prefs.getBool('selectedBands') ?? false;

    return selectedBands;
  }

  void setAuthProvider(String authProvider)async{
    prefs = await SharedPreferences.getInstance();
    prefs.setString("authProvider", authProvider);
  }

  Future<String> getAuthProvider() async{

    prefs = await SharedPreferences.getInstance();
    String authProvider = prefs.getString('authProvider') ?? "apple";

    return authProvider;
  }
}