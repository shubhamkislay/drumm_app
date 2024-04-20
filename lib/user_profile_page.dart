import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/SettingsPage.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/edit_profile.dart';
import 'package:drumm_app/main.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'custom/constants/Constants.dart';
import 'custom/helper/image_uploader.dart';
import 'model/QuestionCard.dart';
import 'model/question.dart';

class UserProfilePage extends StatefulWidget {
  Drummer? drummer;
  bool? fromSearch;
  UserProfilePage({Key? key, this.drummer, this.fromSearch}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin<UserProfilePage> {
  String profileImageUrl = "";
  Drummer? drummer = Drummer();

  String? currentID = "";

  bool followed = false;
  bool fromSearch = false;
  List<Question> questions = [];
  List<QuestionCard> questionCards = [];

  @override
  Widget build(BuildContext context) {
    print(
        "User background image ${modifyImageUrl(drummer?.imageUrl ?? "", "100x100")}");
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: true,
      disabled: false,
      minRadius: 10,
      maxRadius: 10,
      dragSensitivity: 1.0,
      child: Scaffold(
        backgroundColor: COLOR_BACKGROUND,
        body: Stack(
          children: [
            Hero(
              tag: drummer?.imageUrl ?? "",
              child: CachedNetworkImage(
                height: double.maxFinite,
                width: double.maxFinite,
                alignment: Alignment.center,
                imageUrl: modifyImageUrl(drummer?.imageUrl ?? "",
                    "100x100"), //widget.drummer?.imageUrl ?? "",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: COLOR_PRIMARY_DARK),
                errorWidget: (context, url, error) =>
                    Container(color: COLOR_PRIMARY_DARK),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      COLOR_BACKGROUND,
                      COLOR_BACKGROUND
                    ]),
              ),
            ).frosted(blur: 24, frostColor: COLOR_BACKGROUND),
           if(false) IgnorePointer(
              child: Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 100,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                            ])),
                  ),
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                //physics: AlwaysScrollableScrollPhysics(),

                child: Column(
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    if (drummer?.imageUrl != null)
                      Center(
                        child: SizedBox(
                          width: 175,
                          height: 175,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: modifyImageUrl(
                                  drummer?.imageUrl ?? "", "300x300"),
                              placeholder: (context, url) {
                                return Container();
                              },
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      drummer?.name ?? "",
                      style: const TextStyle(
                          fontSize: 24,
                          fontFamily: APP_FONT_BOLD,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${drummer?.jobTitle ?? ""}\n${drummer?.occupation ?? ""}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: APP_FONT_MEDIUM, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ExpandableText(
                        drummer?.bio ?? "",
                        expandText: 'show more',
                        collapseText: 'show less',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: APP_FONT_MEDIUM, color: Colors.white54),
                        linkColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (drummer?.uid == currentID)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile(
                                        drummer: drummer,
                                      )));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                                fontFamily: APP_FONT_BOLD,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 24,
                    ),
                    if (questionCards.isNotEmpty)
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        width: double.maxFinite,
                        child: Text(
                          "Questions",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: APP_FONT_BOLD),
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    if (questionCards.isNotEmpty)
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        //height: double.maxFinite,//MediaQuery.of(context).size.height,
                        child: ListView(
                          padding: EdgeInsets.all(0),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: questionCards,
                        ),
                      ),
                    if (questionCards.isEmpty&&false)
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: 100,
                        width: double.maxFinite,
                        child: Text(
                          "There's nothing here",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (fromSearch)
                    SafeArea(
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  if (drummer?.username != null)
                    SafeArea(
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "@${drummer?.username}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: APP_FONT_MEDIUM,
                              fontSize: 20,
                            ),
                          )),
                    ),
                  if (drummer?.uid == currentID)
                    SafeArea(
                        child: GestureDetector(
                      onTap: () {
                        openSettingsPage();
                      },
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 32,
                          )),
                    )),
                ],
              ),
            ),

            ///The below logic will be enable when the feature, ask this person is implement
            if (false)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        alignment: Alignment.center,
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Image.asset(
                          "images/audio-waves.png",
                          color: Colors.white,
                          height: 32,
                          width: 32,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<ArticleImageCard> articleCards = [];
  List<Article> articles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
    if (widget.fromSearch != null) {
      setState(() {
        fromSearch = widget.fromSearch!;
      });
    }
  }

  Future<bool> getDrummerQuestion(String uid) async {
    questionCards.clear();
    //getUserBands();
    questions = await FirebaseDBOperations.getQuestionsAskedByUserId(uid);
    List<QuestionCard> fetchedQuestionCards = questions.map((question) {
      return QuestionCard(
        question: question,
        deleteItem: true,
        deleteCallback: (question) {
          updateList(question);
        },
        cardWidth: double.maxFinite,
      );
    }).toList();

    print("Questions list ${fetchedQuestionCards.length}");

    setState(() {
      questionCards = fetchedQuestionCards;
    });
    return true;
  }

  void initialise() {
    String? uid = "";
    if (widget.drummer == null) {
      uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      FirebaseDBOperations.getDrummer(uid).then((value) {
        setState(() {
          currentID = uid;
          drummer = value;
        });
      });
    } else {
      setState(() {
        currentID = FirebaseAuth.instance.currentUser?.uid ?? "";
        drummer = widget.drummer;
      });

      uid = widget.drummer?.uid;
    }
    //getArticles(uid);
    checkIfUserisFollowing();
    getDrummerQuestion(uid ?? "");
  }

  Future<void> _refreshData() async {
    initialise();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void removedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void followUser() async {
    bool status = await FirebaseDBOperations.followUser(widget.drummer?.uid);
    setState(() {
      if (status) followed = true;
    });
  }

  void unfollow() async {
    bool status = await FirebaseDBOperations.unfollowUser(widget.drummer?.uid);
    setState(() {
      if (status) followed = false;
    });
  }

  void checkIfUserisFollowing() async {
    bool status = await FirebaseDBOperations.isFollowing(widget.drummer?.uid);
    setState(() {
      followed = status;
    });
  }

  void openSettingsPage() {
    Navigator.push(
        context, SwipeablePageRoute(builder: (context) => SettingsPage()));
  }

  void updateList(Question? question) {
    getDrummerQuestion(FirebaseAuth.instance.currentUser!.uid ?? "");
  }
}
