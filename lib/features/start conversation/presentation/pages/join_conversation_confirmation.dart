import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:drumm_app/core/features/notification/presentation/bloc/notification_event.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/current_user_pinned_conversations_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/current_user_pinned_conversations_event.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_bloc.dart';
import 'package:drumm_app/features/start%20conversation/presentation/bloc/pinned_conversations_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinConversationConfirmation extends StatelessWidget {
  final DrummerEntity drummerEntity;
  final ConversationEntity conversation;
  final bool sendNotification;
  final bool pinConversation;
  final bool onlyCurrentUser;

  const JoinConversationConfirmation({
    Key? key,
    required this.drummerEntity,
    required this.conversation,
    required this.sendNotification,
    required this.pinConversation,
    required this.onlyCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: (pinConversation) ? 0.55 : 0.5, // 50% of the screen height
      widthFactor: 1.0,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 24,
              top: 24,
              child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => BlocProvider.value(
                          value: context.read<
                              UserActivityBloc>(), // Provide the existing bloc
                          child: ReadArticlePage(
                            article:
                                ArticleModel.fromConversation(conversation),
                            bands: [],
                            drummerEntity: drummerEntity,
                          )),
                      isScrollControlled:
                          true, // For making the sheet extendable
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Icon(Icons.open_in_full_rounded)),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                //mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(true);
                      try {
                        context.read<DrummAudioBloc>().add(
                              StartOrSwitchChannelEvent(
                                conversation: conversation,
                                appId: DrummConstants.appId,
                                token: DrummConstants.generateAgoraToken(
                                    drummerEntity.rid.toString(),
                                    conversation.conversationId ?? ""),
                                channelName: conversation.conversationId ?? "",
                                uid: drummerEntity.rid!,
                                isMuted: false,
                              ),
                            );
                      } catch (e) {
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        builder: (_) {
                          return DrummAudioBottomSheet(
                            channelName: conversation.conversationId ?? "",
                            conversation: conversation,
                            drummerEntity: drummerEntity,
                          );
                        },
                        isScrollControlled:
                            true, // optional for a full-screen bottom sheet
                      );

                      if (sendNotification) {
                        context.read<NotificationBloc>().add(
                              SendNotificationToUserEvent(
                                conversation: conversation,
                                drummer: drummerEntity,
                              ),
                            );
                      }
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DrummTheme.drummPrimaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Join conversation",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: DRUMM_FONT_FAMILY,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  if (pinConversation)
                    SizedBox(
                      height: 12,
                    ),
                  if (pinConversation)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);

                        if (onlyCurrentUser) {
                          context
                              .read<CurrentUserPinnedConversationsBloc>()
                              .add(UnpinConversationCurrentUserEvent(
                                  onlyCurrentUser: onlyCurrentUser,
                                  conversationId:
                                      conversation.conversationId!));

                          context.read<PinnedConversationsBloc>().add(
                              LoadPinnedConversationsEvent(
                                  onlyCurrentUser: false));
                        } else {
                          context.read<PinnedConversationsBloc>().add(
                              UnpinConversationEvent(
                                  onlyCurrentUser: onlyCurrentUser,
                                  conversationId:
                                      conversation.conversationId!));
                        }
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DrummTheme.primaryItemBackground(context)
                              .withAlpha(75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Unpin",
                          style: TextStyle(
                              color: DrummTheme.primaryTextColor(context),
                              fontFamily: DRUMM_FONT_FAMILY,
                              fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
                left: 24,
                top: 20,
                child: InstagramDateTimeWidget(
                  publishedAt: conversation.pinnedAt.toString(),
                  textSize: 16,
                  fontColor: DrummTheme.primaryTextColor(context),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Optional drag handle indicator
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: DrummTheme.primaryTextColor(context),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: conversation.imageUrl ?? "",
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    '${conversation.meta}',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${conversation.question}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(),

                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
