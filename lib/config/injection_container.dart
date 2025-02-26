import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/data/data_sources/remote/band_service.dart';
import 'package:drumm_app/core/features/get%20bands/data/repository/band_repository_impl.dart';
import 'package:drumm_app/core/features/get%20bands/domain/repository/band_repository.dart';
import 'package:drumm_app/core/features/get%20bands/domain/usecases/get_bands.dart';
import 'package:drumm_app/core/features/get%20bands/domain/usecases/get_current_user_bands.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/data/data_sources/remote/drummer_service.dart';
import 'package:drumm_app/core/features/get%20drummer/data/repository/drummer_repository_impl.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/repository/drummer_repository.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer_by_rid.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer_id.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/notification/data/data_sources/notification_service.dart';
import 'package:drumm_app/core/features/notification/data/respository/notification_repository_impl.dart';
import 'package:drumm_app/core/features/notification/domain/repository/notification_repository.dart';
import 'package:drumm_app/core/features/notification/domain/usecases/send_notification_to_topic.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/data/data_sources/user_activity_service.dart';
import 'package:drumm_app/core/features/user%20activity/data/respository/user_activity_repository_impl.dart';
import 'package:drumm_app/core/features/user%20activity/domain/repository/user_activity_repository.dart';
import 'package:drumm_app/core/features/user%20activity/domain/usecases/record_user_activity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/features/authentication/data/data_sources/local/shared_preference_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/apple_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/auth_service.dart';
import 'package:drumm_app/features/authentication/data/data_sources/remote/google_sign_in_service.dart';
import 'package:drumm_app/features/authentication/data/respository/auth_repository_impl.dart';
import 'package:drumm_app/features/authentication/domain/repository/auth_repository.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/usecase/get_drummer.dart';
import 'package:drumm_app/features/authentication/domain/usecases/get_initial_screen.dart';
import 'package:drumm_app/features/authentication/domain/usecases/is_authenticated.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_apple.dart';
import 'package:drumm_app/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/hybrid/hybrid_initial_screen_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/drummer/remote/remote_auth_bloc.dart';
import 'package:drumm_app/features/authentication/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/data/data_sources/drumm_audio_service.dart';
import 'package:drumm_app/features/drumm%20audio/data/respository/drumm_audio_repository_impl.dart';
import 'package:drumm_app/features/drumm%20audio/domain/repository/drumm_repository.dart';
import 'package:drumm_app/features/drumm%20audio/domain/usecases/join_drumm_usecase.dart';
import 'package:drumm_app/features/drumm%20audio/domain/usecases/leave_drumm_usecase.dart';
import 'package:drumm_app/features/drumm%20audio/domain/usecases/listen_drumm_events_usecase.dart';
import 'package:drumm_app/features/drumm%20audio/domain/usecases/mute_drumm_audio_usecase.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/data/data_sources/podcast_remote_data_source.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/data/data_sources/podcast_remote_data_source_impl.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/data/respository/podcast_repository_impl.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/repository/podcast_repository.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/domain/usecases/fetch_podcast_usecase.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_bloc.dart';
import 'package:drumm_app/features/news%20feed/data/data_sources/remote/article_service.dart';
import 'package:drumm_app/features/news%20feed/data/respository/article_repository_impl.dart';
import 'package:drumm_app/features/news%20feed/domain/repository/article_repository.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/generate_and_load_recommended_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_clustered_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_interaction_counts.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_latest_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/get_similar_articles.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/mark_articles_as_seen.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/perform_vector_search.dart';
import 'package:drumm_app/features/news%20feed/domain/usecases/vector_search_and_load_recommended_articles.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/search%20article/data/data_sources/search_article_service.dart';
import 'package:drumm_app/features/search%20article/data/respository/search_article_repository_impl.dart';
import 'package:drumm_app/features/search%20article/domain/repository/search_article_repository.dart';
import 'package:drumm_app/features/search%20article/domain/usecases/search_articles.dart';
import 'package:drumm_app/features/search%20article/presentation/bloc/search_article_bloc.dart';
import 'package:drumm_app/features/start%20conversation/data/data_sources/conversation_service.dart';
import 'package:drumm_app/features/start%20conversation/data/respository/conversation_repository_impl.dart';
import 'package:drumm_app/features/start%20conversation/domain/repository/conversation_repository.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/create_conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/create_pinned_conversation.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/get_conversations.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/get_pinned_conversations_last24hours.dart';
import 'package:drumm_app/features/start%20conversation/domain/usecases/update_last_active.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_list_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/last_active_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pin_conversation_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_bloc.dart';
import 'package:get_it/get_it.dart';

