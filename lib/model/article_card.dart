import 'package:flutter/material.dart';
import 'package:drumm_app/custom/random_custom_bk.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/question.dart';
import 'package:drumm_app/open_article_page.dart';


class ArticleCard extends StatelessWidget {
  final Article article;

  ArticleCard(this.article, {Key? key, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OpenArticlePage(article: article,
              ),
            ));
      },
      child: Container(
        margin: EdgeInsets.all(0.5),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey.shade900,
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                ),
                child: Text(
                  "${article.title}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            if (true)
              Container(
                color: Colors.cyan,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${article.reads} Views",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            if (true)
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${article.source}",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
