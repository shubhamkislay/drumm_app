import 'package:flutter/material.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class SkeletonFeed extends StatefulWidget {
  const SkeletonFeed({Key? key}) : super(key: key);

  @override
  State<SkeletonFeed> createState() => _SkeletonFeedState();
}

class _SkeletonFeedState extends State<SkeletonFeed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color:  Colors.black,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(
                left: 0, top: 100, right: 76, bottom: 64),
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [
            //       Colors.transparent,
            //       Colors.transparent,
            //       Colors.black.withOpacity(0.2),
            //       Colors.black.withOpacity(0.6),
            //       Colors.black
            //           .withOpacity(0.5), //.withOpacity(0.95),
            //     ],
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //   ),
            // ),
            child: Container(
              height: 110,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                //  color: Colors.black.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 20,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 20,
                    width: 175,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 32,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 20,
              width: 100,
            ),
          ),
          Positioned(
            left: 12,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 20,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  height: 40,
                  width: 40,
                ),
                // if ((articles!.elementAt(index).likes ?? 0) > 0)
                SizedBox(
                  height: 36,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  height: 40,
                  width: 40,
                ),
                SizedBox(
                  height: 36,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  height: 40,
                  width: 40,
                ),
                SizedBox(
                  height: 36,
                ),
                // ArticleChannel(
                //   articleID:
                //       artcls?.elementAt(index).articleId ?? "",
                //   height: iconHeight,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
