import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_event.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';

class ProfileImageIcon extends StatelessWidget {
  final RemoteDrummerState state;
  const ProfileImageIcon({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is RemoteDrummerLoading) {
      return Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.circular(32),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.selection);
        context.pushTransparentRoute(
          UserProfilePage(
            fromSearch: true,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: state.drummerEntity?.imageUrl ?? "",
          height: 36,
          width: 36,
        ),
      ),
    );
  }
}
