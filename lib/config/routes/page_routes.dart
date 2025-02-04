import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_event.dart';
import 'package:drumm_app/core/util/article_band.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/circle_reveal_transistion.dart';
import 'package:drumm_app/features/authentication/presentation/pages/profession_selection_page.dart';
import 'package:drumm_app/features/drummer%20profile/presentation/pages/drummer_profile.dart';
import 'package:drumm_app/features/authentication/presentation/pages/initial_screen.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/pages/news_discovery_page.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/interests_page.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/register_page.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/bottom_start_conversation_widget.dart';
import 'package:drumm_app/launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/login_page.dart';

class PageRoutes {
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
          path: SCREEN_BOTTOM_CONVERSATION,
          pageBuilder: (context, state) {
            ArticleBands articleBands = state.extra as ArticleBands;
            ArticleEntity article = articleBands.article!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: BottomStartCoversationWidget(
                article: article,
                bands: articleBands.bands??[],
              ), // The bottom sheet
              opaque: false, // Allows background visibility
              transitionDuration: Duration(milliseconds: 150),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return CircleRevealBottomSheet(
                    animation: animation, child: child);
              },
            );
          },
        ),
        GoRoute(
          path: '/newsDiscovery',
          builder: (BuildContext context, GoRouterState state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<RemoteArticlesBloc>(
                    create: (providerContext) => s1()
                      ..add(GetArticles(
                          GetArticlesParams(category: ["For You"])))),
                BlocProvider<RemoteBandsBloc>(
                    create: (providerContext) =>
                        s1()..add(GetCurrentUserBands())),
              ],
              child: NewsDiscoveryPage(),
            );
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
      ],
    );
  }
}
