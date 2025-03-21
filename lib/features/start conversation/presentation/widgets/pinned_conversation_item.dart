import 'package:auto_size_text/auto_size_text.dart';
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
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: DrummTheme.primaryItemColor(context),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InstagramDateTimeWidget(publishedAt: conversation.pinnedAt.toString()),
                if(drummerEntity!.uid != conversation.startedBy)
                  Image.asset("images/pin_selected.png",color: DrummTheme.primaryTextColor(context).withAlpha(100),height: 14,width: 14,),
                if(drummerEntity!.uid == conversation.startedBy)
                  Image.asset("images/pin_selected.png",color: DrummTheme.primaryTextColor(context),height: 14,width: 14,),
              ],
            ),
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(imageUrl: conversation.imageUrl??DEFAULT_APP_IMAGE_URL,width: 36,height: 36,fit: BoxFit.cover,)),
                SizedBox(width: 12,),
                Flexible(
                  child: AutoSizeText(
                    minFontSize: 12,
                    maxFontSize: 24,
                    conversation.meta ?? 'No Title',
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold,color: DrummTheme.primaryTextColor(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
