import 'package:blur/blur.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:drumm_app/article_jam_page.dart';
import 'package:drumm_app/custom/helper/AudioChannelWidget.dart';
import 'package:drumm_app/view_article_jams.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'custom/ai_summary.dart';
import 'custom/helper/firebase_db_operations.dart';
import 'custom/rounded_button.dart';
import 'model/article.dart';

class OpenArticlePage extends StatefulWidget {
  Article article;
  OpenArticlePage({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<OpenArticlePage> createState() => _OpenArticlePageState();
}

class _OpenArticlePageState extends State<OpenArticlePage> with RouteAware {
  late WebViewController controller;
  bool isContainerVisible = true;
  int _progress = 0;

  bool joinedChannel = false;
  late Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        //article.liked = true;
        Navigator.pop(context, widget.article);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text("${widget.article.source}",style: TextStyle(
              fontFamily: APP_FONT_BOLD,
            ),),
            backgroundColor: Colors.black),
        body: Column(
          children: [
            if (_progress < 85) LinearProgressIndicator(value: _progress / 100),
            Expanded(
              child: Listener(
                onPointerMove: (PointerMoveEvent event) {
                  if (event.delta.dy < 0) {
                    // Dragging upwards
                    setState(() {
                      isContainerVisible = false;
                    });
                  } else {
                    // Dragging downwards
                    setState(() {
                      isContainerVisible = true;
                    });
                  }
                },
                child: WebViewWidget(
                  controller: controller,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isContainerVisible ? 100 : 0,
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              width: double.maxFinite,
              color: Colors.black, // Apply app theme background color
              child: Transform.translate(
                offset: Offset(0, isContainerVisible ? 0 : 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RoundedButton(
                      padding: 12,
                      height: 52,
                      color: widget.article.liked ?? false
                          ? Colors.red
                          : Colors.white,
                      bgColor: Colors.grey.withOpacity(0.1),
                      onPressed: () {
                        setState(() {
                          if (widget.article.liked ?? false) {
                            FirebaseDBOperations.removeLike(
                                widget.article.articleId);
                            setState(() {
                              widget.article.liked = false;
                              int currentLikes = widget.article.likes ?? 1;
                              currentLikes -= 1;
                              widget.article.likes = currentLikes;
                              //_articlesController.add(articles);
                            });
                          } else {
                            FirebaseDBOperations.updateLike(
                                widget.article.articleId);
                            setState(() {
                              widget.article.liked = true;
                              int currentLikes = widget.article.likes ?? 0;
                              currentLikes += 1;
                              widget.article.likes = currentLikes;
                              // _articlesController.add(articles);
                            });

                            Vibrate.feedback(FeedbackType.impact);
                          }
                        });
                      },
                      assetPath: widget.article.liked ?? false
                          ? 'images/liked.png'
                          : 'images/heart.png',
                    ),
                    RoundedButton(
                      padding: 12,
                      height: 48,
                      color: Colors.white,
                      bgColor: Colors.grey.withOpacity(0.1),
                      onPressed: () {
                        AISummary.showBottomSheet(
                            context, widget.article ?? Article(), Colors.black);
                      },
                      assetPath: 'images/sparkles.png',
                    ),
                    if (false)
                      RoundedButton(
                        padding: 12,
                        height: 60,
                        color: Colors.white,
                        bgColor: Colors.grey.withOpacity(0.1),
                        onPressed: () {},
                        assetPath: 'images/chat.png',
                      ),
                   if(false) ArticleChannel(
                      articleID: widget.article.articleId ?? "",
                      height: 60,
                    ),
                    RoundedButton(
                      padding: 10,
                      height: 48, //iconHeight,
                      color: Colors.white,
                      bgColor: Colors.grey.shade600
                          .withOpacity(0.30),
                      onPressed: () {
                        // AISummary.showBottomSheet(
                        //     context,
                        //     artcls!.elementAt(index) ?? Article(),
                        //     Colors.transparent);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                child: ArticleJamPage(article: article,),
                              ),
                            );
                          },
                        );

                      },
                      assetPath: 'images/drumm_logo.png',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    initController();
    article = widget.article;
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.resumed.toString()) {
        // Enable default back navigation when the app is resumed
        SystemNavigator.pop();
      }
      return null;
    });
  }

  void initController() async {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if(mounted)
            setState(() {
              _progress = progress;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url ?? ""));

    FirebaseDBOperations.updateReads(widget.article.articleId);
    int currentReads = widget.article.reads ?? 0;
    currentReads += 1;
    widget.article.reads = currentReads;
  }
}
