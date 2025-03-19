import 'package:bloc/bloc.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/get_pinned_conversations_last24hours.dart';
import 'pinned_conversations_event.dart';
import 'pinned_conversations_state.dart';

class PinnedConversationsBloc extends Bloc<PinnedConversationsEvent, PinnedConversationsState> {
  final GetPinnedConversationsLast24Hours getPinnedConversationsLast24Hours;

  PinnedConversationsBloc({required this.getPinnedConversationsLast24Hours})
      : super(PinnedConversationsInitial()) {
    on<LoadPinnedConversationsEvent>(_onLoadPinnedConversations);
  }

  Future<void> _onLoadPinnedConversations(
      LoadPinnedConversationsEvent event,
      Emitter<PinnedConversationsState> emit,
      ) async {
    emit(PinnedConversationsLoading());
    try {
      final conversations = await getPinnedConversationsLast24Hours(onlyCurrentUser: event.onlyCurrentUser);
      emit(PinnedConversationsLoaded(conversations: conversations));
    } catch (e) {
      emit(PinnedConversationsError(error: e.toString()));
    }
  }
}
