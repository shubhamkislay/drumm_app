import 'package:drumm_app/features/authentication/presentation/pages/initial_screen.dart';
import 'package:drumm_app/features/authentication/presentation/pages/onboarding_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/profession_selection_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/login_page.dart';

class PageRoutes{

  static GoRouter getGoRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const InitialScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: '/onboarding',
          builder: (BuildContext context, GoRouterState state) {
            return const OnboardingPage();
          },
        ),
        GoRoute(
          path: '/professionSelection',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfessionSelectionPage();
          },
        ),
      ],
    );
  }
}