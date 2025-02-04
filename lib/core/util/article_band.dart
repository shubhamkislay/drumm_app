import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';

class ArticleBands {
  ArticleEntity ? article;
  List<BandEntity> ? bands;

  ArticleBands({this.article,this.bands});
}