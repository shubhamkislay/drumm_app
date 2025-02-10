// drumm_audio_bottom_sheet.dart

import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummAudioBottomSheet extends StatelessWidget {
  const DrummAudioBottomSheet({Key? key}) : super(key: key);

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
          print("DrummAudioError ${state.message}");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is DrummAudioRemoteUserJoined) {
          print("DrummAudioRemoteUserJoined");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ${state.uid} joined')),
          );
        } else if (state is DrummAudioRemoteUserMuted) {
          print("DrummAudioRemoteUserMuted");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'User ${state.uid} is ${state.isMuted ? 'muted' : 'unmuted'}'),
            ),
          );
        } else if (state is DrummAudioRemoteUserTalking) {
          print("DrummAudioRemoteUserTalking");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User ${state.uid} is ${state.isTalking ? 'talking' : 'silent'}',
              ),
            ),
          );
        }else if (state is DrummChannelJoined) {
          print("DrummChannelJoined");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'JoinedChannel Successfully',
              ),
            ),
          );
        }


      },
      builder: (context, state) {
        if (state is DrummAudioJoined) {
          return Container(
            height: 300, // or MediaQuery for a full screen bottom sheet
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Drumm Audio Bottom Sheet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _muteAudio(context, true),
                  child: const Text('Mute'),
                ),
                ElevatedButton(
                  onPressed: () => _muteAudio(context, false),
                  child: const Text('Unmute'),
                ),
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
