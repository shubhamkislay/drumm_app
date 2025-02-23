import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';

abstract class DrummAudioState {
  final String channelName;
  final ConversationEntity conversation;

  final List<int> remoteUserIds;

  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  DrummAudioState(this.channelName, this.remoteUserIds, this.talkingStatus, this.muteStatus, this.conversation);
}

class DrummAudioInitial extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioInitial(String channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus,this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus,conversation);
}

class DrummAudioLoading extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioLoading(String channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus,conversation);
}

/// When joined, we now persist the remote user IDs and their talking status.
class DrummAudioJoined extends DrummAudioState {
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;

  DrummAudioJoined(this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus,conversation);
}

class DrummAudioLeft extends DrummAudioState {
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioLeft(String channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus,conversation);
}

class DrummAudioLocalUserJoined extends DrummAudioState {
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioLocalUserJoined(this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus,conversation);
}

class DrummAudioRemoteUserJoined extends DrummAudioState {
  final int uid;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioRemoteUserJoined(this.uid, this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus, conversation);
}

class DrummAudioRemoteUserLeft extends DrummAudioState {
  final int uid;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioRemoteUserLeft(this.uid, this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus, conversation);
}

class DrummAudioRemoteUserMuted extends DrummAudioState {
  final int uid;
  final bool isMuted;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioRemoteUserMuted(this.uid, this.isMuted, this.channelName,this.remoteUserIds,this.talkingStatus, this.conversation, { this.muteStatus = const {},}) : super(channelName, remoteUserIds,talkingStatus, muteStatus, conversation);
}

class DrummAudioRemoteUserTalking extends DrummAudioState {
  final int uid;
  final bool isTalking;
  final String channelName;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioRemoteUserTalking(this.uid, this.isTalking, this.channelName,this.remoteUserIds,this.talkingStatus, this.muteStatus, this.conversation) : super(channelName, remoteUserIds,talkingStatus, muteStatus, conversation);
}

class DrummAudioError extends DrummAudioState {
  final String message;
  final List<int> remoteUserIds;
  final Map<int, bool> talkingStatus;
  final Map<int, bool> muteStatus;
  final ConversationEntity conversation;
  DrummAudioError(this.message,this.remoteUserIds,this.talkingStatus,this.muteStatus, this.conversation) : super('',remoteUserIds,talkingStatus,muteStatus,conversation);
}
