import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_state.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/widgets/drummer_join_card.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/last_active_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/last_active_event.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummAudioBottomSheet extends StatefulWidget {
  final String channelName;
  const DrummAudioBottomSheet({Key? key, required this.channelName}) : super(key: key);

  @override
  State<DrummAudioBottomSheet> createState() => _DrummAudioBottomSheetState();
}

class _DrummAudioBottomSheetState extends State<DrummAudioBottomSheet> {
  void _muteAudio(BuildContext context, bool mute) {
    context.read<DrummAudioBloc>().add(MuteDrummAudioEvent(mute, widget.channelName));
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
        if (state is !DrummAudioLoading && state is !DrummAudioError && state is !DrummAudioInitial) {
          return Container(
            height: MediaQuery.sizeOf(context).height * 0.8, // Fixed height for bottom sheet
            color: DrummTheme.primaryItemColor(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Grid view to show remote users.
                Expanded(
                  child: state.remoteUserIds.isNotEmpty
                      ? GridView.builder(
                    scrollDirection: Axis.vertical,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: state.remoteUserIds.length,
                    itemBuilder: (context, index) {
                      final uid = state.remoteUserIds[index];
                      // If the user is talking, show a green border; otherwise, gray.
                      final isTalking = state.talkingStatus[uid] ?? false;
                      final isMute = state.muteStatus[uid]??false;
                      return DrummerJoinCard(drummerId: uid,talking: isTalking,muted: isMute,);
                    },
                  )
                      : Center(child: Text("Total users: ${state.remoteUserIds.length}")),
                ),
                const SizedBox(height: 16),
                // Other controls
                const Text('Drumm Audio Bottom Sheet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _muteAudio(context, true),
                  child: const Text('Mute'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _muteAudio(context, false),
                  child: const Text('Unmute'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _leaveChannel(context),
                  child: const Text('Leave Channel'),
                ),
              ],
            ),
          );
        } else  {
          return Container(
            height: MediaQuery.sizeOf(context).height * 0.8, // Fixed height for bottom sheet
            color: DrummTheme.primaryItemColor(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Grid view to show remote users.
                Expanded(
                  child: Container()
                ),
                const SizedBox(height: 16),
                // Other controls
                const Text('Drumm Audio Bottom Sheet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _muteAudio(context, true),
                  child: const Text('Mute'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _muteAudio(context, false),
                  child: const Text('Unmute'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _leaveChannel(context),
                  child: const Text('Leave Channel'),
                ),
              ],
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
