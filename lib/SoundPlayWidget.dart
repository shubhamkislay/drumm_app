import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:path_provider/path_provider.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'model/article.dart';

class SoundPlayWidget extends StatefulWidget {
  Article article;
  bool play;
  double? imageSize;
  double? paddingSize;
  Color? backgroundColor;
  VoidCallback? onPressed;
  SoundPlayWidget({super.key, required this.article, required this.play,this.imageSize,
    this.paddingSize,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  State<SoundPlayWidget> createState() => _SoundPlayWidgetState();
}

class _SoundPlayWidgetState extends State<SoundPlayWidget> {
  String status = "idle";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed;
        if(status == "loading"){
          try {
            //audioPlayer.stop();
            FirebaseDBOperations.OggOpus_Player.pause();
            FirebaseDBOperations.OggOpus_Player.dispose();
            setState(() {
              status = "idle";
              widget.play = false;
            });
            return;
          } catch (e) {}
        }
        if (status == "idle"||!widget.play) {

          setState(() {
            status = "loading";
          });


          convertTextToSpeech(
              getSpeechText(widget.article) ?? "",
              widget.article.articleId ?? "");
          //widget.playPause(widget.play);
        } else {
          setState(() {
            status = "idle";
            widget.play = false;
          });
          try{
            FirebaseDBOperations.OggOpus_Player.pause();
            FirebaseDBOperations.OggOpus_Player.dispose();
          }catch(err){

          }
          //widget.playPause(widget.play);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 0.0,right: 0),
        alignment: Alignment.center,
        child: Container(
          height: widget.paddingSize??28, //44
          width: widget.paddingSize??28,
          alignment: Alignment.center,
          //padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: widget.backgroundColor??Colors.grey.shade900.withOpacity(0.85),
            border: Border.all(color: (widget.play)?Colors.white38:Colors.grey.shade900.withOpacity(0.85),width: 2)
          ),
          child:
         Stack(
           alignment: Alignment.center,
            children: [
              if(status == "loading") SizedBox(
                height: widget.paddingSize??26,
                width: widget.paddingSize??26,
                child: const CircularProgressIndicator(
                  color: Colors.white38,
                  strokeWidth: 2,
                ),
              ),
              Image.asset(
                (status == "playing" && widget.play) ? 'images/volume-on.png' :'images/volume-off.png',
                height: widget.imageSize??12,//20
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? getSpeechText(Article articleForSpeech) {
    //return articleForSpeech.question;
    String? text = (articleForSpeech.summary!=null)?articleForSpeech.summary:(articleForSpeech.description == null)
        ? (articleForSpeech.content == null)?articleForSpeech.title:articleForSpeech.content
        : "${articleForSpeech.description}";
    if (articleForSpeech.question != null) {
      text =
      "$text\n${articleForSpeech.question}\nStart a drumm to check what the community thinks!";
    }else {
      text =
      "$text\nStart a drumm to check what the community thinks!";
    }

    return text;
  }

  Future<void> convertTextToSpeech(String text, String id) async {
    try {
      //audioPlayer.stop();
      FirebaseDBOperations.OggOpus_Player.pause();
      FirebaseDBOperations.OggOpus_Player.dispose();
    } catch (e) {}
    final apiKey = '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';
    final endpoint = 'https://api.openai.com/v1/audio/speech';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Define a list of voices
    final voices = [
      'alloy',
      'fable',
      'echo',
      'onyx',
      'nova',
      'shimmer'
    ]; //'echo', 'onyx', 'nova', 'shimmer'

    // Randomly select a voice from the list
    final random = Random();
    final selectedVoice = voices[random.nextInt(voices.length)];

    // Set the selected voice in the data
    final data = {
      'input': text,
      'model': 'tts-1',
      'voice': selectedVoice,
      'response_format': 'opus',
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      //  //await audioPlayer.play(BytesSource(response.bodyBytes));
      final audioBytes = response.bodyBytes;
      final appDir = await getApplicationDocumentsDirectory();
      final audioFile = File('${appDir.path}/$id.opus');
      await audioFile.writeAsBytes(audioBytes);
      //if (articleTop == id) {
      // audioPlayer.setFilePath(audioFile.path);
      // audioPlayer.play();

      FirebaseDBOperations.OggOpus_Player = OggOpusPlayer(audioFile.path);
      if(status == "loading") {
        FirebaseDBOperations.OggOpus_Player.play();

        setState(() {
          status = "playing";
          widget.play = true;
        });
      }

      //}
    } else {
      // Handle API error
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      status = "idle";
    });
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    try {
      setState(() {
        status = "idle";
      });
    }catch(e){}
    super.dispose();
  }
}