import 'package:bloc/bloc.dart';
import 'package:drumm_app/core/features/notification/domain/usecases/send_notification_to_topic.dart';
import 'package:drumm_app/core/features/notification/domain/usecases/send_notification_to_user.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_event.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final SendNotificationToTopicUseCase sendNotificationToTopicUseCase;
  final SendNotificationToUserUseCase sendNotificationToUserUseCase;

  NotificationBloc({required this.sendNotificationToTopicUseCase, required this.sendNotificationToUserUseCase})
      : super(NotificationInitial()) {
    on<SendNotificationEvent>(_onSendNotification);
    on<SendNotificationToUserEvent>(_onSendNotificationToUser);
    on<ForegroundConversationNotificationReceivedEvent>((event, emit) {
      emit(NotificationLoading());
      emit(ForegroundConversationNotificationLoaded(conversation: event.conversation));
    });
    on<BackgroundConversationNotificationReceivedEvent>((event, emit) {
      emit(NotificationLoading());
      emit(BackgroundConversationNotificationLoaded(conversation: event.conversation));
    });
    on<ForegroundPodcastNotificationReceivedEvent>((event, emit) {
      emit(NotificationLoading());
      emit(ForegroundPodcastNotificationLoaded(podcast: event.podcast));
    });
    on<BackgroundPodcastNotificationReceivedEvent>((event, emit) {
      emit(NotificationLoading());
      emit(BackgroundPodcastNotificationLoaded(podcast: event.podcast));
    });
    on<NavigateToArticleEvent>((event, emit) {
      emit(NotificationLoading());
      emit(NavigateToArticleState(article: event.article));
    });
  }

  Future<void> _onSendNotification(
      SendNotificationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await sendNotificationToTopicUseCase(
        conversation: event.conversation,
        drummer: event.drummer,
      );
      emit(NotificationSuccess());
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }
  Future<void> _onSendNotificationToUser(
      SendNotificationToUserEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      await sendNotificationToUserUseCase(
        conversation: event.conversation,
        drummer: event.drummer,
      );
      emit(NotificationSuccess());
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }
}
