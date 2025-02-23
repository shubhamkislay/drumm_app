import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class SendNotificationEvent extends NotificationEvent {
  final ConversationEntity conversation;
  final DrummerEntity drummer;

  const SendNotificationEvent({
    required this.conversation,
    required this.drummer,
  });

  @override
  List<Object?> get props => [conversation, drummer];
}

class ForegroundConversationNotificationReceivedEvent extends NotificationEvent {
  final ConversationEntity conversation;
  const ForegroundConversationNotificationReceivedEvent({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

class BackgroundConversationNotificationReceivedEvent extends NotificationEvent {
  final ConversationEntity conversation;
  const BackgroundConversationNotificationReceivedEvent({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

class ForegroundPodcastNotificationReceivedEvent extends NotificationEvent {
  final PodcastEntity podcast;
  const ForegroundPodcastNotificationReceivedEvent({required this.podcast});

  @override
  List<Object?> get props => [podcast];
}

class BackgroundPodcastNotificationReceivedEvent extends NotificationEvent {
  final PodcastEntity podcast;
  const BackgroundPodcastNotificationReceivedEvent({required this.podcast});

  @override
  List<Object?> get props => [podcast];
}

class NavigateToArticleEvent extends NotificationEvent {
  final ArticleEntity article;
  const NavigateToArticleEvent({required this.article});

  @override
  List<Object?> get props => [article];
}
