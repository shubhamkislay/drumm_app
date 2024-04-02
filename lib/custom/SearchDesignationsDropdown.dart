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

  SearchDesignationDropdown({Key? key, required this.designations,this.hintText, this.initialDesignation, this.colorTheme, required this.designationsSelectedCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.black,
      child: CustomDropdown<dynamic>.search(
        hintText: hintText??'What\'s your role?',
        items: designations,
        initialItem: initialDesignation,
        //initialItem: designations.elementAt(0),
        decoration: CustomDropdownDecoration(
          closedFillColor: colorTheme??Colors.grey.shade900,
          closedShadow: null,
          closedBorderRadius: BorderRadius.circular(0),
          expandedFillColor: colorTheme??Colors.grey.shade900,
          expandedBorderRadius: BorderRadius.circular(0),
          searchFieldDecoration: SearchFieldDecoration(
            fillColor: COLOR_PRIMARY_DARK,

          ),
          listItemDecoration: ListItemDecoration(
            selectedColor: Colors.blue.shade600,
            splashColor: Colors.blue.shade600
          )
        ),
        onChanged: (value) {
          log('changing value to: ${value}');
          designationsSelectedCallback(value);
          //professionSelectedCallback(value);
        },

      ),
    );
  }
}