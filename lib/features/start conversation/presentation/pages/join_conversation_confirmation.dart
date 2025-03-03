import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/news%20feed/data/models/article.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinConversationConfirmation extends StatelessWidget {
  final DrummerEntity drummerEntity;
  final ConversationEntity conversation;

  const JoinConversationConfirmation(
      {Key? key, required this.drummerEntity, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5, // 50% of the screen height
      child: Container(
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
                  onTap: (){
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => BlocProvider.value(
                          value: context
                              .read<UserActivityBloc>(), // Provide the existing bloc
                          child: ReadArticlePage(
                            article: ArticleModel.fromConversation(conversation),
                            bands: [],
                            drummerEntity: drummerEntity,
                          )),
                      isScrollControlled: true, // For making the sheet extendable
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Icon(Icons.open_in_full_rounded)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
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
                  child: CachedNetworkImage(imageUrl: conversation.imageUrl??"",height: 150,width: 150,fit: BoxFit.cover,),
                ),
                SizedBox(height: 24,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${conversation.meta}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: (){
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
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DrummTheme.drummPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Join conversation", style: TextStyle(color: Colors.white,fontFamily: DRUMM_FONT_FAMILY,fontSize: 14),),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
