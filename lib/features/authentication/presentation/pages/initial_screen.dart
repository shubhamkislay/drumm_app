import 'package:drumm_app/core/presentation/pages/splashscreen.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_state.dart';
import 'package:drumm_app/features/authentication/presentation/pages/login_page.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/profession_selection_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/register_page.dart';
import 'package:drumm_app/features/constants.dart';
import 'package:drumm_app/features/news%20feed/presentation/pages/news_discovery_page.dart';
import 'package:drumm_app/launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HybridInitialScreenBloc>(
        create: (context) => s1()
      ..add(GetInitialScreen(FirebaseAuth.instance.currentUser?.uid ?? "")),
      child: BlocBuilder<HybridInitialScreenBloc, HybridInitialScreenState>(
        builder: (context, blocState) {
          if (blocState is FetchingInitialScreen) {
            return Splashscreen();
          } else if ((blocState is InitialScreenFetched)) {
            if (blocState.initialScreen == SCREEN_NEWS_DISCOVERY) return LauncherPage();//NewsDiscoveryPage();
            if (blocState.initialScreen == SCREEN_ONBOARDING) return OnboardingPage();
            if (blocState.initialScreen == SCREEN_REGISTER) return RegisterPage(name: "",email: "",);
            if (blocState.initialScreen == SCREEN_LOGIN) return LoginPage();
            if (blocState.initialScreen == SCREEN_PROFESSIONAL) return ProfessionSelectionPage();
          }
          return OnboardingPage();
        },
      ),
    );
  }
}
