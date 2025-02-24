import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_state.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/pages/music_player_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummAudioFloatingWidget extends StatelessWidget {
  final ConversationEntity? conversation;
  const DrummAudioFloatingWidget({Key? key, required this.conversation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return DrummAudioBottomSheet(
                  channelName: conversation!.conversationId ?? "",
                  conversation: conversation!,
                );
              },
              isScrollControlled:
                  true, // optional for a full-screen bottom sheet
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //const Icon(Icons.music_note, color: Colors.white),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: conversation?.imageUrl ?? DEFAULT_APP_IMAGE_URL,
                      height: 42,
                      width: 42,
                      fit: BoxFit.cover,
                      errorWidget: (context,url,a){
                        return Image.asset(
                          "images/audio-waves.png",
                          color: DrummTheme.primaryTextColor(context),
                          height: 14,
                          width: 14,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      conversation?.question ?? "Playing Podcast",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: DrummTheme.primaryTextColor(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Close button to end the music.
                  IconButton(
                    icon:  Icon(Icons.exit_to_app_rounded,
                        color: DrummTheme.primaryTextColor(context)),
                    onPressed: () {
                      // context.read<MusicPlayerBloc>().add(StopMusic(podcast));
                      context
                          .read<DrummAudioBloc>()
                          .add(LeaveDrummChannelEvent());
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
