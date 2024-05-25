import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom/constants/Constants.dart';
import 'model/StateItem.dart';

class StatsDescriptionBox extends StatefulWidget {
  String tutorialMessage;
  String tutorialMessageTitle;
  String tutorialImageAsset;
  String? type;
  String boxType;
  bool? autoUpdate = false;
  String? confirmMessage;
  Color? confirmColor;
  VoidCallback? onConfirm;
  VoidCallback? onCancel;
  List<ChartLayer>? chartLayer;
  List<StatsItem>? stateList;
  int? magnitude;
  ValueNotifier<double>? valueNotifier = ValueNotifier(1);
  bool? checkLevel = false;
  StatsDescriptionBox(
      {Key? key,
      required this.tutorialMessage,
      required this.tutorialMessageTitle,
      required this.tutorialImageAsset,
      required this.boxType,
      this.type,
      this.autoUpdate,
        this.magnitude,
      this.confirmMessage,
      this.confirmColor,
        this.valueNotifier,
        this.checkLevel,
      this.stateList,
      this.chartLayer,
      this.onCancel,
      this.onConfirm})
      : super(key: key);

  @override
  State<StatsDescriptionBox> createState() => _StatsDescriptionBoxState();
}

class _StatsDescriptionBoxState extends State<StatsDescriptionBox> {

  double horizontalPadding = 24;

  @override
  Widget build(BuildContext context) {
    String confirmMsg = widget.confirmMessage ?? "Close";
    int chartLayerSize = widget.chartLayer?.length??0;

    double level = widget.magnitude?.toDouble()??0;
    bool openLevel = widget.checkLevel??false;

    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      surfaceTintColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Container(
        height: 135,
        width: 135,
        child:(chartLayerSize>0)? Chart(
          layers: widget.chartLayer ?? [],
        ): (openLevel)?
        DashedCircularProgressBar.aspectRatio(
          aspectRatio: 1, // width ÷ height
          valueNotifier: widget.valueNotifier??ValueNotifier<double>(1),
          progress: level,
          // startAngle: 225,
          // sweepAngle: 270,
          foregroundColor: Colors.lightBlueAccent,
          backgroundColor: Colors.grey.shade800
              .withOpacity(0.25),
          foregroundStrokeWidth: 18,
          backgroundStrokeWidth: 18,
          animation: true,
          seekSize: 0,
          seekColor: Colors.grey.shade900,
        ):Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade800.withOpacity(0.35)
          ),
          child: Image.asset(
            "images/drumm_logo.png",
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
      title: Column(
        children: [
          Text(
            widget.type ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            widget.tutorialMessageTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0,vertical: 12),
      iconPadding: const EdgeInsets.all(24),
      content: Container(
        padding:  EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(

                padding:  EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  widget.tutorialMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              SizedBox(height: 24,),
              if (widget.chartLayer!.isNotEmpty && widget.stateList!.isNotEmpty)
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: widget.stateList!
                        .map((item) => CategoryColorItem(item))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding:  EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: 24),
      actions: [
        GestureDetector(
          onTap: () {
            try {
              widget.onConfirm!();
            } catch (e) {
              print("You've not set onConfirm callback");
            }
            Navigator.pop(context);
          },
          child: Container(
            padding:  EdgeInsets.symmetric(vertical: 12, horizontal: horizontalPadding),
            width: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.35),
                //gradient: LinearGradient(colors: JOIN_COLOR),
                borderRadius: BorderRadius.circular(24)),
            child: Text(
              confirmMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
      titlePadding:EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: 12) ,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.stateList!.isNotEmpty) {
      setColorMaps();
    }
  }

  void setColorMaps() {}
}

class CategoryColorItem extends StatelessWidget {
  final StatsItem item;

  CategoryColorItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24.0,
          height: 12.0,

          decoration: BoxDecoration(
              color: item.itemColor,
            borderRadius: BorderRadius.circular(16)
          ),
        ),
        SizedBox(width: 4.0),
        Text(
          item.category??"",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12
          ),
        ),
      ],
    );
  }
}
