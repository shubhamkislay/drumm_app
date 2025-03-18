import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_bloc.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_event.dart';
import 'package:drumm_app/core/features/get%20drummer/presentation/bloc/remote_drummer_state.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_state.dart';
import 'package:drumm_app/core/features/notification/presentation/widgets/notification_item.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_state.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/widgets/drumm_audio_floating.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/music_player_state.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_bloc.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_event.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/bloc/podcast_state.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/pages/music_player_bottom_sheet.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_item_loading_card.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/article_list_widget.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/custom_band_list.dart';
import 'package:drumm_app/features/drumm%20podcast%20player/presentation/widgets/podcast_list_widget.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/profile_image_icon.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/safe_area_persistent_header_delegate.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/search_button.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/pages/join_conversation_confirmation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/conversation_horizontal_list.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/pinned_conversations_horizontal_list.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../drumm podcast player/presentation/widgets/floating_music_player.dart';

class NewsDiscoveryPage extends StatelessWidget {
  const NewsDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'NewsDiscoveryPage',
      parameters: <String, Object>{
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    requestPermissions();
    List<ArticleEntity> articleList = [];
    List<BandEntity>? bands = [];
    var lastDocument;
    String selectedBandId = "For You";
    RemoteArticlesState remoteState = RemoteArticlesLoading();
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<RemoteDrummerBloc, RemoteDrummerState>(
          builder: (context, drummerState) {
        if (drummerState is RemoteDrummerDone ||
            drummerState is RefreshedDrummer) {
          if (drummerState is RefreshedDrummer) {
            articleList.clear();
          }

          context.read<RemoteArticlesBloc>().add(GetRecommendedArticles(
              GetArticlesParams(
                  category: [selectedBandId],
                  drummerEntity: drummerState.drummerEntity)));
        }
        if (drummerState is RemoteDrummerLoading) {
          articleList.clear();
        }
        return BlocListener<NotificationBloc, NotificationState>(
          listener: (context, notificationState) {
            if (notificationState is ForegroundConversationNotificationLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AnimatedSnackBar(
                        builder: ((context) {
                          return ForegroundNotificationItem(
                            conversation: notificationState.conversation,
                            drummerEntity:
                                drummerState.drummerEntity ?? DrummerEntity(),
                          );
                        }),
                        duration: const Duration(seconds: 8),
                        mobileSnackBarPosition: MobileSnackBarPosition.bottom)
                    .show(context);
              });
            } else if (notificationState
                is BackgroundConversationNotificationLoaded) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // enables custom height sizing
                backgroundColor:
                    Colors.transparent, // for rounded corners effect
                builder: (BuildContext context) {
                  return JoinConversationConfirmation(
                    sendNotification: false,
                    conversation: notificationState.conversation,
                    drummerEntity:
                        drummerState.drummerEntity ?? DrummerEntity(),
                  );
                },
              );
            } else if (notificationState
                is BackgroundPodcastNotificationLoaded) {
              //print("Trying to play ${notificationState.podcast}");
              context
                  .read<MusicPlayerBloc>()
                  .add(LoadMusic(notificationState.podcast));
              showModalBottomSheet(
                context: context,
                isScrollControlled:
                    true, // Enables full-screen bottom sheet behavior.
                builder: (_) =>
                    MusicPlayerBottomSheet(podcast: notificationState.podcast),
              );
            } else if (notificationState
                is ForegroundPodcastNotificationLoaded) {
              context.read<PodcastBloc>().add(GetPodcastsEvent());
            } else if (notificationState is NavigateToArticleState) {
              //print("Opening link");
              showModalBottomSheet(
                context: context,
                builder: (_) => BlocProvider.value(
                    value: context
                        .read<UserActivityBloc>(), // Provide the existing bloc
                    child: ReadArticlePage(
                      article: notificationState.article,
                      bands: bands ?? [],
                      drummerEntity:
                          drummerState.drummerEntity ?? DrummerEntity(),
                    )),
                isScrollControlled: true, // For making the sheet extendable
                backgroundColor: Colors.transparent,
              );
            }
          },
          child: BlocBuilder<RemoteBandsBloc, RemoteBandsState>(
            builder: (BuildContext context, bandState) {
              SliverAppBar sliverAppBar = SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 12),
                      child: const BandsPlaceHolder(),
                    )),
                flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        DrummTheme.primaryItemBackground(context),
                        DrummTheme.primaryItemBackground(context)
                            .withOpacity(0.75),
                        DrummTheme.primaryItemBackground(context)
                            .withOpacity(0.0),
                      ],
                    )),
                  );
                }),
                toolbarHeight: 0,
                collapsedHeight: 0,
                expandedHeight: 24,
              );
              if (bandState is RemoteBandsFetched) {
                bands = bandState.bands;
                sliverAppBar = SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  bottom: PreferredSize(
                      preferredSize: Size.fromHeight(50),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(bottom: 12),
                        child: CustomBandSelectContainer(
                          bandEntities: bands ?? [],
                          onSelect: (BandEntity bandEntity) {
                            //print("Selected Band Id : ${bandEntity.bandId}");
                            selectedBandId = bandEntity.bandId ?? "For You";
                            context.read<RemoteArticlesBloc>().add(
                                  GetArticlesFromDifferentCategory(
                                    GetArticlesParams(
                                      category: [
                                        bandEntity.bandId ?? "For You"
                                      ],
                                      lastDocument: null,
                                    ),
                                  ),
                                );
                          },
                        ),
                      )),
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DrummTheme.primaryItemBackground(context),
                          DrummTheme.primaryItemBackground(context)
                              .withOpacity(0.75),
                          DrummTheme.primaryItemBackground(context)
                              .withOpacity(0.0),
                        ],
                      )),
                      child: FlexibleSpaceBar(
                        collapseMode: CollapseMode.none,
                        background: Container(
                          alignment: Alignment.bottomLeft,
                          padding:
                              EdgeInsets.only(left: 10, bottom: 64, right: 10),
                          width: double.maxFinite,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Stories",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontFamily: DRUMM_FONT_HEADINGS,
                                  color: DrummTheme.primaryTextColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  expandedHeight: 64,
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.axisDirection ==
                          AxisDirection.down &&
                      scrollNotification is ScrollUpdateNotification &&
                      scrollNotification.metrics.extentAfter < 500 &&
                      remoteState is! RemoteArticlesLoadingMoreArticles &&
                      remoteState is! GeneratingRecommendation &&
                      remoteState is! RemoteArticlesLoading &&
                      remoteState is! RemoteArticlesError) {
                    context.read<RemoteArticlesBloc>().add(
                          GetArticles(GetArticlesParams(
                            category: [selectedBandId],
                            lastDocument: lastDocument,
                          )),
                        );
                  }
                  return false;
                },
                child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                  builder: (context, articleState) {
                    lastDocument = articleState.articleEntityList?.lastDocument;
                    remoteState = articleState;
                    return Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            articleList.clear();
                            final bloc = context.read<RemoteDrummerBloc>();
                            bloc.add(RefreshDrummer());
                            await bloc.stream.firstWhere(
                              (state) =>
                                  state is RefreshedDrummer ||
                                  state is RemoteDrummerError,
                            );
                          },
                          color: DrummTheme.drummPrimaryColor,
                          child: CustomScrollView(
                            shrinkWrap: true,
                            slivers: [
                              SliverAppBar(
                                pinned: false,
                                backgroundColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                flexibleSpace: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        DrummTheme.primaryItemBackground(context),
                                        DrummTheme.primaryItemBackground(context)
                                            .withOpacity(0.75),
                                        DrummTheme.primaryItemBackground(context)
                                            .withOpacity(0.0),
                                      ],
                                    )),
                                    child: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.none,
                                      background: Container(
                                        alignment: Alignment.bottomLeft,
                                        padding: EdgeInsets.only(
                                            left: 10, bottom: 0, right: 10),
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // GestureDetector(
                                            //     onTap:(){
                                            //       final bloc = context.read<RemoteDrummerBloc>();
                                            //       bloc.add(GetDrummer());
                                            //     },
                                            //     child: Image.asset("images/logo_icon.png",height: 28,width: 28,color: DrummTheme.primaryTextColor(context),)),
                                            // SizedBox(width: 4,),
                                            Text(
                                              "Discover",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontFamily: DRUMM_FONT_HEADINGS,
                                                color:
                                                    DrummTheme.primaryTextColor(
                                                        context),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Expanded(child: SizedBox()),
                                            SearchButton(
                                              onPressed: () {
                                                List<Object> parameters = [];
                                                parameters.add(
                                                    drummerState.drummerEntity ??
                                                        DrummerEntity());
                                                parameters
                                                    .add(bandState.bands ?? []);
                                                context.push(
                                                    SCREEN_SEARCH_ARTICLE_PAGE,
                                                    extra: parameters);
                                              },
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            ProfileImageIcon(state: drummerState)
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                toolbarHeight: 0,
                                collapsedHeight: 0,
                                expandedHeight: 56,
                              ),
                              const SliverToBoxAdapter(
                                child: PodcastListWidget(),
                              ),
                              const SliverToBoxAdapter(
                                child: ConversationHorizontalList(),
                              ),
                              const SliverToBoxAdapter(
                                child: PinnedConversationsWidget(),
                              ),
                              sliverAppBar,
                              if (remoteState is GeneratingRecommendation)
                                SliverAppBar(
                                  pinned: true,
                                  toolbarHeight: 0,
                                  collapsedHeight: 0,
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  flexibleSpace: Container(
                                    height: 44,
                                    width: double.maxFinite,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color:
                                            DrummTheme.primaryItemColor(context)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Shimmer(
                                        color:
                                            DrummTheme.primaryTextColor(context),
                                        duration: Duration(milliseconds: 2000),
                                        interval: Duration(milliseconds: 0),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Lottie.asset(
                                                    'images/sparkle.json',
                                                    fit: BoxFit.contain,
                                                    height: 32,
                                                    width: 32),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  "Fetching news that you might be interested in...",
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: DrummTheme
                                                          .primaryTextColor(
                                                              context),
                                                      fontFamily:
                                                          DRUMM_FONT_FAMILY,
                                                      fontSize: 12),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (remoteState is RemoteArticlesLoading)
                                SliverAppBar(
                                  pinned: true,
                                  toolbarHeight: 0,
                                  collapsedHeight: 0,
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  flexibleSpace: Container(
                                    height: 44,
                                    width: double.maxFinite,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color:
                                            DrummTheme.primaryItemColor(context)),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 4,
                                            color: DrummTheme.drummPrimaryColor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Checking what's happening around the world",
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: DrummTheme.primaryTextColor(
                                                  context),
                                              fontFamily: DRUMM_FONT_FAMILY,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              if (remoteState is GeneratedRecommendationArticle)
                                SliverAppBar(
                                  pinned: true,
                                  toolbarHeight: 0,
                                  collapsedHeight: 0,
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  flexibleSpace: GestureDetector(
                                    onTap: () {
                                      articleList.clear();
                                      context.read<RemoteArticlesBloc>().add(
                                            GetArticles(GetArticlesParams(
                                              category: [selectedBandId],
                                            )),
                                          );
                                    },
                                    child: Container(
                                      height: 44,
                                      width: double.maxFinite,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 12),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: DrummTheme.drummPrimaryColor),
                                      child: const Text(
                                        "New Updates",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: DRUMM_FONT_FAMILY,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              const SliverToBoxAdapter(
                                child: ArticleListWidget(),
                              ),
                            ],
                          ),
                        ),
                        // Conditionally show the floating mini-player only if:
                        // 1. Music is loaded (duration is available and non-zero)
                        // 2. The track has not finished playing (position is less than duration)

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BlocBuilder<DrummAudioBloc, DrummAudioState>(
                                  builder: (context, state) {
                                //print("DrummAudioState State is $state");
                                if (state.conversation.conversationId != null &&
                                    state is! DrummAudioLoading &&
                                    state is! DrummAudioError &&
                                    state is! DrummAudioInitial &&
                                    state is! DrummAudioLeft) {

                                  //print("Conversation meta is ${state.conversation.meta}");

                                  return DrummAudioFloatingWidget(
                                      drummerEntity: drummerState.drummerEntity ??
                                          DrummerEntity(),
                                      conversation: state.conversation);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                                builder: (context, state) {
                                  final loaded = state.duration != null &&
                                      state.duration!.inMilliseconds > 0;
                                  final finished = loaded &&
                                      state.position.inMilliseconds >=
                                          state.duration!.inMilliseconds;
                                  if (!loaded || finished) {
                                    return const SafeArea(
                                      bottom: true,
                                      top: false,
                                      child: SizedBox.shrink(),
                                    );
                                  }
                                  ////print("MusicPlayerState is ${state}");
                                  return FloatingMusicPlayer(
                                    podcast: state.podcast,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
  }
}
