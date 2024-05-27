import 'package:flutter/material.dart';

class ScorePopup extends StatefulWidget {
  final int score;

  ScorePopup({Key? key, required this.score}) : super(key: key);

  @override
  ScorePopupState createState() => ScorePopupState();
}

class ScorePopupState extends State<ScorePopup> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _offsetAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0.80, 0.15),
      end: Offset(0.80, 0.35),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _animationController!.forward().then((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        _animationController!.reverse();
      });
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation!,
      child: AnimatedBuilder(
        animation: _opacityAnimation!,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation!.value,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: TextStyle(),
                child: Text(
                  '+${widget.score}',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 3,),
              Image.asset(
                "images/drumm_logo.png",
                height: 12,
                color: Colors.white,
              ),
              SizedBox(width: 8,),
            ],
          ),
        ),
      ),
    );
  }
}