final s1 = GetIt.instance;

Future<void> initializeDependencies() async {

  /**
   * Dependencies
   */
  //authentication
  s1.registerSingleton<AuthService>(AuthService());
  s1.registerSingleton<SharedPreferenceService>(SharedPreferenceService());
  s1.registerSingleton<AppleSignInService>(AppleSignInService());
  s1.registerSingleton<GoogleSignInService>(GoogleSignInService());
  //news feed
  s1.registerSingleton<ArticleService>(ArticleService());
  //core
  s1.registerSingleton<BandService>(BandService());
  s1.registerSingleton<DrummerService>(DrummerService());
  s1.registerSingleton<UserActivityService>(UserActivityService());
  //drumm audio
  s1.registerSingleton<DrummAudioService>(DrummAudioService());
  //drumm podcast player
  s1.registerSingleton<PodcastService>(PodcastService());
  //search article
  s1.registerSingleton<SearchArticleService>(SearchArticleService());
  //conversation
  s1.registerSingleton<ConversationService>(ConversationService());
  //notification
  s1.registerSingleton<NotificationService>(NotificationService());

  /**
   * Repositories
   */
  //authentication
  s1.registerSingleton<AuthRepository>(AuthRepositoryImpl(s1(), s1(),s1(),s1(),s1()));
  //news feed
  s1.registerSingleton<ArticleRepository>(ArticleRespositoryImpl(s1()));
  //core
  s1.registerSingleton<BandRepository>(BandRepositoryImpl(s1()));
  s1.registerSingleton<DrummerRepository>(DrummerRepositoryImpl(s1()));
  s1.registerSingleton<UserActivityRepository>(UserActivityRepositoryImpl(s1()));
  //drumm audio
  s1.registerSingleton<IDrummRepository>(DrummAudioRepositoryImpl(drummAudioService: s1()));
  //drumm podcast player
  s1.registerSingleton<PodcastRepository>(PodcastRepositoryImpl(s1()));
  //search article
  s1.registerSingleton<SearchArticleRepository>(SearchArticleRepositoryImpl(service: s1()));
  //conversation
  s1.registerSingleton<ConversationRepository>(ConversationRepositoryImpl(conversationService: s1()));
  //notification
  s1.registerSingleton<NotificationRepository>(NotificationRepositoryImpl(s1()));


  /**
   * UseCases
   */
  //authentication
  s1.registerSingleton<IsAuthenticatedUseCase>(IsAuthenticatedUseCase(s1()));
  s1.registerSingleton<GetInitialScreenUseCase>(GetInitialScreenUseCase(s1()));
  s1.registerSingleton<SignInWithAppleUseCase>(SignInWithAppleUseCase(s1()));
  s1.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(s1()));
  //news feed
  s1.registerSingleton<GetArticlesUseCase>(GetArticlesUseCase(s1()));
  s1.registerSingleton<GetLatestArticlesUseCase>(GetLatestArticlesUseCase(s1()));
  s1.registerSingleton<GetInteractionCountsUseCase>(GetInteractionCountsUseCase(s1()));
  s1.registerSingleton<PerformVectorSearchUseCase>(PerformVectorSearchUseCase(s1()));
  s1.registerSingleton<GetSimilarArticlesUseCase>(GetSimilarArticlesUseCase(s1()));
  s1.registerSingleton<GetClusteredArticlesUseCase>(GetClusteredArticlesUseCase(s1()));
  s1.registerSingleton<GenerateAndLoadRecommendedArticlesUseCase>(GenerateAndLoadRecommendedArticlesUseCase(s1()));
  s1.registerSingleton<VectorSearchAndLoadRecommendedArticlesUseCase>(VectorSearchAndLoadRecommendedArticlesUseCase(s1()));
  s1.registerSingleton<MarkArticlesAsSeenUseCase>(MarkArticlesAsSeenUseCase(s1()));
  //core
  s1.registerSingleton<GetBandsUseCase>(GetBandsUseCase(s1()));
  s1.registerSingleton<GetCurrentUserBandsUseCase>(GetCurrentUserBandsUseCase(s1()));
  s1.registerSingleton<GetDrummerUseCase>(GetDrummerUseCase(s1()));
  s1.registerSingleton<GetDrummerIdUseCase>(GetDrummerIdUseCase(s1()));
  s1.registerSingleton<GetDrummerByRidUseCase>(GetDrummerByRidUseCase(s1()));
  s1.registerSingleton<RecordUserActivityUseCase>(RecordUserActivityUseCase(s1()));
  //drumm audio
  s1.registerSingleton<JoinDrummUseCase>(JoinDrummUseCase(s1()));
  s1.registerSingleton<LeaveDrummUseCase>(LeaveDrummUseCase(s1()));
  s1.registerSingleton<ListenDrummEventsUseCase>(ListenDrummEventsUseCase(s1()));
  s1.registerSingleton<MuteDrummAudioUseCase>(MuteDrummAudioUseCase(s1()));
  //drumm podcast player
  s1.registerSingleton<FetchPodcastsUseCase>(FetchPodcastsUseCase(s1()));
  //search article
  s1.registerSingleton<SearchArticlesUseCase>(SearchArticlesUseCase(s1()));
  //conversation
  s1.registerSingleton<CreateConversationUseCase>(CreateConversationUseCase(s1()));
  s1.registerSingleton<GetConversationsUseCase>(GetConversationsUseCase(s1()));
  s1.registerSingleton<UpdateLastActiveUseCase>(UpdateLastActiveUseCase(s1()));
  s1.registerSingleton<GetPinnedConversationsLast24Hours>(GetPinnedConversationsLast24Hours(s1()));
  s1.registerSingleton<CreatePinConversationUseCase>(CreatePinConversationUseCase(s1()));
  //notification
  s1.registerSingleton<SendNotificationToTopicUseCase>(SendNotificationToTopicUseCase(s1()));


  /**
   * Bloc
   */
  //authentication
  s1.registerFactory<RemoteAuthBloc>(() => RemoteAuthBloc(s1()));
  s1.registerFactory<HybridInitialScreenBloc>(() => HybridInitialScreenBloc(s1()));
  s1.registerFactory<SignInBloc>(() => SignInBloc(s1(),s1()));
  //news feed
  s1.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(s1(),s1(),s1(),s1(),s1(),s1(),s1(),s1(),s1()));
  //core
  s1.registerFactory<RemoteDrummerBloc>(() => RemoteDrummerBloc(s1(),s1())); //get drummer
  s1.registerFactory<RemoteBandsBloc>(() => RemoteBandsBloc(s1(),s1())); //get band
  s1.registerFactory<UserActivityBloc>(() => UserActivityBloc(s1())); //record useractivity
  //drumm audio
  s1.registerFactory<DrummAudioBloc>(() => DrummAudioBloc(joinUseCase: s1(),leaveUseCase: s1(),listenUseCase: s1(),muteUseCase: s1(),repository: s1()));
  //drumm podcast player
  s1.registerFactory<MusicPlayerBloc>(() => MusicPlayerBloc());
  s1.registerSingleton<PodcastBloc>(PodcastBloc(s1()));
  //search article
  s1.registerFactory<SearchArticleBloc>(() => SearchArticleBloc(searchArticlesUseCase: s1()));
  //conversation
  s1.registerFactory<ConversationBloc>(() => ConversationBloc(createConversationUseCase: s1()));
  s1.registerFactory<ConversationListBloc>(() => ConversationListBloc(getConversationsUseCase: s1()));
  s1.registerFactory<LastActiveBloc>(() => LastActiveBloc(updateLastActiveUseCase: s1()));
  s1.registerFactory<PinConversationBloc>(() => PinConversationBloc(createPinConversation: s1()));
  s1.registerFactory<PinnedConversationsBloc>(() => PinnedConversationsBloc(getPinnedConversationsLast24Hours: s1()));
  s1.registerSingleton<NotificationBloc>(NotificationBloc(sendNotificationToTopicUseCase: s1()));



}
