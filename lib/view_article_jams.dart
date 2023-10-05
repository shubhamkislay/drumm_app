import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/jam_image_card.dart';
import 'package:drumm_app/theme/theme_constants.dart';

import 'model/article.dart';

class ViewArticleJam extends StatefulWidget {
  Article? article;
  ViewArticleJam({Key? key, this.article}) : super(key: key);

  @override
  State<ViewArticleJam> createState() => ViewArticleJamState();
}

class ViewArticleJamState extends State<ViewArticleJam> {
  String profileImageUrl = "";
  Article? article = Article();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: COLOR_PRIMARY_DARK,//Colors.black,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                if (article?.category != null)
                  Container(
                    height: 250,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          imageUrl: article?.imageUrl ??
                              "", //widget.article?.imageUrl ?? "",
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorWidget: (context, url, error) {
                            return Container(color: Colors.grey.shade900);
                          },
                        ),
                        Container(
                          alignment: Alignment.topCenter,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black54, Colors.transparent]),
                          ),
                        ),
                        // SafeArea(
                        //     child: Container(
                        //         alignment: Alignment.topCenter,
                        //         child: Text(
                        //           "${article?.category}",
                        //           textAlign: TextAlign.center,
                        //           style: const TextStyle(
                        //               fontSize: 24,
                        //               fontWeight: FontWeight.bold),
                        //         ))),
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Wrap(
                            children: [
                              Container(
                                color: Colors.black87,
                                alignment: Alignment.bottomLeft,
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article?.source ?? "",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          "${article?.category}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white54),
                                        ),
                                        //Text("${widget.article?.badges}"),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ExpandableText(
                    article?.title ?? "",
                    expandText: 'show more',
                    collapseText: 'show less',
                    maxLines: 2,
                    linkColor: Colors.blue,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      "images/drumm_logo.png",
                      height: 32,
                      color: Colors.white,
                    )),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  padding: const EdgeInsets.all(1),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    // color: (jamImageCards.isNotEmpty)
                    //     ? COLOR_PRIMARY_DARK
                    //     : Colors.black,
                      color:COLOR_PRIMARY_DARK,
                      border: const Border(
                        top: BorderSide(
                          color: Colors.white24,
                          width: 1.0,
                        ),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (jamImageCards.isNotEmpty)
                      //   Container(
                      //     alignment: Alignment.topCenter,
                      //     child: GridView.custom(
                      //       shrinkWrap: true,
                      //       physics: const NeverScrollableScrollPhysics(),
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 2, vertical: 2),
                      //       gridDelegate: SliverQuiltedGridDelegate(
                      //         crossAxisCount: 3,
                      //         mainAxisSpacing: 3,
                      //         crossAxisSpacing: 3,
                      //         repeatPattern: QuiltedGridRepeatPattern.inverted,
                      //         pattern: [
                      //           const QuiltedGridTile(2, 1),
                      //           const QuiltedGridTile(2, 1),
                      //           const QuiltedGridTile(2, 1),
                      //         ],
                      //       ),
                      //       childrenDelegate: SliverChildBuilderDelegate(
                      //         childCount: jamImageCards.length,
                      //             (context, index) => jamImageCards.elementAt(index),
                      //       ),
                      //     ),
                      //   ),
                      if (jamImageCards.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: GridView.count(
                              childAspectRatio: 1,
                              crossAxisCount: 2,
                              mainAxisSpacing: 3, // Number of columns
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                              crossAxisSpacing: 3,
                              children: jamImageCards),
                        ),
                      if (jamImageCards.isEmpty)
                        Container(
                          height: 200,
                          color: COLOR_PRIMARY_DARK,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text("There are currently no active drumms"),
                          ),
                        ),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 32),
            child: IconLabelButton(label: 'Start a Drumm',
              onPressed: () {
                print('Ask a question');
                Navigator.pop(context);

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: COLOR_PRIMARY_DARK,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(0.0)),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(0.0)),
                        child: CreateJam(
                            title: widget.article?.title,
                            articleId: widget.article?.jamId,
                            imageUrl: widget.article?.imageUrl),
                      ),
                    );
                  },
                );
              },
              imageAsset: 'images/drumm_logo.png',
              height: 40,

            ),

          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<JamImageCard> jamImageCards = [];
  List<Jam> jams = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    article = widget.article;
    getArticles(widget.article?.articleId);
  }

  void getArticles(String? uid) async {
    List<Jam> fetchedJam = await FirebaseDBOperations.getJamsFromArticle(
        uid ?? ""); //getUserBands();
    jams = fetchedJam;

    setState(() {
      jamImageCards = jams.map((_jam) {
        //_jam.imageUrl = null;
        return JamImageCard(_jam,jamCallback: (val){
          Navigator.pop(context);
        },);
      }).toList();
    });
  }

}
