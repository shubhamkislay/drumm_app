import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your other pages, blocs, etc.
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_event.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_event.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/pages/news_discovery_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/login_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/register_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/initial_screen.dart';
import 'package:drumm_app/features/drummer%20profile/presentation/pages/drummer_profile.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:drumm_app/features/onboarding/presentation/pages/interests_page.dart';
import 'package:drumm_app/features/authentication/presentation/pages/profession_selection_page.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/core/util/article_band.dart';
import 'package:drumm_app/features/start%20conversation/presentation/pages/bottom_start_conversation_widget.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/circle_reveal_transistion.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/config/injection_container.dart';
import 'router_constants.dart'; // your constants file


class PageRoutes {
  static GoRouter getGoRouter() {
    return GoRouter(
      initialLocation: '/',
      // We define a top-level ShellRoute that wraps all child routes.
      routes: <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                create: (_) => MusicPlayerBloc(),),
            BlocProvider<RemoteDrummerBloc>(
            create: (context) => s1()..add(GetDrummer())),
                BlocProvider<DrummAudioBloc>(
                  create: (_) => s1<DrummAudioBloc>(),
                ),
                BlocProvider<UserActivityBloc>(
                  create: (providerContext) => s1<UserActivityBloc>(),
                ),
                BlocProvider<RemoteArticlesBloc>(
                  create: (providerContext) => s1<RemoteArticlesBloc>(),
                ),
              ],
              child: child,
            );
          },
          routes: [
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
                List<Object> parameters = state.extra as List<Object>;
                ArticleEntity article =parameters.elementAt(0) as ArticleEntity;
                DrummerEntity drummerEntity = parameters.elementAt(1) as DrummerEntity;
                List<BandEntity> bands = parameters.elementAt(2) as List<BandEntity>;
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: BottomStartConversationWidget(
                    article: article,
                    bands: bands, drummerEntity: drummerEntity,
                  ),
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 150),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return CircleRevealBottomSheet(
                      animation: animation,
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/newsDiscovery',
              builder: (BuildContext context, GoRouterState state) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider<RemoteDrummerBloc>(
                      create: (BuildContext context) =>
                      s1<RemoteDrummerBloc>()..add(GetDrummer()),
                    ),
                    BlocProvider<RemoteBandsBloc>(
                      create: (providerContext) =>
                      s1<RemoteBandsBloc>()..add(GetCurrentUserBands()),
                    ),
                  ],
                  child: const NewsDiscoveryPage(),
                );
              },
            ),
            GoRoute(
              path: '/interestsPage',
              builder: (BuildContext context, GoRouterState state) {
                return const InterestsPage();
              },
            ),
            GoRoute(
              path: '/drummerProfile',
              builder: (BuildContext context, GoRouterState state) {
                return const DrummerProfile();
              },
            ),
            // --- End child routes ---
          ],
        ),
      ],
    );
  }
}
