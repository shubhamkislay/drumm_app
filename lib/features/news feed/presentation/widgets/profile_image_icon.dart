import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../../../user page/presentation/pages/user_profile_page.dart';

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
            drummer: state.drummerEntity,
            currentUser: true,
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
