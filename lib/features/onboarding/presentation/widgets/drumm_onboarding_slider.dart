library flutter_onboarding_slider;

import 'package:drumm_app/features/authentication/auth_constants.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/background.dart';
import 'package:flutter_onboarding_slider/background_body.dart';
import 'package:flutter_onboarding_slider/background_controller.dart';
import 'package:flutter_onboarding_slider/background_final_button.dart';
import 'package:flutter_onboarding_slider/onboarding_navigation_bar.dart';
import 'package:flutter_onboarding_slider/page_offset_provider.dart';
import 'package:provider/provider.dart';

class FlutterOnBoardingSlider extends StatefulWidget {
  /// Number of total pages.
  final int totalPage;

  /// NavigationBars color.
  final Color headerBackgroundColor;


  /// The speed of the animation for the [background].
  final double speed;

  /// Background Color of whole screen apart from the NavigationBar.
  final Color? pageBackgroundColor;

  /// Background Gradient of whole screen apart from the NavigationBar.
  final Gradient? pageBackgroundGradient;

  /// Callback to be executed when clicked on the [finishButton].
  final Function? onFinish;

  /// NavigationBar trailing widget when on last screen.
  final Widget? trailing;

  /// NavigationBar trailing widget when not on last screen.
  final Widget? skipTextButton;

  /// Callback to be executed when clicked on the last pages bottom button.
  final Function? trailingFunction;

  /// Style of the bottom button on the last page.
  final FinishButtonStyle? finishButtonStyle;

  /// Text inside last pages bottom button.
  final String? finishButtonText;

  /// Text style for text inside last pages bottom button.
  final TextStyle finishButtonTextStyle;

  /// Color of the bottom page indicators.
  final Color? controllerColor;

  /// Toggle bottom button.
  final bool addButton;

  /// Center [background].
  /// Do not pass [imageHorizontalOffset] when you turn this flag to true otherwise that will get ignored
  final bool centerBackground;

  /// Toggle bottom page controller visibilty.
  final bool addController;

  /// Defines the vertical offset of the [background].
  final double imageVerticalOffset;

  /// Defines the horizontal offset of the [background].
  /// Do not set [centerBackground] to true when you use this property otherwise this will get ignored
  final double imageHorizontalOffset;

  /// leading widget in the navigationBar.
  final Widget? leading;

  /// middle widget in the navigationBar.
  final Widget? middle;

  /// Whether has the floating action button to skip and the finish button
  final bool hasFloatingButton;

  /// Whether has the skip button in the bottom;
  final bool hasSkip;

  /// icon on the skip button
  final Icon skipIcon;

  /// is the indicator located on top of the screen
  final bool indicatorAbove;

  /// distance of indicator from bottom
  final double indicatorPosition;

  /// override the function for kip button in the navigator.
  final Function? skipFunctionOverride;

