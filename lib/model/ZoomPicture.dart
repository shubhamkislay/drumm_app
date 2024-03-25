import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ZoomPicture extends StatelessWidget {
  String url;
  String? articleId;
  ZoomPicture({Key? key, required this.url, this.articleId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = url.isEmpty?"https://placekitten.com/200/300":url;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          PinchZoom(
            maxScale: 10,
            child: Image.network(imageUrl),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(12),
              width: double.maxFinite,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 32,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
