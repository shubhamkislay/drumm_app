import 'package:bloc/bloc.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/get_conversations.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_list_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_list_state.dart';

class ConversationListBloc extends Bloc<ConversationListEvent, ConversationListState> {
  final GetConversationsUseCase getConversationsUseCase;

  ConversationListBloc({required this.getConversationsUseCase})
      : super(ConversationListInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
  }

  Future<void> _onLoadConversations(
      LoadConversationsEvent event,
      Emitter<ConversationListState> emit,
      ) async {
    emit(ConversationListLoading());
    try {
      final conversations = await getConversationsUseCase();
      emit(ConversationListLoaded(conversations: conversations));
    } catch (e) {
      emit(ConversationListError(message: e.toString()));
    }
  }
}
