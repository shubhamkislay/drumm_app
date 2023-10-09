import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/model/band.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../article_jam_page.dart';
import '../custom/ai_summary.dart';
import '../custom/helper/firebase_db_operations.dart';
import '../custom/helper/remove_duplicate.dart';
import '../custom/instagram_date_time_widget.dart';
import '../custom/rounded_button.dart';
import '../theme/theme_constants.dart';
import 'article.dart';
import 'article_band.dart';

class HomeItem extends StatefulWidget {
  ArticleBand articleBand;
  int index;
  String? bandId;
  bool isContainerVisible = false;
  VoidCallback undo;
  Function(Article) updateList;
  Function(Article) openArticle;
  Future<void> Function() onRefresh;
  HomeItem(
      {Key? key,
        required this.index,
      required this.articleBand,
        required this.onRefresh,
        required this.undo,
      required this.isContainerVisible,
      required this.updateList,
        this.bandId,
      required this.openArticle})
      : super(key: key);

  @override
  State<HomeItem> createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItem> {
  double fontSize = 10;
  Color iconBGColor = Colors.grey.shade900.withOpacity(0.5);//COLOR_PRIMARY_DARK;
  double iconHeight = 64;
  double sizedBoxedHeight = 12;
  double curve = 20;
  Band? band;
  @override
  Widget build(BuildContext context) {
    //setband();
    return ClipRRect(
      borderRadius: BorderRadius.circular(curve),
      child: Container(
        decoration: BoxDecoration(
            color: COLOR_PRIMARY_DARK,//Color(0xff012036FF)
            borderRadius: BorderRadius.circular(curve),
            border: Border.all(color: Colors.grey.shade900, width: 1)),
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(curve),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15), // Shadow color
                              offset: Offset(0, -2), // Shadow offset (horizontal, vertical)
                              blurRadius: 8, // Blur radius
                              spreadRadius: 0, // Spread radius
                            ),
                          ]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(curve-4),
                        child: CachedNetworkImage(
                          imageUrl: widget.articleBand.article?.imageUrl ?? "",
                          filterQuality: FilterQuality.low,
                          placeholder: (context, imageUrl) {
                            String imageUrl = widget.articleBand.article?.imageUrl ??"";
                            return Container(
                              height: 150,
                              width: double.infinity,
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(curve-4),
                              ),
                              child: Image.asset("images/logo_background_white.png",color: Colors.white.withOpacity(0.1),),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              height: 150,
                              width: double.infinity,
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(curve-4),
                              ),
                              child: Image.asset("images/logo_background_white.png",color: Colors.white.withOpacity(0.1),),
                            );
                          },
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Vibrate.feedback(FeedbackType.impact);
                        widget.openArticle(widget.articleBand.article??Article());
                        print("Tapped article");
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                    "${widget.articleBand.article?.source}",
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                                SizedBox(width: 8,),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 2,horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text("${widget.articleBand.article?.category}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: "alata"
                                    ),),
                                ),
                                SizedBox(width: 8,),
                               if(widget.articleBand.band!=null) Container(
                                  padding: EdgeInsets.symmetric(vertical: 2,horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text("${widget.articleBand.band?.name}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: "alata"
                                    ),),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Wrap(
                              children: [
                                Container(
                                  child: AutoSizeText(
                                    RemoveDuplicate.removeTitleSource(
                                        widget.articleBand.article?.title ?? ""),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            InstagramDateTimeWidget(
                                publishedAt:
                                    widget.articleBand.article?.publishedAt.toString() ?? ""),
                            SizedBox(
                              height: 12,
                            ),
                            ExpandableText(
                              (widget.articleBand.article?.description != null)
                                  ? "${widget.articleBand.article?.description}"
                                  : (widget.articleBand.article?.content != null)
                                      ? "${widget.articleBand.article?.content}"
                                      : "",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70
                              ), expandText: 'See more',
                              collapseText: 'Hide',
                              maxLines: 1,
                              linkColor: Colors.white,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Tap to view",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        RoundedButton(
                          padding: 14,
                          height: iconHeight, //iconHeight,
                          color: Colors.white,
                          bgColor: iconBGColor,
                          onPressed: () {
                            AISummary.showBottomSheet(context,
                                widget.articleBand.article ?? Article(), Colors.transparent);
                          },
                          assetPath: 'images/sparkles.png',
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Gen AI\nSummary",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fontSize, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              RoundedButton(
                                padding: 16,
                                height: iconHeight,
                                color: widget.articleBand.article?.liked ?? false
                                    ? Colors.red
                                    : Colors.white,
                                bgColor: iconBGColor,
                                hoverColor: Colors.redAccent,
                                onPressed: () {
                                  setState(() {
                                    if (widget.articleBand.article?.liked ?? false) {
                                      FirebaseDBOperations.removeLike(
                                          widget.articleBand.article?.articleId);
                                      widget.articleBand.article?.liked = false;
                                      int currentLikes = widget.articleBand.article?.likes ?? 1;
                                      currentLikes -= 1;
                                      widget.articleBand.article?.likes = currentLikes;
                                      widget.updateList(widget.articleBand.article??Article());
                                      //  _articlesController.add(articles);
                                    } else {
                                      FirebaseDBOperations.updateLike(
                                          widget.articleBand.article?.articleId);

                                      widget.articleBand.article?.liked = true;
                                      int currentLikes = widget.articleBand.article?.likes ?? 0;
                                      currentLikes += 1;
                                      widget.articleBand.article?.likes = currentLikes;
                                      widget.updateList(widget.articleBand.article??Article());
                                      //_articlesController.add(articles);

                                      Vibrate.feedback(FeedbackType.impact);
                                    }
                                  });
                                },
                                assetPath: widget.articleBand.article?.liked ?? false
                                    ? 'images/liked.png'
                                    : 'images/heart.png',
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                ((widget.articleBand.article?.likes ?? 0) > 0)
                                    ? "${widget.articleBand.article?.likes}"
                                    : "Like",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ],
                          ),
                          // if ((articles!.elementAt(index).likes ?? 0) > 0)
                          Column(
                            children: [
                              RoundedButton(
                                padding: 12,
                                height: 64, //iconHeight,
                                color: Colors.white,
                                bgColor: iconBGColor, //Colors.white24,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.grey.shade900,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(0.0)),
                                    ),
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(0.0)),
                                          child: ArticleJamPage(
                                            article: widget.articleBand.article??Article(),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                assetPath: 'images/drumm_logo.png',
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Drumms",
                                style: TextStyle(fontSize: fontSize,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
                if(widget.index!=0)GestureDetector(
                  onTap: widget.undo,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_ios_new_rounded,size: 24,)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    print("Setting article in view");
    super.initState();

  }

  void setband() async {
   // band = null;
    if(widget.bandId!=null){
      Band fetchedBand = await FirebaseDBOperations.getBand(widget.bandId??"");
      setState(() {
        band = fetchedBand;
        FirebaseDBOperations.articleBand.putIfAbsent(widget.articleBand.article?.articleId??"", () => band?.bandId??"");
      });
    }else{
      List<Band> userBands = await FirebaseDBOperations.getBandByUser();
      for(Band fetchedBand in userBands){
        List bandHooks =fetchedBand.hooks??[];

        if(bandHooks.contains(widget.articleBand.article?.category)){
          print("BandHooks ${bandHooks} for bandName ${fetchedBand.name} and category ${widget.articleBand.article?.category}\n article ${widget.articleBand.article?.title}");
          setState(() {
            band = fetchedBand;
            FirebaseDBOperations.articleBand.putIfAbsent(widget.articleBand.article?.articleId??"", () => band?.bandId??"");
          });
          break;
        }

      }
    }
  }

}
