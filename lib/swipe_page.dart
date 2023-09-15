import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/model/duel_card.dart';
import 'package:drumm_app/model/example_candidate.dart';
import 'package:drumm_app/model/example_card.dart';

import 'custom/helper/circular_reveal_clipper.dart';
import 'model/question.dart';

class SwipePage extends StatefulWidget {
  SwipePage({Key? key}) : super(key: key);

  @override
  State<SwipePage> createState() => SwipePageState();
}

class SwipePageState extends State<SwipePage>
    with SingleTickerProviderStateMixin {
  final CardSwiperController controller = CardSwiperController();
  late AnimationController _animationController;
  List<Question> communityQuestions = [];
  //final cards = candidates.map((candidate) => ExampleCard(candidate)).toList();
  var cards = [];

  bool loadCards = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      upperBound: 1.0,
    );
    _animationController.forward();

    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        setState(() {
          loadCards = true;
          getUserQuestions();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (BuildContext context, Widget? child) {
        return ClipPath(
          clipper: CircleRevealClipper(fraction: _animationController.value),
          child: child,
        );
      },
      animation: _animationController,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade700,
                  Colors.blue.shade900
                ]),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 16, top: 4),
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            loadCards = false;
                          });
                          Vibrate.feedback(FeedbackType.selection);
                          _animationController
                              .reverse()
                              .then((value) => Navigator.pop(context));
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 42,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(right: 0, top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Wave",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32),
                          ),
                          Text(
                            " Mode",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (loadCards && cards.length > 0)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 24),
                          SizedBox(
                            height: 550,
                            child: CardSwiper(
                              controller: controller,
                              cardsCount: cards.length,
                              numberOfCardsDisplayed: (cards.length > 1)?(cards.length > 2)?3:2:1,
                              isVerticalSwipingEnabled: false,
                              threshold: 5,
                              onSwipe: _onSwipe,
                              onUndo: _onUndo,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              cardBuilder: (context, index) => cards[index],
                            ),
                          ),
                          SizedBox(height: 64),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 48.0),
                            child: FloatingActionButton.extended(
                              backgroundColor: Colors.white,
                              onPressed: () {
                                // Add your logic here
                                print('Ask a question');
                              },
                              label: Text(
                                'Ask a question',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "San Francisco",
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getUserQuestions() async {
    List<Question> fetchedQuestions =
        await FirebaseDBOperations.getQuestionsAsked();
    communityQuestions = fetchedQuestions;
    setState(() {
      cards = communityQuestions.map((question) => DuelCard(question)).toList();
    });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      cards.removeAt(previousIndex);
    });

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
