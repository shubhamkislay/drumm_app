import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../model/profession.dart';

typedef void DesignationsSelectedCallback(String designation);

class SearchDesignationDropdown extends StatelessWidget {
  List<dynamic> designations;
  DesignationsSelectedCallback designationsSelectedCallback;
  dynamic initialDesignation;
  String? hintText;
  Color? colorTheme;
  bool? isLight;

  SearchDesignationDropdown({Key? key, required this.designations,this.hintText,this.isLight, this.initialDesignation, this.colorTheme, required this.designationsSelectedCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double curve = 14;

    return Container(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(curve),
        child: CustomDropdown<dynamic>.search(
          hintText: hintText??'What\'s your role?',
          items: designations,
          initialItem: initialDesignation,

          //initialItem: designations.elementAt(0),
          decoration: CustomDropdownDecoration(
            closedFillColor: (isLight??false)?Colors.white:Colors.grey.shade900,
            expandedBorderRadius: BorderRadius.circular(curve),
            closedBorderRadius: BorderRadius.circular(curve),
            expandedFillColor: (isLight??false)?Colors.white:Colors.grey.shade900,

            searchFieldDecoration: SearchFieldDecoration(
              fillColor: (isLight??false)?Colors.white:COLOR_PRIMARY_DARK,
              hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600
              ),
              textStyle: TextStyle(
                  color: (isLight??false)?Colors.black:Colors.white,
                  fontWeight: FontWeight.w600
              ),
            ),
            listItemDecoration: ListItemDecoration(
              selectedColor: Colors.blue.shade600,
              splashColor: Colors.blue.shade600
            ),
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600
            ),
            listItemStyle: TextStyle(
                color: (isLight??false)?Colors.black:Colors.white,
                fontWeight: FontWeight.w600
            ),
            headerStyle: TextStyle(
                color: (isLight??false)?Colors.black:Colors.white,
                fontWeight: FontWeight.w600
            ),
          ),
          onChanged: (value) {
            log('changing value to: ${value}');
            designationsSelectedCallback(value);
            //professionSelectedCallback(value);
          },



        ),
      ),
    );
  }
}