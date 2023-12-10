import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicyTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'By continuing you are accepting the ',
              style: TextStyle(color: Colors.white,fontSize: 10),
            ),
            TextSpan(
              text: 'Policy',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                  fontSize: 10
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURL('https://www.termsfeed.com/live/6bb937e0-0e2f-4d01-8257-5983452d2019');
                },
            ),
            TextSpan(
              text: ' and the ',
              style: TextStyle(color: Colors.white,fontSize: 10),
            ),
            TextSpan(
              text: 'terms & conditions',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                  fontSize: 10
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURL('https://getdrumm.blogspot.com/2023/12/terms-and-conditions-for-drumm.html');
                },
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Policy and Terms'),
      ),
      body: Center(
        child: PolicyTextWidget(),
      ),
    ),
  ));
}
