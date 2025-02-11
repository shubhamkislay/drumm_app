// drumm_audio_bottom_sheet.dart

import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummAudioBottomSheet extends StatefulWidget {
  const DrummAudioBottomSheet({Key? key}) : super(key: key);

  @override
  State<DrummAudioBottomSheet> createState() => _DrummAudioBottomSheetState();
}

class _DrummAudioBottomSheetState extends State<DrummAudioBottomSheet> {
  // List to keep track of remote user IDs
  final List<int> _remoteUserIds = [];
  // Map to keep track of talking status for each remote user (uid -> bool)
  final Map<int, bool> _talkingStatus = {};
  int i = 0;

  void _muteAudio(BuildContext context, bool mute) {
    context.read<DrummAudioBloc>().add(MuteDrummAudioEvent(mute));
  }

  void _leaveChannel(BuildContext context) {
    context.read<DrummAudioBloc>().add(LeaveDrummChannelEvent());
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
        } else if (state is DrummAudioRemoteUserJoined) {
          //print("DrummAudioRemoteUserJoined: uid ${state.uid}");
          // Add the remote UID if not already present
          int id = (state.uid == 0)?12345:state.uid;
          if (!_remoteUserIds.contains(id)) {
            setState(() {
              _remoteUserIds.add(id);
            });
          }
        } else if (state is DrummAudioRemoteUserMuted) {
          //print("DrummAudioRemoteUserMuted: uid ${state.uid}");

        } else if (state is DrummAudioRemoteUserTalking) {
          //print("DrummAudioRemoteUserTalking: uid ${state.uid} talking ${state.isTalking}");
          // Update the talking status for the given uid
          if (!_remoteUserIds.contains(12345))
          setState(() {
            _remoteUserIds.add(12345);
            print("Total users${_remoteUserIds.length}");
          });
          int id = (state.uid == 0)?12345:state.uid;
          setState(() {
            _talkingStatus[id] = state.isTalking;
          });
        } else if (state is DrummChannelJoined) {
          print("DrummChannelJoined");
          setState(() {
            _remoteUserIds.add(12345);
            print("Total users${_remoteUserIds.length}");
          });
        }
      },
      builder: (context, state) {
        if (state is !DrummAudioError && state is !DrummAudioLoading) {
          return Container(
            height: MediaQuery.sizeOf(context).height*0.8, // Fixed height for the bottom sheet
            color: DrummTheme.primaryItemColor(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Grid view to show remote users
                Expanded(
                  child: Container(
                    child: _remoteUserIds.isNotEmpty
                        ? GridView.builder(
                      scrollDirection: Axis.vertical,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                      ),
                      itemCount: _remoteUserIds.length,
                      itemBuilder: (context, index) {
                        final uid = _remoteUserIds[index];
                        // If the user is talking, show a green border; otherwise, gray.
                        final isTalking = _talkingStatus[uid] ?? false;
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isTalking ? Colors.green : Colors.grey,
                              width: isTalking ? 3 : 1,
                            ),
                          ),
                          width: 60,
                          height: 60,
                          child: Center(
                            child: Text(
                              uid.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    )
                        : Center(child: Text("Total users${_remoteUserIds.length}")),
                  ),
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
        } else if (state is DrummAudioLoading) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: const Center(
              child: Text('Not in a call'),
            ),
          );
        }
      },
    );
  }
}
