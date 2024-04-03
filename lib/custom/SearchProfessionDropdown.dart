import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../model/profession.dart';

typedef void ProfessionSelectedCallback(Profession profession);

class SearchProfessionDropdown extends StatelessWidget {
  List<Profession> professions;
  ProfessionSelectedCallback professionSelectedCallback;
  Profession? initialProfession;
  String? hintText;
  Color? colorTheme;
  bool? isLight;

  SearchProfessionDropdown({Key? key, required this.professions, this.hintText, this.isLight,this.initialProfession, this.colorTheme, required this.professionSelectedCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double curve = 16;
    return Container(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(curve),
        child: CustomDropdown<Profession>.search(
          hintText: hintText??'Select your field of expertise',
          items: professions,
          initialItem: initialProfession,
          excludeSelected: false,
          validateOnChange: true,
          decoration: CustomDropdownDecoration(
            closedFillColor: (isLight??false)?Colors.white:Colors.grey.shade900,
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
          ),
          onChanged: (value) {
            //log('changing value to: ${value.}');
            professionSelectedCallback(value);
          },
        ),
      ),
    );
  }
}