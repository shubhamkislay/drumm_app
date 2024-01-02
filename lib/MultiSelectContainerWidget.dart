import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';

class MultiSelectContainerWidget extends StatelessWidget {
  Function(List<dynamic> selectedItems, dynamic selectedItem) onSelect;
  List<MultiSelectCard<dynamic>> bandsCards;
  MultiSelectContainerWidget({Key? key,required this.onSelect, required this.bandsCards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double multiSelectRadius = 14;

    return MultiSelectContainer(
      showInListView: true,
      listViewSettings: ListViewSettings(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        separatorBuilder: (_, __) => const SizedBox(
          width: 4,
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
            color: Colors.black, //Colors.grey.shade900,
            border: Border.all(
                color: Colors.black, width: 2), //Color(0xff2f2f2f)),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
        selectedDecoration: BoxDecoration(
            gradient:  LinearGradient(colors: [
              Colors.black, //Colors.blue.shade600,
              Colors.black, //Colors.blue.shade800, //Colors.cyan,
            ]),
            border: Border.all(
                color: Colors.grey.shade900, width: 2.5),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
      ),
      items: bandsCards,
      textStyles: const MultiSelectTextStyles(
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: APP_FONT_BOLD,
        ),
        textStyle: TextStyle(
          color: Colors.white30,
          fontSize: 16,
          //fontWeight: FontWeight.bold, // FontWeight.w700,
          fontFamily: APP_FONT_BOLD,
        ),
      ),
      onChange: onSelect,
      singleSelectedItem: true,
      itemsPadding: const EdgeInsets.all(0),
    );
  }
}
