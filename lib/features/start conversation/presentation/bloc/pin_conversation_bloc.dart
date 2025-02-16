import 'package:bloc/bloc.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/create_pinned_conversation.dart';
import 'pin_conversation_event.dart';
import 'pin_conversation_state.dart';

class PinConversationBloc extends Bloc<PinConversationEvent, PinConversationState> {
  final CreatePinConversationUseCase createPinConversation;

  PinConversationBloc({required this.createPinConversation}) : super(PinConversationInitial()) {
    on<CreatePinConversationEvent>(_onCreatePinConversation);
  }

  Future<void> _onCreatePinConversation(
      CreatePinConversationEvent event,
      Emitter<PinConversationState> emit,
      ) async {
    emit(PinConversationLoading());
    try {
      await createPinConversation(event.conversation);
      emit(PinConversationSuccess());
    } catch (e) {
      emit(PinConversationFailure(error: e.toString()));
    }
  }
}
