import 'package:bloc/bloc.dart';
import 'package:drumm_app/core/features/notification/domain/usecases/send_notification_to_topic.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_event.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final SendNotificationToTopicUseCase sendNotificationToTopicUseCase;

  NotificationBloc({required this.sendNotificationToTopicUseCase})
      : super(NotificationInitial()) {
    on<SendNotificationEvent>(_onSendNotification);
    on<ForegroundNotificationReceivedEvent>((event, emit) {
      print("LOADING NOTIFICATION//////////////");
      emit(ForegroundNotificationLoaded(conversation: event.conversation));
    });
    on<BackgroundNotificationReceivedEvent>((event, emit) {
      print("LOADING NOTIFICATION//////////////");
      emit(BackgroundNotificationLoaded(conversation: event.conversation));
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
}
