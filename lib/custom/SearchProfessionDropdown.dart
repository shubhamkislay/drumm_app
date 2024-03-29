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

  SearchProfessionDropdown({Key? key, required this.professions, this.initialProfession, required this.professionSelectedCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<Profession>.search(
      hintText: 'Select your field of expertise',
      items: professions,
      initialItem: initialProfession,
      excludeSelected: false,
      validateOnChange: true,
      decoration: CustomDropdownDecoration(
        closedFillColor: Colors.grey.shade900,

            closedShadow: null,
         closedBorderRadius: BorderRadius.circular(16),
        expandedFillColor: Colors.grey.shade900,
        expandedBorderRadius: BorderRadius.circular(16),
        searchFieldDecoration: SearchFieldDecoration(
          fillColor: COLOR_PRIMARY_DARK,
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
    );
  }
}