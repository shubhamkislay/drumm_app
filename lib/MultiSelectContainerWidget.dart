import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';

class MultiSelectContainerWidget extends StatelessWidget {
  Function(List<dynamic> selectedItems, dynamic selectedItem) onSelect;
  List<MultiSelectCard<dynamic>> bandsCards;
  MultiSelectContainerWidget({Key? key,required this.onSelect, required this.bandsCards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double multiSelectRadius = CURVE+3;

    return MultiSelectContainer(
      showInListView: true,
      listViewSettings: ListViewSettings(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        separatorBuilder: (_, __) => const SizedBox(
          width: 8,
        ),
      ),
      suffix: MultiSelectSuffix(
          selectedSuffix: const Padding(
            padding: EdgeInsets.only(left: 1, right: 1),
          ),
          disabledSuffix: const Padding(
            padding: EdgeInsets.only(left: 1),
            child: Icon(
              Icons.do_disturb_alt_sharp,
              size: 14,
            ),
          )),
      controller: MultiSelectController(
        deSelectPerpetualSelectedItems: true,
      ),
      itemsDecoration: MultiSelectDecorations(
        decoration: BoxDecoration(
            color: Colors.grey.shade900,//.withOpacity(0.75), //Colors.grey.shade900,
            // border: Border.all(
            //     color: Colors.grey.shade900.withOpacity(0.5), width: 2.25), //Color(0xff2f2f2f)),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
        selectedDecoration: BoxDecoration(
          color: Colors.white,
            // border: Border.all(
            //     color: Colors.grey.shade900, width: 2.25),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
      ),

      items: bandsCards,
      textStyles: const MultiSelectTextStyles(
        selectedTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          wordSpacing: 0.01,
          fontFamily: APP_FONT_MEDIUM,
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 13,
          wordSpacing: 0.01,
          //fontWeight: FontWeight.w500,
          //fontWeight: FontWeight.bold, // FontWeight.w700,
          fontFamily: APP_FONT_MEDIUM,
        ),
      ),
      onChange: onSelect,
      singleSelectedItem: true,
      itemsPadding: const EdgeInsets.all(0),


    );
  }
}
