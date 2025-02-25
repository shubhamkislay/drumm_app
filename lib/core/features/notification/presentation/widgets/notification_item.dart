import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_bloc.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/bloc/drumm_audio_event.dart';
import 'package:drumm_app/features/drumm%20audio/presentation/pages/drumm_audio_bottom_sheet.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../custom/constants/Constants.dart';
import '../../../user activity/domain/entities/user_activity_entity.dart';
import '../../../user activity/presentation/bloc/user_activity_event.dart';

class ForegroundNotificationItem extends StatelessWidget {
  final ConversationEntity conversation;
  final DrummerEntity drummerEntity;
  const ForegroundNotificationItem({super.key ,required this.conversation, required this.drummerEntity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){

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
        }catch(e){
          return;
        }
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return DrummAudioBottomSheet(channelName: conversation.conversationId ?? "",conversation: conversation, drummerEntity: drummerEntity,);
          },
          isScrollControlled: true, // optional for a full-screen bottom sheet
        );
      },
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            decoration: BoxDecoration(
              color: DrummTheme.primaryItemColor(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DrummTheme.primaryItemColor(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius:
                          BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: conversation.imageUrl??"",
                            fit: BoxFit.cover,
                            width: 20,
                            height: 20,
                          )),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        "${conversation.meta} • Join Now!",
                        style: TextStyle(
                          color: DrummTheme.primaryTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
