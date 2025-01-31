import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/band_selection_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
class BandSelectContainer extends StatelessWidget {
  BandSelectedCallback onSelect;
  List<MultiSelectCard<dynamic>> bandsCards;
  BandSelectContainer({Key? key, required this.onSelect, required this.bandsCards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double multiSelectRadius = 24;

    return MultiSelectContainer(
      showInListView: true,
      listViewSettings: ListViewSettings(
        padding: EdgeInsets.only(left: 12,right: 12),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        separatorBuilder: (_, __) => const SizedBox(
          width: 8,
        ),
      ),
      controller: MultiSelectController(
        deSelectPerpetualSelectedItems: true,
      ),
      itemsDecoration: MultiSelectDecorations(
        decoration: BoxDecoration(
            color: DrummTheme.primaryItemColor(context),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
        selectedDecoration: BoxDecoration(
            color: DrummTheme.primarySelectedItemColor(context),
            borderRadius: BorderRadius.circular(multiSelectRadius)),
      ),

      items: bandsCards,
      textStyles:  MultiSelectTextStyles(
        selectedTextStyle: TextStyle(
          color: DrummTheme.primarySelectedTextColor(context),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          wordSpacing: 0.7,
          fontFamily: DRUMM_FONT_FAMILY,
        ),
        textStyle: TextStyle(
          color: DrummTheme.primaryTextColor(context),
            fontWeight: FontWeight.w700,
          fontSize: 14,
          wordSpacing: 0.01,
          fontFamily: DRUMM_FONT_FAMILY
        ),
      ),
      onChange: (list, item){
        print("onChanged called");
        onSelect(item);
      },
      singleSelectedItem: true,
      itemsPadding: const EdgeInsets.symmetric(vertical: 4,horizontal: 2),
    );
  }
}
