import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';

class DrummAppBar extends StatefulWidget {
  DrummAppBar({
    Key? key,
    required this.titleText,
    required this.isDark,
    required this.scrollController,
    required this.onPressed,
    required this.iconColor,
    required this.autoJoinDrumms,
    this.scrollOffset = 34,
    this.appBarColor = Colors.white,
    this.boxShadowColor = Colors.black,
    this.titleColor = Colors.black,
    this.titleFontWeight = FontWeight.bold,
  }) : super(key: key);

  final ScrollController scrollController;
  final int scrollOffset;
  final Color appBarColor;
  final Color boxShadowColor;
  final Color titleColor;
  final Color iconColor;
  final String titleText;
  final bool isDark;
  final FontWeight titleFontWeight;
  final VoidCallback onPressed;
final bool autoJoinDrumms;
  @override
  _DrummAppBarState createState() => _DrummAppBarState();
}

class _DrummAppBarState extends State<DrummAppBar>
    with TickerProviderStateMixin {
  double topBarOpacity = 0.0;
  late Animation<double> topBarAnimation;
  late AnimationController animationController;

  double iconContainerHeight = 100.0;


  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    animationController.forward();
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    widget.scrollController.addListener(() {
      if(mounted) {
        if (widget.scrollController.offset >= widget.scrollOffset) {
          if (widget.scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (iconContainerHeight != 0)
              setState(() {
                iconContainerHeight = 0;
              });
          }
          if (widget.scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            if (iconContainerHeight == 0)
              setState(() {
                iconContainerHeight = 100;
              });
          }
          if (topBarOpacity != 0.05) {
            setState(() {
              topBarOpacity = 0.05;
              print("topBarOpacity: $topBarOpacity");
            });
          }
        }
        else if (widget.scrollController.offset <= widget.scrollOffset &&
            widget.scrollController.offset >= 0) {
          if (topBarOpacity !=
              widget.scrollController.offset / widget.scrollOffset &&
              topBarOpacity <= 0.05) {
            if (widget.scrollController.position.userScrollDirection ==
                ScrollDirection.reverse) {
              if (iconContainerHeight != 0)
                setState(() {
                  iconContainerHeight = 0;
                });
            }
            if (widget.scrollController.position.userScrollDirection ==
                ScrollDirection.forward) {
              if (iconContainerHeight == 0)
                setState(() {
                  iconContainerHeight = 100;
                });
            }
            setState(() {
              topBarOpacity =
                  widget.scrollController.offset / widget.scrollOffset;
              print("topBarOpacity: $topBarOpacity");
            });
          }
        }
        else if (widget.scrollController.offset <= 0) {
          if (topBarOpacity != 0.0) {
            setState(() {
              topBarOpacity = 0.0;
              print("topBarOpacity: $topBarOpacity");
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return getAppBarUI(context);
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.scrollController.removeListener(() { });
    print("Called dispose");
    super.dispose();
  }

  Widget getAppBarUI(context) {
    final List<Color> colors = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];

    final List<int> duration = [500, 700, 800, 300];

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[

          // AnimatedContainer(
          //   height: iconContainerHeight,
          //   padding: EdgeInsets.only(
          //       left: 16,
          //       right: 16,
          //       top: 16 - 8.0 * topBarOpacity,
          //       bottom: 12 - 8.0 * topBarOpacity),
          //   duration: Duration(milliseconds: 200),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: <Widget>[
          //       Image.asset(
          //         color: Color(COLOR_PRIMARY_VAL),
          //         width: 35,
          //         "images/logo_background_white.png",
          //         height: 35,
          //       ),
          //       Expanded(
          //         child: Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Text(
          //             widget.titleText,
          //             textAlign: TextAlign.left,
          //             style: Theme.of(context).textTheme.headlineMedium
          //           ),
          //         ),
          //       ),
          //       CircleAvatar(
          //         minRadius: 22,
          //         backgroundColor: Colors.grey.withOpacity(0.2),
          //         child: Image.asset(
          //           color: widget.isDark ? Colors.white: Colors.black,
          //           width: 22,
          //           "images/profile_icon.png",
          //           height: 22,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              padding: EdgeInsets.only(
                  left: 16,
                  right: 2,
                  top: 0,//16 - 8.0 * topBarOpacity,
                  bottom: 0,),//12 - 8.0 * topBarOpacity),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                 if(true) Image.asset(
                    color: widget.iconColor,//Colors.white.withOpacity(0.25),//Color(COLOR_PRIMARY_VAL),
                    width: 42,
                    "images/logo_background_white.png",
                    height: 42,
                  ),
                  if(widget.autoJoinDrumms)SizedBox(
                    height: 12,
                    width: 30,
                    child: MusicVisualizer(
                      barCount: 4,
                      colors: colors,
                      duration: duration,
                    ),
                  ),
                  if(false)Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                          widget.titleText,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[

                              Shadow(
                                offset: Offset(0.0, 2.0),
                                blurRadius: 8.0,
                                color: Colors.grey.shade900.withOpacity(0.05)),

                            ],
                          ),
                      ),
                    ),
                  ),
                 if(false) RoundedButton(
                    padding: 12,
                    height: 45,
                    color: Colors.white,
                    bgColor: Colors.grey.withOpacity(0.25),
                    onPressed: widget.onPressed,
                    assetPath: 'images/post.png',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 18,//MediaQuery.of(context).padding.top,
          ),
          // Padding(
          //   padding: EdgeInsets.only(
          //       left: 16,
          //       right: 16,
          //       top: 10.0 * topBarOpacity,
          //       bottom: 12 - 8.0 * topBarOpacity),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: "What's on your mind?"
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
