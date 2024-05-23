import 'package:flutter/material.dart';

class StatsItem {
  int? score = 0;
  String? category;
  Color? itemColor;

  StatsItem(int? sc, String? cat, Color? ic){
    score = sc;
    category = cat;
    itemColor = ic;
  }

}
