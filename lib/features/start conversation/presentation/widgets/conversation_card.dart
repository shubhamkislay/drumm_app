import 'package:drumm_app/features/start%20conversation/domain/entities/conversation.dart';
import 'package:flutter/material.dart';

class ConversationCard extends StatelessWidget {
  final ConversationEntity conversation;

  const ConversationCard({Key? key, required this.conversation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Adjust card width as needed.
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              conversation.title ?? 'Untitled',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              conversation.question ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}