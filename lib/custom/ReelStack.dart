library stacked_page_view;

import 'dart:math';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:flutter/material.dart';

/// A Calculator.
class ReelStack extends StatefulWidget {
  ReelStack({
    Key? key,
    required this.index,
    required this.controller,
    required this.child,
    this.animationAxis = Axis.vertical,
    this.curPosition = 0,
    this.backgroundColor = Colors.black,
  }) : super(key: key);
  final int index;
  int curPosition;
  final PageController controller;
  final Widget child;
  final Axis animationAxis;
  final Color backgroundColor;
  @override
  _StackPageViewState createState() => _StackPageViewState();
}

class _StackPageViewState extends State<ReelStack> {
  int currentPosition = 0;
  double pagePosition = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.controller.position.haveDimensions) {
      widget.controller.addListener(() {
        _listener();
      });
    }
  }

  _listener() {
    if (this.mounted)
      setState(() {
        pagePosition =
        num.parse(widget.controller.page!.toStringAsFixed(4)) as double;
        currentPosition = widget.controller.page!.floor();
        widget.curPosition = widget.controller.page!.floor();
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double padding = 32.0;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double delta = pagePosition - widget.index;
          double start = widget.animationAxis == Axis.horizontal
              ? (size.width * 0.105) * delta.abs() * 10
              : (size.height * 0.105) * delta.abs() * 7.5;
          double sides = padding * max(-delta, 0.0);
          double opac = (sides / 0.5) * 0.1;
          double anotheropac = 0.0;
          if (num.parse(opac.toStringAsFixed(2)) <= 1.0) {
            anotheropac = num.parse(opac.toStringAsFixed(3)) * 0.5;
          } else if (num.parse(opac.toStringAsFixed(2)) >= 1.0) {
            anotheropac = 0.5;
          } else {
            anotheropac = num.parse(opac.toStringAsFixed(3)) * 0.07;
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(CURVE),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              padding: widget.curPosition == widget.index
                  ? EdgeInsets.all(0)
                  : EdgeInsets.only(left: 0, right: 0, bottom: 0),
              child: ColorFiltered(
                colorFilter: widget.curPosition  != widget.index
                    ? ColorFilter.mode(
                    Colors.black.withOpacity(anotheropac),
                    BlendMode.darken)
                    : ColorFilter.mode(Colors.black.withOpacity(0.01),
                    BlendMode.darken),
                child: ClipRRect(
                  child: Transform.translate(
                    offset: widget.curPosition  != widget.index
                        ? (widget.animationAxis == Axis.horizontal
                        ? Offset(start, 0)
                        : Offset(0, -start))
                        : Offset(0, 0),
                    child: ClipRRect(
                      borderRadius: widget.curPosition  != widget.index
                          ? BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))
                          : BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Scaffold(body: widget.child),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
