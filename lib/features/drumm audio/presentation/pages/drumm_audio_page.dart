// presentation/pages/drumm_audio_page.dart

import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrummAudioPage extends StatelessWidget {
  final String appId;
  final String token;
  final String channelName;
  final int uid;

  const DrummAudioPage({
    Key? key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
  }) : super(key: key);

  void _initializeJoinListen(BuildContext context) {
    context.read<DrummAudioBloc>().add(
      InitializeJoinListenDrummEvent(
        appId: appId,
        token: token,
        channelName: channelName,
        uid: uid,
        isMuted: false, // or true if you want to join muted
      ),
    );
  }

  void _leaveChannel(BuildContext context) {
    context.read<DrummAudioBloc>().add(LeaveDrummChannelEvent());
  }

  void _muteAudio(BuildContext context, bool mute) {
    context.read<DrummAudioBloc>().add(MuteDrummAudioEvent(mute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drumm Audio (Stateless)'),
      ),
      body: BlocConsumer<DrummAudioBloc, DrummAudioState>(
        listener: (context, state) {
          if (state is DrummAudioError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is DrummAudioRemoteUserJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User ${state.uid} joined')),
            );
          } else if (state is DrummAudioRemoteUserMuted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'User ${state.uid} is now ${state.isMuted ? 'muted' : 'unmuted'}',
                ),
              ),
            );
          } else if (state is DrummAudioRemoteUserTalking) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'User ${state.uid} is ${state.isTalking ? 'talking' : 'silent'}',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DrummAudioInitial) {
            // Not yet joined or initialized
            return Center(
              child: ElevatedButton(
                onPressed: () => _initializeJoinListen(context),
                child: const Text('Initialize & Join'),
              ),
            );
          } else if (state is DrummAudioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DrummAudioJoined) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have joined the channel'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _muteAudio(context, true),
                    child: const Text('Mute Myself'),
                  ),
                  ElevatedButton(
                    onPressed: () => _muteAudio(context, false),
                    child: const Text('Unmute Myself'),
                  ),
                  ElevatedButton(
                    onPressed: () => _leaveChannel(context),
                    child: const Text('Leave Channel'),
                  ),
                ],
              ),
            );
          } else if (state is DrummAudioLeft) {
            return Center(
              child: Text('You left the channel: $channelName'),
            );
          } else {
            // e.g. DrummAudioRemoteUserJoined, DrummAudioRemoteUserMuted, etc.
            // The UI can be basically the same as DrummAudioJoined,
            // unless you want special visuals for "user joined" states
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('In the channel'),
                  ElevatedButton(
                    onPressed: () => _leaveChannel(context),
                    child: const Text('Leave Channel'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
