import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_state.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/widgets/podcast_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../bloc/music_player_event.dart';
import '../pages/music_player_bottom_sheet.dart';

class PodcastListWidget extends StatelessWidget {

  const PodcastListWidget({super.key});

  @override
  Widget build(BuildContext context) {

    print("Building list");
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
        if (state is PodcastLoaded) {
          final podcasts = state.podcasts;
          if (podcasts.isNotEmpty) {
            return SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: podcasts.length,
            padding: EdgeInsets.symmetric(horizontal:0),
            itemBuilder: (context, index) {
              final podcast = podcasts[index];
              return GestureDetector(
                onTap: () {
                  // Show a bottom sheet with the selected audio
                  Vibrate.feedback(FeedbackType.medium);
                  context.read<MusicPlayerBloc>().add(LoadMusic(podcast));
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Enables full-screen bottom sheet behavior.
                    builder: (_) => MusicPlayerBottomSheet(podcast:podcast),
                  );
                },
                child: PodcastItemWidget(
                  podcast: podcast,
                ),
              );
            },
          ),
        );
          }else{
          }
        }
        return const SizedBox.shrink();
      }
    );
  }
}

class PodcastListLoadingWidget extends StatelessWidget {

  const PodcastListLoadingWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            height: 200,
            width: 300,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DrummTheme.primaryItemColor(context),
              borderRadius: BorderRadius.circular(12)
            ),
          );
        },
      ),
    );
  }
}
