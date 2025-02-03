import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SourceWidget extends StatelessWidget {
  GetSimilarArticlesParams params;
  SourceWidget({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (BuildContext context) => s1()..add(GetSimilarArticles(params)),
      child: BlocBuilder<RemoteArticlesBloc,RemoteArticlesState>(builder: (context, state) { return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
            horizontal: 0, vertical: 12),
        child: Wrap(
          runSpacing: 8.0,
          crossAxisAlignment:
          WrapCrossAlignment.center,
          runAlignment: WrapAlignment.start,
          spacing: 4,
          alignment: WrapAlignment.start,
          children: (state.articleEntityList!.articleList??[]).map(
                (article) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OpenArticlePage(
                            article: article,
                          ),
                    ));
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 4,
                    top: 4,
                    bottom: 4,
                    right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius:
                  BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                        borderRadius:
                        BorderRadius
                            .circular(24),
                        child:
                        CachedNetworkImage(
                          imageUrl: article
                              .imageUrl ??
                              "",
                          height: 20,
                          width: 20,
                          fit: BoxFit.cover,
                        )),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      article.source ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily:
                          DRUMM_FONT_FAMILY),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
        ),
      ); },
      ),
    );
  }
}
