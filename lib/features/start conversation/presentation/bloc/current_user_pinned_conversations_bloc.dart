import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:drumm_app/core/resources/data_state.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/get_pinned_conversations_last24hours.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/upin_conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/current_user_pinned_conversations_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/current_user_pinned_conversations_state.dart';

class CurrentUserPinnedConversationsBloc
    extends Bloc<CurrentUserPinnedConversationsEvent, CurrentUserPinnedConversationsState> {
  final GetPinnedConversationsLast24Hours getPinnedConversationsLast24Hours;
  final UnpinConversationUseCase unpinConversationUseCase;

  CurrentUserPinnedConversationsBloc(
      {required this.getPinnedConversationsLast24Hours,
      required this.unpinConversationUseCase})
      : super(PinnedConversationsInitial()) {
    on<CurrentUserLoadPinnedConversationsEvent>(_onCurrentUserLoadPinnedConversations);
    on<UnpinConversationCurrentUserEvent>(_onUnpinConversation);
  }

  Future<void> _onCurrentUserLoadPinnedConversations(
      CurrentUserLoadPinnedConversationsEvent event,
      Emitter<CurrentUserPinnedConversationsState> emit,
      ) async {
    emit(PinnedConversationsLoading());
    try {
      final conversations = await getPinnedConversationsLast24Hours(
          onlyCurrentUser: true);
        emit(CurrentUserPinnedConversationsLoaded(
            conversations: conversations));
    } catch (e) {
      emit(PinnedConversationsError(error: e.toString()));
    }
  }

  Future<void> _onUnpinConversation(
      UnpinConversationCurrentUserEvent event,
    Emitter<CurrentUserPinnedConversationsState> emit,
  ) async {
    emit(UnpinningConversation());
    try {
      DataState unpinState =
          await unpinConversationUseCase(conversationId: event.conversationId);
      bool unpin = unpinState.data;
      if (unpin) {
        emit(PinnedConversationsLoading());
        try {
          final conversations = await getPinnedConversationsLast24Hours(
              onlyCurrentUser: event.onlyCurrentUser);
          if (event.onlyCurrentUser) {
            emit(CurrentUserPinnedConversationsLoaded(
                conversations: conversations));
          } else {
            emit(PinnedConversationsLoaded(conversations: conversations));
          }
        } catch (e) {
          emit(PinnedConversationsError(error: e.toString()));
        }
      }
    } on DioException catch (e) {
      emit(UnableToUnpinConversation(error: e.toString()));
    }
  }
}
