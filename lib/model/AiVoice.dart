import 'package:cloud_firestore/cloud_firestore.dart';

class AiVoice {
  String? aiVoiceUrl;
  String? content;

  AiVoice({
    this.aiVoiceUrl,
    this.content,
  });

  Map<String, dynamic> toJson() => {
    'aiVoiceUrl': aiVoiceUrl,
    'content': content,
  };

  AiVoice.fromSnapshot(snapshot)
      : aiVoiceUrl = snapshot.data()['aiVoiceUrl'],
        content = snapshot.data()['content'];

}
