import 'package:drumm_app/features/drumm%20podcast%20player/domain/entities/podcast.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {}

class NotificationFailure extends NotificationState {
  final String error;

  const NotificationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ForegroundConversationNotificationLoaded extends NotificationState {
  final ConversationEntity conversation;
  const ForegroundConversationNotificationLoaded({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}

class BackgroundConversationNotificationLoaded extends NotificationState {
  final ConversationEntity conversation;
  const BackgroundConversationNotificationLoaded({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}


class ForegroundPodcastNotificationLoaded extends NotificationState {
  final PodcastEntity podcast;
  const ForegroundPodcastNotificationLoaded({required this.podcast});

  @override
  List<Object?> get props => [podcast];
}

class BackgroundPodcastNotificationLoaded extends NotificationState {
  final PodcastEntity podcast;
  const BackgroundPodcastNotificationLoaded({required this.podcast});

  @override
  List<Object?> get props => [podcast];
}

class NavigateToArticleState extends NotificationState {
  final ArticleEntity article;
  const NavigateToArticleState({required this.article});

  @override
  List<Object?> get props => [article];
}