import 'package:drumm_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom/helper/connect_channel.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Function to handle logout
  void _logout() {
    // Add your logout logic here
    if(ConnectToChannel.engineInitialized)
      ConnectToChannel.disposeEngine();
    removedPreferences();
    FirebaseAuth.instance.signOut().then(
            (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()), (_) => false));
    print('Logged out'); // You can replace this with your actual logout logic
  }

  // Function to open a web page
  Future<void> _openWebPage(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void removedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Privacy Policy'),
            onTap: () {
              _openWebPage('https://www.termsfeed.com/live/6bb937e0-0e2f-4d01-8257-5983452d2019');
            },
          ),
          ListTile(
            title: Text('Terms and Conditions'),
            onTap: () {
              _openWebPage('https://getdrumm.blogspot.com/2023/12/terms-and-conditions-for-drumm.html');
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              _logout();
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsPage(),
  ));
}
