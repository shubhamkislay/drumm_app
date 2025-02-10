import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/instagram_date_time_widget.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/get_similar_articles_parameter.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_bloc.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_event.dart';
import 'package:drumm_app/features/news%20feed/presentation/bloc/article/remote/remote_articles_state.dart';
import 'package:drumm_app/features/open_article/presentation/pages/open_article_page.dart';
import 'package:drumm_app/features/read%20article/presentation/pages/read_article_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class SimilarArticlesWidget extends StatelessWidget {
  GetSimilarArticlesParams params;
  final List<BandEntity> bands;
  SimilarArticlesWidget({super.key, required this.params, required this.bands});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (BuildContext context) => s1()..add(GetSimilarArticles(params)),
      child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
          if(state is RemoteSimilarArticlesFetched){
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("More like this"),
                SizedBox(height: 4,),
                Container(
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
                    children: (state.articleEntityList?.articleList??[])
                        .map(
                          (article) => GestureDetector(
                        onTap: () {
                          Vibrate.feedback(FeedbackType.medium);
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ReadArticlePage(article: article, bands: bands,drummerEntity: DrummerEntity(),),
                            isScrollControlled: true, // For making the sheet extendable
                            backgroundColor: Colors.transparent,
                          );
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
                            BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              ClipRRect(
                                  borderRadius:
                                  BorderRadius
                                      .circular(12),
                                  child:
                                  CachedNetworkImage(
                                    imageUrl: article
                                        .imageUrl ??
                                        DEFAULT_IMAGE_URL,
                                    height: 24,
                                    width: 24,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return Image.asset(
                                        "images/drumm_logo.png",
                                        color: Colors.white12,
                                      );
                                    },
                                  )),
                              SizedBox(
                                width: 4,
                              ),
                              Flexible(
                                child: SizedBox(
                                  child: Text(
                                    article.meta?.trim() ?? "",
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily:DRUMM_FONT_FAMILY,

                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                " • ",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 13,
                                  fontFamily: DRUMM_FONT_FAMILY,
                                ),
                              ),
                              InstagramDateTimeWidget(
                                publishedAt: article.publishedAt
                                    .toString() ??
                                    "",
                                textSize: 13,
                                fontColor: Colors.white30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
