import 'package:flutter/material.dart';

import '../model/profession.dart';
import '../theme/theme_constants.dart';
import 'DrummChipList.dart';
import 'helper/firebase_db_operations.dart';
typedef SelectedCallback = void Function(String  selectedDesignation,Profession selectedProfession);
class ProfessionChipSelectionWidget extends StatefulWidget {
  SelectedCallback selectedCallback;
   ProfessionChipSelectionWidget({super.key,required this.selectedCallback});

  @override
  State<ProfessionChipSelectionWidget> createState() => _ProfessionChipSelectionWidgetState();
}

class _ProfessionChipSelectionWidgetState extends State<ProfessionChipSelectionWidget> {

  Widget chipWidget = Container();
  Map<String, Profession> designationProfessionMapping = Map();

  @override
  Widget build(BuildContext context) {

    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            chipWidget,
            const SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfessions();
  }

  void getProfessions() async {
    List<Profession> fetchProfessions =
    await FirebaseDBOperations.getProfessions();
    List<Widget> chipWidgetChildren = [];
    for(Profession profession in fetchProfessions){
      List<dynamic> fDesignations = profession.designations??[];
      List<String> fetchDesignations = [];
      int? selectIndex;
      for(dynamic designation in fDesignations) {
        fetchDesignations?.add(designation.toString());
        designationProfessionMapping["${designation}"] = profession;
      }
      chipWidgetChildren.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 6),
        child: Text("${profession.departmentName}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
      ));
      chipWidgetChildren.add(SizedBox(height: 4,));
      chipWidgetChildren.add(Container(
        padding:  const EdgeInsets.symmetric(horizontal: 14,vertical: 6),
        alignment: Alignment.centerLeft,
        child: ChipList(
          shouldWrap: true,
          showCheckmark: true,//(selectedIndex==0)?false:true,
          listOfChipNames: fetchDesignations,
          activeBgColorList:[const Color(COLOR_PRIMARY_VAL)],//(selectedIndex==0)?[Colors.white]: [Color(COLOR_PRIMARY_VAL)],
          inactiveBgColorList: [Colors.grey.shade800.withOpacity(0.5)],
          inactiveBorderColorList: [Colors.transparent],
          activeTextColorList: [Colors.white],//(selectedIndex==0)?[Colors.black]: [Colors.white],
          extraOnToggle: (index) {
            FocusScope.of(context).unfocus();
            widget.selectedCallback(fetchDesignations.elementAt(index),designationProfessionMapping["${fetchDesignations.elementAt(index)}"] ??
                Profession());
          },
          inactiveTextColorList: [Colors.white70],
          listOfChipIndicesCurrentlySeclected: [selectIndex],
          activeBorderColorList: [const Color(COLOR_PRIMARY_VAL)],
        ),
      ));
      chipWidgetChildren.add(SizedBox(height: 12,));

    }
    setState(() {
      chipWidget = Column(children: chipWidgetChildren,crossAxisAlignment: CrossAxisAlignment.start,);
    });



  }

}
