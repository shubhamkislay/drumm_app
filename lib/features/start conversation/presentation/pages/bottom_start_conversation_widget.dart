import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_event.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/start_drumm_button.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/conversation_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pin_conversation_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pin_conversation_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/widgets/conversation_share_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../../../drumm audio/presentation/pages/drumm_audio_bottom_sheet.dart';

class BottomStartConversationWidget extends StatelessWidget {
  final ArticleEntity article;
  final List<BandEntity> ? bands;
  final DrummerEntity drummerEntity;
  String selectedBandId = "";
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  BottomStartConversationWidget(
      {super.key,
      required this.article,
      required this.bands,
      required this.drummerEntity});
  @override
  Widget build(BuildContext context) {
    selectedBandId = (((bands??[]).isNotEmpty)?bands?.first.bandId:"")!;//(bands?.first.bandId??"broadcast");
    analytics.logEvent(
      name: 'start_conversation_option',
      parameters: <String, Object>{
        'category': article.category??"",
        'article_title': article.title??"",
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    const textStyle = TextStyle(
      fontSize: 32.0,
      height: 1.5,
    );
    return Material(
      color: Colors.transparent, // Transparent background
      child: Align(
        alignment: Alignment.bottomCenter, // Bottom Sheet Position
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: DrummTheme.drummPrimaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Align(
            alignment: Alignment.bottomCenter, // B
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      color: Colors.white,
                      width: 32,
                      "images/team_active.png",
                      height: 32,
                    ),
                   if((bands??[]).isNotEmpty) SizedBox(
                      height: 75,
                      width: 150,
                      child: CupertinoPicker(
                        itemExtent: textStyle.fontSize!,
                        diameterRatio: 5,
                        magnification: 1.15,
                        squeeze: 1,
                        selectionOverlay:
                            CupertinoPickerDefaultSelectionOverlay(
                          background: Colors.black.withAlpha(25),
                        ),
                        onSelectedItemChanged: (index) {
                          print("Band Name ${bands?[index].name}");
                          selectedBandId = bands?[index].bandId??"broadcast";
                        },
                        children: List.generate(
                          (bands??[]).length,
                          (index) {
                            return Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(8.0),
                              child: Text(
                                '${(bands??[])[index].name}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: DRUMM_FONT_FAMILY),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if((bands??[]).isEmpty)BlocBuilder<RemoteBandsBloc,RemoteBandsState>(builder: (context,state){
                      if(state is RemoteBandsFetched) {
                        selectedBandId = (((state.bands??[]).isNotEmpty)?state.bands?.first.bandId:"")!;
                        print("SelectedBandId is $selectedBandId");
                        return SizedBox(
                          height: 75,
                          width: 150,
                          child: CupertinoPicker(
                            itemExtent: textStyle.fontSize!,
                            diameterRatio: 5,
                            magnification: 1.15,
                            squeeze: 1,
                            selectionOverlay:
                            CupertinoPickerDefaultSelectionOverlay(
                              background: Colors.black.withAlpha(25),
                            ),
                            onSelectedItemChanged: (index) {
                              print("Band Name ${state.bands![index].name}");
                              selectedBandId = state.bands![index].bandId??"broadcast";
                            },
                            children: List.generate(
                              state.bands!.length,
                                  (index) {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${state.bands![index].name}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: DRUMM_FONT_FAMILY),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }else{
                        return SizedBox.shrink();
                      }
                    }),
                    SizedBox(
                      width: 32,
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Container(
                  height: 135,
                  padding: const EdgeInsets.all(16.0),
                  child: AutoSizeText(
                    "${article.question}",
                    maxFontSize: 32,
                    minFontSize: 12,
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontFamily: DRUMM_FONT_FAMILY),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConversationShareButton(conversation: createConversation(article, drummerEntity, context),),
                      StartDrummButton(
                        article: ArticleEntity(articleId: ""),
                        size: 92,
                        buttonText: "Tap to start a conversation",
                        onPressed: () {

                          analytics.logEvent(
                            name: 'start_conversation',
                            parameters: <String, Object>{
                              'category': article.category??"",
                              'article_title': article.title??"",
                              'timestamp': DateTime.now().toIso8601String(),
                            },
                          );

                          Navigator.pop(context);
                          Vibrate.feedback(FeedbackType.impact);
                          context
                              .read<UserActivityBloc>()
                              .add(RecordUserActivity(UserActivityEntity(
                                type: INTERACTION_STARTED,
                                weight: WEIGHT_STARTED,
                                articleId: article.articleId!,
                                embedding: article.embedding!,
                              )));

                          uploadConversation( context,false);
                        },
                        background: Colors.black.withAlpha(25),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          Vibrate.feedback(FeedbackType.impact);
                          context
                              .read<UserActivityBloc>()
                              .add(RecordUserActivity(UserActivityEntity(
                            type: INTERACTION_STARTED,
                            weight: WEIGHT_STARTED,
                            articleId: article.articleId!,
                            embedding: article.embedding!,
                          )));

                          uploadConversation( context,true);
                          context.read<PinnedConversationsBloc>().add(
                              LoadPinnedConversationsEvent(
                                  onlyCurrentUser: false));


                          analytics.logEvent(
                            name: 'pin_article',
                            parameters: <String, Object>{
                              'category': article.category??"",
                              'article_title': article.title??"",
                              'timestamp': DateTime.now().toIso8601String(),
                            },
                          );
                        },
                        child: Container(
                          height: 42,
                          width: 42,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black.withAlpha(25),
                              borderRadius: BorderRadius.circular(24)),
                          child: Image.asset('images/pin_select.png',
                              color: DrummTheme.primaryTextColorDark, fit: BoxFit.contain),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startOrSwitchChannel(BuildContext context, int uid,String conversationId, ConversationEntity conversation) {
    context.read<DrummAudioBloc>().add(
          StartOrSwitchChannelEvent(
            conversation: conversation,
            appId: DrummConstants.appId,
            token: DrummConstants.generateAgoraToken(
                uid.toString(), conversationId),
            channelName: conversationId,
            uid: uid,
            isMuted: false,
          ),
        );
    context.read<NotificationBloc>().add(
      SendNotificationEvent(
        conversation: conversation,
        drummer: drummerEntity,
      ),
    );

    _showCallBottomSheet(context, conversation);
  }

  void _showCallBottomSheet(BuildContext context, ConversationEntity conversation) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return DrummAudioBottomSheet(channelName: conversation.conversationId ?? "",conversation: conversation,drummerEntity: drummerEntity,);
      },
      isScrollControlled: true, // optional for a full-screen bottom sheet
    );
  }

  ConversationEntity createConversation(
      ArticleEntity article, DrummerEntity drummerEntity, BuildContext context,
      {bool pinned = false}) {
    // Get current user id from Firebase Auth
    final String? currentUserId = drummerEntity.uid;

    String conversationId = article.jamId! + currentUserId!;

    // Create a new conversation entity. You can set conversationId to a custom value or null.

    final conversation = ConversationEntity(
        conversationId: conversationId, // or generate one if needed
        title: article.title,
        meta: article.meta,
        articleId: article.articleId,
        bandId: selectedBandId,
        category: article.category,
        country: article.country,
        description: article.description,
        url: article.url,
        imageUrl: article.imageUrl,
        publishedAt: article.publishedAt,
        boostamp: article.boostamp,
        question: article.question,
        summary: article.summary,
        content: article.content,
        clusterId: article.clusterId,
        similarId: article.similarId,
        jamId: article.jamId,
        source: article.source,
        dump: article.dump,
        liked: article.liked,
        likes: article.likes,
        reads: article.reads,
        boosts: article.boosts,
        uid: article.uid,
        aiVoiceUrl: article.aiVoiceUrl,
        embedding: article.embedding,
        relatedImageUrls: article.relatedImageUrls,
        lastActive: Timestamp.now(),
        startTime: Timestamp.now(),
        startedBy: currentUserId,
        pinned: pinned,
        pinnedAt: Timestamp.now());

    return conversation;


  }

  uploadConversation(BuildContext context, bool pinned){
    // Dispatch the event to create a conversation.
    ConversationEntity conversation = createConversation(article, drummerEntity, context,pinned: pinned);
    context
        .read<ConversationBloc>()
        .add(CreateConversationEvent(conversation: conversation));
    if (pinned) {
      pinConversation(context, conversation);
    } else {
      startConversation(context, conversation,conversation.conversationId!);
    }
  }

  void startConversation(
      BuildContext context, ConversationEntity conversation,String conversationId) {
    _startOrSwitchChannel(context, (drummerEntity.rid) ?? 11,conversationId,conversation);
  }

  void pinConversation(BuildContext context, ConversationEntity conversation) {
    context
        .read<PinConversationBloc>()
        .add(CreatePinConversationEvent(conversation: conversation));
  }
}
