import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';

class PinnedConversationItem extends StatelessWidget {
  final ConversationEntity conversation;
  final DrummerEntity drummerEntity;
  final VoidCallback onTap;
  const PinnedConversationItem({super.key, required this.conversation, required this.drummerEntity,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              child: Row(
                children: [
                  Image.asset("images/pin.png",color: DrummTheme.primaryTextColor(context),height: 14,width: 14,),
                  SizedBox(width: 4,),
                  Text((drummerEntity!.uid == conversation.startedBy)?'You Pinned': 'Pinned',style: TextStyle(
                      color: DrummTheme.primaryTextColor(context).withAlpha(150),
                      fontFamily: DRUMM_FONT_FAMILY,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                  ),),
                  if(drummerEntity!.uid == conversation.startedBy)
                    Expanded(child: SizedBox.shrink()),
                  if(drummerEntity!.uid == conversation.startedBy)
                    Image.asset("images/bin.png",color: DrummTheme.primaryTextColor(context).withAlpha(150),height: 18,width: 18,),
                ],
              ),
            ),
            Row(
              children: [
                CachedNetworkImage(imageUrl: conversation.imageUrl??DEFAULT_APP_IMAGE_URL,width: 36,height: 36,fit: BoxFit.cover,),
                SizedBox(width: 12,),
                Flexible(
                  child: Text(
                    conversation.meta ?? 'No Title',
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold,color: DrummTheme.primaryTextColor(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InstagramDateTimeWidget(publishedAt: conversation.pinnedAt.toString()),
          ],
        ),
      ),
    );
  }
}
