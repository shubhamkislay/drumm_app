import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_state.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/widgets/drummer_join_card.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/last_active_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/last_active_event.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummAudioBottomSheet extends StatefulWidget {
  final String channelName;
  final ConversationEntity conversation;
  final DrummerEntity drummerEntity;
  const DrummAudioBottomSheet(
      {Key? key,
      required this.channelName,
      required this.conversation,
      required this.drummerEntity})
      : super(key: key);

  @override
  State<DrummAudioBottomSheet> createState() => _DrummAudioBottomSheetState();
}

class _DrummAudioBottomSheetState extends State<DrummAudioBottomSheet> {
  void _muteAudio(BuildContext context, bool mute) {
    context.read<DrummAudioBloc>().add(
        MuteDrummAudioEvent(mute, widget.channelName, widget.conversation));
  }

  void _leaveChannel(BuildContext context) {
    context.read<DrummAudioBloc>().add(LeaveDrummChannelEvent());
    //context.read<LastActiveBloc>().add(StopUpdatingLastActive());
    Navigator.pop(context); // Close the bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DrummAudioBloc, DrummAudioState>(
      listener: (context, state) {
        if (state is DrummAudioError) {
          print("DrummAudioError: ${state.message}");

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
        // You no longer need to update local _remoteUserIds or _talkingStatus here,
        // as these values are maintained in the Bloc's state.
      },
      builder: (context, state) {
        if (state is! DrummAudioLoading &&
            state is! DrummAudioError &&
            state is! DrummAudioInitial) {
          return Container(
            height: MediaQuery.sizeOf(context).height *
                0.8, // Fixed height for bottom sheet
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: DrummTheme.primaryItemColor(context),
                borderRadius: BorderRadius.circular(12)),
            child: DraggableScrollableSheet(
              shouldCloseOnMinExtent: true,
              snap: false,
              snapAnimationDuration: Duration(milliseconds: 100),
              initialChildSize: 1,
              minChildSize: 0.9,
              maxChildSize: 1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grid view to show remote users.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //const Icon(Icons.music_note, color: Colors.white),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.conversation.imageUrl ??
                                DEFAULT_APP_IMAGE_URL,
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, a) {
                              return Image.asset(
                                "images/audio-waves.png",
                                color: DrummTheme.primaryTextColor(context),
                                height: 64,
                                width: 64,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.conversation.question ?? "Playing Podcast",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: DrummTheme.primaryTextColor(context),
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                    value: context.read<
                                        UserActivityBloc>(), // Provide the existing bloc
                                    child: ReadArticlePage(
                                      article: ArticleModel.fromConversation(
                                          widget.conversation),
                                      bands: [],
                                      drummerEntity: widget.drummerEntity,
                                    )),
                                isScrollControlled:
                                    true, // For making the sheet extendable
                                backgroundColor: Colors.transparent,
                              );
                            },
                            child: Icon(Icons.open_in_full_rounded)),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: state.remoteUserIds.isNotEmpty
                          ? GridView.builder(
                              scrollDirection: Axis.vertical,
                              controller: scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: state.remoteUserIds.length,
                              itemBuilder: (context, index) {
                                final uid = state.remoteUserIds[index];
                                // If the user is talking, show a green border; otherwise, gray.
                                final isTalking =
                                    state.talkingStatus[uid] ?? false;
                                final isMute = state.muteStatus[uid] ?? false;
                                return DrummerJoinCard(
                                  drummerId: uid,
                                  talking: isTalking,
                                  muted: isMute,
                                );
                              },
                            )
                          : Center(
                              child: Image.asset(
                              "images/drumm_logo.png",
                              color: DrummTheme.primaryTextColor(context)
                                  .withAlpha(10),
                              height: 100,
                              width: 100,
                            )),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (state.muteStatus[widget.drummerEntity.rid] ??
                                false) {
                              _muteAudio(context, false);
                            } else {
                              _muteAudio(context, true);
                            }
                          },
                          child: Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                  color: (state.muteStatus[
                                              widget.drummerEntity.rid] ??
                                          false)
                                      ? DrummTheme.primaryTextColor(context)
                                          .withAlpha(100)
                                      : DrummTheme.drummPrimaryColor,
                                  shape: BoxShape.circle),
                              child:
                                  (state.muteStatus[widget.drummerEntity.rid] ??
                                          false)
                                      ? Icon(
                                          size: 42,
                                          Icons.mic_off_rounded,
                                          color: Colors.white,
                                        )
                                      : Icon(
                                          size: 42,
                                          Icons.mic_rounded,
                                          color: Colors.white,
                                        )),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                              color: DrummTheme.primaryTextColor(context)
                                  .withAlpha(100),
                              shape: BoxShape.circle),
                          child: IconButton(
                            icon: Icon(Icons.exit_to_app_rounded,
                                size: 36, color: Colors.white),
                            onPressed: () {
                              // context.read<MusicPlayerBloc>().add(StopMusic(podcast));
                              _leaveChannel(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SafeArea(bottom: true, child: SizedBox.shrink()),
                  ],
                );
              },
            ),
          );
        } else if (state is DrummAudioError) {
          return Container(
            height: MediaQuery.sizeOf(context).height *
                0.8, // Fixed height for bottom sheet
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: DrummTheme.primaryItemColor(context),
                borderRadius: BorderRadius.circular(12)),
            child: DraggableScrollableSheet(
              shouldCloseOnMinExtent: true,
              snap: false,
              snapAnimationDuration: Duration(milliseconds: 100),
              initialChildSize: 1,
              minChildSize: 0.9,
              maxChildSize: 1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grid view to show remote users.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //const Icon(Icons.music_note, color: Colors.white),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.conversation.imageUrl ??
                                DEFAULT_APP_IMAGE_URL,
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, a) {
                              return Image.asset(
                                "images/audio-waves.png",
                                color: DrummTheme.primaryTextColor(context),
                                height: 64,
                                width: 64,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.conversation.question ?? "Playing Podcast",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: DrummTheme.primaryTextColor(context),
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                    value: context.read<
                                        UserActivityBloc>(), // Provide the existing bloc
                                    child: ReadArticlePage(
                                      article: ArticleModel.fromConversation(
                                          widget.conversation),
                                      bands: [],
                                      drummerEntity: widget.drummerEntity,
                                    )),
                                isScrollControlled:
                                    true, // For making the sheet extendable
                                backgroundColor: Colors.transparent,
                              );
                            },
                            child: Icon(Icons.open_in_full_rounded)),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: Center(
                          child: Text(state.message)),
                    ),
                  ],
                );
              },
            ),
          );
        } else {
          return Container(
            height: MediaQuery.sizeOf(context).height *
                0.8, // Fixed height for bottom sheet
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: DrummTheme.primaryItemColor(context),
                borderRadius: BorderRadius.circular(12)),
            child: DraggableScrollableSheet(
              shouldCloseOnMinExtent: true,
              snap: false,
              snapAnimationDuration: Duration(milliseconds: 100),
              initialChildSize: 1,
              minChildSize: 0.9,
              maxChildSize: 1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grid view to show remote users.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //const Icon(Icons.music_note, color: Colors.white),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.conversation.imageUrl ??
                                DEFAULT_APP_IMAGE_URL,
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, a) {
                              return Image.asset(
                                "images/audio-waves.png",
                                color: DrummTheme.primaryTextColor(context),
                                height: 64,
                                width: 64,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.conversation.question ?? "Playing Podcast",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: DrummTheme.primaryTextColor(context),
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                    value: context.read<
                                        UserActivityBloc>(), // Provide the existing bloc
                                    child: ReadArticlePage(
                                      article: ArticleModel.fromConversation(
                                          widget.conversation),
                                      bands: [],
                                      drummerEntity: widget.drummerEntity,
                                    )),
                                isScrollControlled:
                                    true, // For making the sheet extendable
                                backgroundColor: Colors.transparent,
                              );
                            },
                            child: Icon(Icons.open_in_full_rounded)),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: Center(
                          child: Image.asset(
                        "images/drumm_logo.png",
                        color:
                            DrummTheme.primaryTextColor(context).withAlpha(10),
                        height: 100,
                        width: 100,
                      )),
                    ),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //context.read<LastActiveBloc>().add(StartUpdatingLastActive(channelName));
  }

  @override
  void dispose() {
    //context.read<LastActiveBloc>().add(StopUpdatingLastActive());
    super.dispose();
  }
}
