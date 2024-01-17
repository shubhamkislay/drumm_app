import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class CustomSwiper extends StatefulWidget {
  @override
  _CustomSwiperState createState() => _CustomSwiperState();
}

class _CustomSwiperState extends State<CustomSwiper>
    with TickerProviderStateMixin {
  double _swipeProgress = 0.0;
  bool _swipeComplete = false;
  late AnimationController _animationController;
  List<double> numList = [1, 2, 3, 4, 5, 6];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  void _updateSwipeProgress(DragUpdateDetails details) {
    setState(() {
      _swipeProgress =
          (details.primaryDelta ?? 0) / MediaQuery.of(context).size.width;
      _swipeProgress = _swipeProgress.clamp(0.0, 1.0);
    });
  }

  void _completeSwipe(DragEndDetails details) {
    if (_swipeProgress > 0.5) {
      setState(() {
        _swipeComplete = true;
      });
      _animationController.forward().then((_) {
        Future.delayed(Duration(seconds: 1), () {
          _animationController.reverse();
          setState(() {
            _swipeComplete = false;
          });
        });
      });
    } else {
      setState(() {
        _swipeComplete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardSwiper(
        cardBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.red,
                height: 300,
                width: 200,
                child: Text(
                  numList.elementAt(index).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                //opacity: _swipeComplete ? 1.0 : _swipeProgress,
                child: Container(
                  // Your container with text here
                  color: Colors.red,
                  child: Text(
                    "Swipe Progress ${_swipeProgress}",
                    style: TextStyle(fontSize: 12,color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
        scale: 0.9,
        cardsCount: (numList.isNotEmpty) ? numList.length : 0,
        numberOfCardsDisplayed: 2,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
