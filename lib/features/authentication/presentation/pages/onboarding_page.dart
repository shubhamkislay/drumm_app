import 'package:drumm_app/features/authentication/presentation/widgets/drumm_onboarding_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: FlutterOnBoardingSlider(
          onFinish: () {
            context.go("/login");
          },
        ),
      ),
    );
  }
}
