import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/model/article.dart';

import 'band.dart';

class ArticleBand {
  Article? article;
  Band? band;

  ArticleBand(
      {this.article,
        this.band});

}
