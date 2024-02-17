import 'package:flutter/cupertino.dart';

class BottomUpPageRoute<T> extends CupertinoPageRoute<T> {
  BottomUpPageRoute({required WidgetBuilder builder})
      : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Customize the transition animation here
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class NoAnimationCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  NoAnimationCupertinoPageRoute({required WidgetBuilder builder})
      : super(builder: builder);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.25,
        end: 1.0,
      ).animate(animation),
      child: builder(context),
    );
  }

  @override
  void animateTransition() {
    // Do nothing to remove the default animation
  }
}