import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'model/article.dart';

class HeroAnimationWidget extends StatefulWidget {
  final String tag;
  final String imageUrl;
  List<Article>? preloadList;
  final int initialIndex;

   HeroAnimationWidget({
    Key? key,
    required this.tag,
    required this.imageUrl,
    required this.preloadList,
     required this.initialIndex
  }) : super(key: key);

  @override
  _HeroAnimationWidgetState createState() => _HeroAnimationWidgetState();
}

class _HeroAnimationWidgetState extends State<HeroAnimationWidget> {
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: widget.initialIndex);
    return Container(
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.preloadList?.length,
          itemBuilder: (BuildContext context, int index) {
        return Container(
          child: Hero(
            tag: widget.preloadList?.elementAt(index).articleId??"",
            child: CachedNetworkImage(
              imageUrl: widget.preloadList?.elementAt(index).imageUrl??"",
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.fitWidth,
            ),
          ),
        );
      }),
    );
  }
}
