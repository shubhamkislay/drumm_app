import 'package:drumm_app/features/drumm%20podcast%20player/domain/usecases/fetch_podcast_usecase.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PodcastBloc extends Bloc<PodcastEvent, PodcastState> {
  final FetchPodcastsUseCase fetchPodcastsUseCase;

  PodcastBloc(this.fetchPodcastsUseCase) : super(PodcastInitial()) {
    on<GetPodcastsEvent>((event, emit) async {
      emit(PodcastLoading());
      try {
        final podcasts = await fetchPodcastsUseCase();
        emit(PodcastLoaded(podcasts));
      } catch (e) {
        emit(PodcastError(e.toString()));
      }
    });
  }
}
