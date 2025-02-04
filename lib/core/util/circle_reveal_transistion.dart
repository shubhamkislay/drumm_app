import 'package:flutter/material.dart';

class CircleRevealBottomSheet extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const CircleRevealBottomSheet({Key? key, required this.animation, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Tap outside to dismiss
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withOpacity(animation.value * 0.3),
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Bottom Sheet with Circular Reveal
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: CircleRevealClipper(animation.value, MediaQuery.of(context).size),
                child: child,
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final double progress;
  final Size screenSize;

  CircleRevealClipper(this.progress, this.screenSize);

  @override
  Path getClip(Size size) {
    double radius = screenSize.width * progress * 1.25; // Expand circle effect
    return Path()
      ..addOval(Rect.fromCircle(center: Offset(screenSize.width / 2, screenSize.height/1.15), radius: radius));
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
