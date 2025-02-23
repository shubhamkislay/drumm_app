
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class OpenArticlePage extends StatefulWidget {
  ArticleEntity article;
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
  late ArticleEntity article;





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
              fontFamily: DRUMM_FONT_FAMILY,
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
          ],
        ),
      ),
    );
  }

  void logOpenArticleEvent() {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'OpenArticlePage',
      parameters: <String, Object>{
        'category': article.category??"",
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void initState() {
    initController();
    article = widget.article;
    super.initState();
    logOpenArticleEvent();
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
  }
}


