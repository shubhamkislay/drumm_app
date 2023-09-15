import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class AppleWatchMenu extends StatefulWidget {
  @override
  _AppleWatchMenuState createState() => _AppleWatchMenuState();
}

class _AppleWatchMenuState extends State<AppleWatchMenu> {
  final List<IconData> randomIcons = [
    CupertinoIcons.bolt_fill,
    CupertinoIcons.globe,
    CupertinoIcons.heart_fill,
    CupertinoIcons.home,
    CupertinoIcons.music_albums_fill,
    CupertinoIcons.person_fill,
    CupertinoIcons.sun_max_fill,
    CupertinoIcons.tag_fill,
    CupertinoIcons.trash_fill,
  ];

  final List<String> randomLabels = [
    'Icon 1',
    'Icon 2',
    'Icon 3',
    'Icon 4',
    'Icon 5',
    'Icon 6',
    'Icon 7',
    'Icon 8',
    'Icon 9',
  ];

  final List<Color> randomColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apple Watch Menu'),
      ),
      body: Center(
        child: Container(
          width: 600, // Adjust the width as needed
          height: 600, // Adjust the height as needed
          child: Wrap(
            spacing: 50,
            runSpacing: 50,
            children: List.generate(9, (index) {
              final randomIndex = index % randomIcons.length;
              final randomIcon = randomIcons[randomIndex];
              final randomLabel = randomLabels[randomIndex];
              final randomColor = randomColors[randomIndex];

              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: randomColor,
                ),
                child: CupertinoButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        randomIcon,
                        color: CupertinoColors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        randomLabel,
                        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          color: CupertinoColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}









