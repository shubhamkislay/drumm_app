import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lottie/lottie.dart';

import 'model/article.dart';
import 'model/home_item.dart';
import 'model/home_item_default.dart';
import 'open_article_page.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({Key? key}) : super(key: key);

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List<Article> articles = [];
  final CardSwiperController controller = CardSwiperController();

  bool loadAnimation =false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Drumm",
              textAlign: TextAlign.center,
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),),
            SizedBox(
              height: 16,
            ),
            if (articles.length<1 || loadAnimation)
              Expanded(child: Lottie.asset('images/animation_loading.json',fit:BoxFit.contain ,width: double.maxFinite)),
            if(articles.length>0) Expanded(
               child: CardSwiper(
                 controller: controller,
                 cardsCount: articles.length,
                 numberOfCardsDisplayed: 1,//(articles.length>1)?2:1,
                 isVerticalSwipingEnabled: false,
                 onEnd: (){
                   print("Ended swipes");
                   setState(() {
                     //loadAnimation = true;
                     articles.clear();
                   });
                 },
                 threshold: 50,
                 onSwipe: _onSwipe,
                 isLoop: false,
                 onUndo: _onUndo,
                 padding:
                 const EdgeInsets.symmetric(horizontal: 24),
                 cardBuilder: (context, index){
                   print("Index of element $index");
                   if(index>=0)
                   return HomeItem(article: articles.elementAt(index),
                     isContainerVisible: false,
                     openArticle: (article){openArticlePage(article,index);},
                     updateList: (article){},
                   );
                 },
               ),
             ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getArticles();

  }

  void openArticlePage(Article? article, int index) async {
    var returnData = await Navigator.push<Article?>(
      context,
      MaterialPageRoute(
        builder: (context) => OpenArticlePage(
          article: article ?? Article(),
        ),
      ),
    );
    setState(() {
      articles[index] = returnData!;
    });
    // print("Return Data ${returnData?.liked}");
  }

  void getArticles() async {
    List<Article> articleFetched = await FirebaseDBOperations.getArticlesByBands();
    setState(() {
      articles = articleFetched;
      print("Article length ${articles.length}");
    });
  }

  bool _onSwipe(
      int previousIndex,
      int? currentIndex,
      CardSwiperDirection direction,
      ) {
    if(direction == CardSwiperDirection.left)
      {
        return true;
      }

    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  bool _onUndo(
      int? previousIndex,
      int currentIndex,
      CardSwiperDirection direction,
      ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }
}
