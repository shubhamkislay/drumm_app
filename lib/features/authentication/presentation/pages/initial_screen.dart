import 'package:drumm_app/core/features/startup/presentation/pages/splashscreen.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_event.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_state.dart';
import 'package:drumm_app/features/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/injection_container.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HybridInitialScreenBloc>(
      create: (context) => s1()..add(GetInitialScreen()),
      child: BlocListener<HybridInitialScreenBloc, HybridInitialScreenState>(
        listener: (context, state) {
          if (state is InitialScreenFetched) {
            context.go(SCREEN_DRUMMER_PROFILE);//state.initialScreen ?? SCREEN_ONBOARDING);
          }
        },
        child: BlocBuilder<HybridInitialScreenBloc, HybridInitialScreenState>(
          builder: (context, blocState) {
            if (blocState is FetchingInitialScreen) {
              return Splashscreen();
            }
            return Container();
          },
        ),
      ),
    );
  }
}
