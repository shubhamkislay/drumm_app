import 'package:bloc/bloc.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/create_conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final CreateConversationUseCase createConversationUseCase;

  ConversationBloc({required this.createConversationUseCase})
      : super(ConversationInitial()) {
    on<CreateConversationEvent>(_onCreateConversation);
  }

  Future<void> _onCreateConversation(
      CreateConversationEvent event,
      Emitter<ConversationState> emit,
      ) async {
    emit(ConversationLoading());
    try {
      await createConversationUseCase(event.conversation);
      emit(ConversationSuccess());
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }
}
