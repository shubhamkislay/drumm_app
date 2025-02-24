import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/core/util/core_utils.dart';
import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
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
          color: DrummTheme.drummPrimaryColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              conversation.title ?? 'No Title',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "${(drummerEntity!.uid == conversation.startedBy)?"You Pinned at: ":"Pinned at:"} ${CoreUtils.getFormattedTime(conversation.pinnedAt!.toDate())}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
