import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_state.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/pages/music_player_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class FloatingMusicPlayer extends StatelessWidget {
  final PodcastEntity? podcast;
  const FloatingMusicPlayer({Key? key, required this.podcast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            // Open the full music player when tapping the mini-player.
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => MusicPlayerBottomSheet(podcast: podcast,),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: DrummTheme.primaryItemColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 // const Icon(Icons.music_note, color: Colors.white),
                  Image.asset("images/podcast.png",color: DrummTheme.primaryTextColor(context),height: 18,width: 18,),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      podcast?.podcastTitle??"Playing Podcast",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: DrummTheme.primaryTextColor(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: DrummTheme.primaryTextColor(context),
                    ),
                    onPressed: () {
                      if (state.isPlaying) {
                        context.read<MusicPlayerBloc>().add(PauseMusic(podcast));
                      } else {
                        context.read<MusicPlayerBloc>().add(PlayMusic(podcast));
                      }
                    },
                  ),
                  // Close button to end the music.
                  IconButton(
                    icon: Icon(Icons.close, color: DrummTheme.primaryTextColor(context)),
                    onPressed: () {
                      context.read<MusicPlayerBloc>().add(StopMusic(podcast));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
