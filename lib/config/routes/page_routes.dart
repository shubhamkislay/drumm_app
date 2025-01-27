import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/features/authentication/presentation/pages/profession_selection_page.dart';
import 'package:drumm_app/features/drummer%20profile/presentation/pages/drummer_profile.dart';
import 'package:drumm_app/features/authentication/presentation/pages/initial_screen.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/presentation/pages/news_discovery_page.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/interests_page.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/register_page.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:drumm_app/launcher.dart';
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
          path: '/register/:email?/:name?',
          builder: (BuildContext context, GoRouterState state) {
            final email = state.pathParameters['email'];
            final name = state.pathParameters['name'];
            return RegisterPage(name: name, email: email);
          },
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) {
            return RegisterPage(name: null, email: null);
          },
        ),
        GoRoute(
          path: '/onboarding',
          builder: (BuildContext context, GoRouterState state) {
            return const OnboardingPage();
          },
        ),
        GoRoute(
          path: '/launcherPage',
          builder: (BuildContext context, GoRouterState state) {
            return LauncherPage();
          },
        ),
        GoRoute(
          path: '/professionSelection',
          builder: (BuildContext context, GoRouterState state) {
            return ProfessionSelectionPage();
          },
        ),
        GoRoute(
          path: '/newsDiscovery',
          builder: (BuildContext context, GoRouterState state) {
            return NewsDiscoveryPage();
          },
        ),
        GoRoute(
          path: '/interestsPage',
          builder: (BuildContext context, GoRouterState state) {
            return InterestsPage();
          },
        ),
        GoRoute(
          path: '/drummerProfile',
          builder: (BuildContext context, GoRouterState state) {
            return const DrummerProfile();
          },
        ),
        GoRoute(
          path: SCREEN_READ_ARTICLE,
          builder: (context, state) {
            ArticleEntity article = state.extra as ArticleEntity;
            return ReadArticlePage(
              article: article,
            );
          },

        ),
      ],
    );
  }
}