  const FlutterOnBoardingSlider({
    this.totalPage = 4,
    this.speed = 1.8,
    this.onFinish,
    this.trailingFunction,
    this.trailing,
    this.skipTextButton = const Text(
      'Skip',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    this.pageBackgroundColor = Colors.black,
    this.pageBackgroundGradient,
    this.headerBackgroundColor = Colors.black,
    this.finishButtonStyle = const FinishButtonStyle(
      backgroundColor: COLOR_PRIMARY_DARK,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
    ),
    this.finishButtonText = GET_STARTED,
    this.controllerColor,
    this.addController = true,
    this.centerBackground = true,
    this.addButton = true,
    this.imageVerticalOffset = 0,
    this.imageHorizontalOffset = 0,
    this.leading,
    this.middle,
    this.hasFloatingButton = true,
    this.hasSkip = true,
    this.finishButtonTextStyle = const TextStyle(
      color: Colors.white,
      fontFamily: APP_FONT_BOLD,
    ),
    this.skipIcon = const Icon(
      Icons.arrow_forward,
      color: Colors.white,
    ),
    this.indicatorAbove = false,
    this.indicatorPosition = 90,
    this.skipFunctionOverride,
  });

  @override
  _FlutterOnBoardingSliderState createState() =>
      _FlutterOnBoardingSliderState();
}

class _FlutterOnBoardingSliderState extends State<FlutterOnBoardingSlider> {
  final PageController _pageController = PageController(initialPage: 0);

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PageOffsetNotifier(_pageController),
      child: Scaffold(
        backgroundColor: widget.pageBackgroundColor ?? null,
        floatingActionButton: widget.hasFloatingButton
            ? BackgroundFinalButton(
                buttonTextStyle: widget.finishButtonTextStyle,
                skipIcon: widget.skipIcon,
                addButton: widget.addButton,
                currentPage: _currentPage,
                pageController: _pageController,
                totalPage: widget.totalPage,
                onPageFinish: widget.onFinish,
                finishButtonStyle: widget.finishButtonStyle,
                buttonText: widget.finishButtonText,
                hasSkip: widget.hasSkip,
              )
            : SizedBox.shrink(),
        body: CupertinoPageScaffold(
          backgroundColor: Colors.black,
          navigationBar: OnBoardingNavigationBar(
            skipFunctionOverride: widget.skipFunctionOverride,
            leading: widget.leading,
            middle: widget.middle,
            totalPage: widget.totalPage,
            currentPage: _currentPage,
            onSkip: _onSkip,
            headerBackgroundColor: widget.headerBackgroundColor,
            onFinish: widget.trailingFunction,
            finishButton: widget.trailing,
            skipTextButton: widget.skipTextButton,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: widget.pageBackgroundGradient ?? null,
              color: widget.pageBackgroundColor ?? null,
            ),
            child: SafeArea(
              child: Background(
                centerBackground: widget.centerBackground,
                imageHorizontalOffset: widget.imageHorizontalOffset,
                imageVerticalOffset: widget.imageVerticalOffset,
                background: getBackgroundList(),
                speed: widget.speed,
                totalPage: widget.totalPage,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: BackgroundBody(
                          controller: _pageController,
                          function: slide,
                          totalPage: widget.totalPage,
                          bodies: getPageBodies(context),
                        ),
                      ),
                      widget.addController
                          ? BackgroundController(
                              hasFloatingButton: widget.hasFloatingButton,
                              indicatorPosition: widget.indicatorPosition,
                              indicatorAbove: widget.indicatorAbove,
                              currentPage: _currentPage,
                              totalPage: widget.totalPage,
                              controllerColor: widget.controllerColor,
                            )
                          : SizedBox.shrink(),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Slide to Next Page.
  void slide(int page) {
    if(kDebugMode){
      print("Current page is $page");
    }
    setState(() {
      _currentPage = page;
    });
  }

  /// Skip to last Slide.
  void _onSkip() {
    _pageController.jumpToPage(widget.totalPage - 1);
    setState(() {
      _currentPage = widget.totalPage - 1;
    });
  }

  List<Widget> getBackgroundList() {
    double assetSize = 200;

    return IMAGE_PATHS
        .map(
          (path) => Container(
        height: 500,
        width: 300,
        alignment: Alignment.center,
        child: Image.asset(
          path,
          height: assetSize,
          width: assetSize,
          fit: BoxFit.contain,
          color: Colors.white,
        ),
      ),
    )
        .toList();
  }

  List<Widget> getPageBodies(BuildContext context) {
    double textSize = 36;
    return PAGE_CONTENT
        .map(
          (content) => Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: content["title"]!.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: content["title"],
                style: TextStyle(
                  fontFamily: APP_FONT_MEDIUM,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: textSize,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content["description"]!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: APP_FONT_MEDIUM,
                color: Colors.white70,
                fontSize: textSize / 2.25,
              ),
            ),
            const SizedBox(height: 64),
          ],
        )
            : const SizedBox.shrink(),
      ),
    )
        .toList();
  }
}
