import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FadeInContainer extends StatefulWidget {
  final Widget? child;
  final Duration duration;

  const FadeInContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  }) : super(key: key);

  @override
  _FadeInTextState createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        _controller.forward();
      }catch(e){
        print("Error running animation because ${e}");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          alignment: Alignment.centerLeft,
          child: widget.child,
        ),
      ),
    );
  }
}
