import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ZoomPicture extends StatelessWidget {
  String url;
   ZoomPicture({Key? key,required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Expanded(
            child: PinchZoom(
              child: Image.network(url),
              maxScale: 10,
            ),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(12),
              width: double.maxFinite,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                  child: Icon(Icons.close_rounded,size: 32,)),
            ),
          ),
        ],
      ),
    );
  }
}
