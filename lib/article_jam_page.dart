import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/custom/create_jam_bottom_sheet.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/icon_button.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/model/jam_image_card.dart';
import 'package:drumm_app/open_article_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';

import 'model/article.dart';

class ArticleJamPage extends StatefulWidget {
  Article? article;
  ArticleJamPage({Key? key, this.article}) : super(key: key);

  @override
  State<ArticleJamPage> createState() => ArticleJamPageState();
}

class ArticleJamPageState extends State<ArticleJamPage> {
  String profileImageUrl = "";
  Article? article = Article();

  double curve = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: COLOR_PRIMARY_DARK, //Colors.black,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                if (article?.category != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OpenArticlePage(
                                    article: article ?? Article(),
                                  )));
                    },
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(curve),
                        color: COLOR_PRIMARY_DARK,
                        border:
                            Border.all(color: Colors.grey.shade900, width: 1),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(curve - 4),
                              child: CachedNetworkImage(
                                height: double.infinity,
                                width: 100,
                                imageUrl: article?.imageUrl ??
                                    "", //widget.article?.imageUrl ?? "",
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                placeholder: (context, url) =>
                                    Container(color: COLOR_PRIMARY_DARK),
                                errorWidget: (context, url, error) {
                                  return Container(color: COLOR_PRIMARY_DARK);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: ExpandableText(
                                article?.title ?? "",
                                expandText: 'show more',
                                collapseText: 'show less',
                                maxLines: 3,
                                linkColor: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  width: 4,
                ),
                if (article?.question != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExpandableText(
                      article?.question ?? "",
                      expandText: 'by Drumm AI',
                      collapseText: 'by Drumm AI',
                      maxLines: 4,
                      style: TextStyle(fontSize: 18),
                      linkColor: Colors.blue,
                    ),
                  ),
                const SizedBox(
                  height: 24,
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
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      // color: (jamImageCards.isNotEmpty)
                      //     ? COLOR_PRIMARY_DARK
                      //     : Colors.black,
                      color: COLOR_PRIMARY_DARK,
                      border: const Border(
                        top: BorderSide(
                          color: Colors.white12,
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
                      if (true)
                        if (jamImageCards.isEmpty)
                          Container(
                            height: 350,
                            color: COLOR_PRIMARY_DARK,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child:
                                  Text("There are currently no active drumms"),
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
            alignment: /*jamImageCards.isNotEmpty ?*/
                Alignment.bottomCenter, //:Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconLabelButton(
                  label: 'Join Open Drumm',
                  onPressed: () {
                    Jam jam = Jam();
                    jam.broadcast = false;
                    jam.title = widget.article?.title;
                    jam.bandId = widget.article?.category;
                    jam.jamId = widget.article?.jamId;
                    jam.articleId = widget.article?.articleId;
                    jam.startedBy = widget.article?.source;
                    jam.imageUrl = widget.article?.imageUrl;
                    if (widget.article?.question != null)
                      jam.question = widget.article?.question;
                    else
                      jam.question = widget.article?.title;
                    jam.count = 1;
                    jam.membersID = [];
                    jam.lastActive = Timestamp.now();

                    //FirebaseDBOperations.createOpenDrumm(jam);
                    FirebaseDBOperations.addMemberToJam(jam.jamId ?? "",
                            FirebaseAuth.instance.currentUser?.uid ?? "", true)
                        .then((value) {
                      print("Added the member ${value}");
                      if (!value) {
                        FirebaseDBOperations.createOpenDrumm(jam);
                        FirebaseDBOperations.sendNotificationToTopic(
                            jam, false, true);
                      }
                    });

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
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                            child: JamRoomPage(
                              jam: jam,
                              open: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  imageAsset: 'images/drumm_logo.png',
                  height: 40,
                ),
                SizedBox(width: 8),
                Text("or"),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
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
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(0.0)),
                            child: CreateJam(
                                jamId: widget.article?.jamId,
                                title: widget.article?.title,
                                articleId: widget.article?.articleId,
                                imageUrl: widget.article?.imageUrl),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    child: Icon(Icons.add),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(COLOR_PRIMARY_VAL)),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [COLOR_PRIMARY_DARK, Colors.transparent]),
            ),
          ),
          Row(
            children: [
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ExpandableText(
                    article?.source ?? "",
                    expandText: 'show more',
                    collapseText: 'show less',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 3,
                    linkColor: Colors.blue,
                  ),
                ),
              ),
            ],
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
    getArticleJams(widget.article?.articleId);
  }

  void getArticleJams(String? uid) async {
    List<Jam> fetchedJam = await FirebaseDBOperations.getJamsFromArticle(
        uid ?? ""); //getUserBands();
    jams = fetchedJam;

    setState(() {
      jamImageCards = jams.map((_jam) {
        //_jam.imageUrl = null;
        return JamImageCard(
          _jam,
          jamCallback: (val) {
            Navigator.pop(context);
          },
        );
      }).toList();
    });
  }
}
