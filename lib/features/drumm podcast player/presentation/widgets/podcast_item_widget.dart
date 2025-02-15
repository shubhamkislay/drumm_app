import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:flutter/material.dart';

class PodcastItemWidget extends StatelessWidget {

  final PodcastEntity podcast;
  const PodcastItemWidget({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      color: DrummTheme.primaryItemColor(context),
      child: Center(
        child: Text(
          "${CoreUtils.getWeekDay(podcast.updatedAt)}, ${CoreUtils.getFormattedDate(podcast.updatedAt)}\n${CoreUtils.getFormattedTime(podcast.updatedAt)}\n\n${podcast.podcastTitle}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DrummTheme.primaryTextColor(context)
          ),
        ),
      ),
    );
  }
}
