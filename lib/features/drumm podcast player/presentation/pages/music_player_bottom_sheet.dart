import 'package:auto_size_text/auto_size_text.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_state.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/widgets/podcast_share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MusicPlayerBottomSheet extends StatefulWidget {
  final PodcastEntity? podcast;
  const MusicPlayerBottomSheet({Key? key, required this.podcast})
      : super(key: key);

  @override
  _MusicPlayerBottomSheetState createState() => _MusicPlayerBottomSheetState();
}

class _MusicPlayerBottomSheetState extends State<MusicPlayerBottomSheet> {
  bool _isDragging = false;
  double _dragValue = 0.0; // Local slider value in milliseconds.

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    context.read<MusicPlayerBloc>().add(PlayMusic(widget.podcast));
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: DrummTheme.primaryItemColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PodcastShareButton(podcast: widget.podcast!),
          const SizedBox(height: 24),
          AutoSizeText(
            minFontSize: 16,
            textAlign: TextAlign.center,
            maxLines: 2,
            ((widget.podcast?.podcastTitle ?? "").isNotEmpty)
                ? widget.podcast?.podcastTitle ?? ""
                : widget.podcast?.audioTitle ?? "",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Replace with album art or any other UI element.
          const SizedBox(height: 24),
          // Play/Pause button.
          BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            builder: (context, state) {
              return (state.isProcessing)
                  ? Container(
                      height: 64,
                      width: 64,
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: DrummTheme.drummPrimaryColor,
                      ),
                    )
                  : IconButton(
                    iconSize: 64,
                    padding: EdgeInsets.all(0),
                    icon: Icon(

                      state.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: DrummTheme.drummPrimaryColor,
                    ),
                    onPressed: () {
                      if (state.isPlaying) {
                        context
                            .read<MusicPlayerBloc>()
                            .add(PauseMusic(widget.podcast));
                      } else if (!state.isProcessing) {
                        context
                            .read<MusicPlayerBloc>()
                            .add(PlayMusic(widget.podcast));
                      }
                    },
                  );
            },
          ),
          const SizedBox(height: 24),
          // Seek bar with local drag state.
          BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            builder: (context, state) {
              final totalDuration = state.duration ?? Duration.zero;
              final currentPosition = state.position;

              // If not dragging, update _dragValue with the current position.
              if (!_isDragging) {
                _dragValue = currentPosition.inMilliseconds.toDouble();
              }

              return Column(
                children: [
                  Slider(
                    value: _dragValue,
                    min: 0,
                    max: totalDuration.inMilliseconds > 0
                        ? totalDuration.inMilliseconds.toDouble()
                        : 1,
                    onChangeStart: (value) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _dragValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      // Seek to the desired position.
                      context.read<MusicPlayerBloc>().add(
                            SeekMusic(Duration(milliseconds: value.toInt()),
                                widget.podcast),
                          );
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    thumbColor: DrummTheme.drummPrimaryColor,
                    activeColor: DrummTheme.drummPrimaryColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(
                            Duration(milliseconds: _dragValue.toInt())),
                        style: TextStyle(
                            color: DrummTheme.primaryTextColor(context)),
                      ),
                      Text(_formatDuration(totalDuration),
                          style: TextStyle(
                              color: DrummTheme.primaryTextColor(context))),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
