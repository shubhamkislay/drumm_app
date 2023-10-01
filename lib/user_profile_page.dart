import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

import 'custom/helper/image_uploader.dart';

class UserProfilePage extends StatefulWidget {
  Drummer? drummer;
  bool? fromSearch;
  UserProfilePage({Key? key, this.drummer, this.fromSearch}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin<UserProfilePage>{
  String profileImageUrl = "";
  Drummer? drummer = Drummer();

  String? currentID = "";

  bool followed = false;
  bool fromSearch=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (drummer?.username != null)
                    Container(
                      height: 500,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            height: double.maxFinite,
                            width: double.maxFinite,
                            alignment: Alignment.center,
                            imageUrl: modifyImageUrl(drummer?.imageUrl ??"","100x100"), //widget.drummer?.imageUrl ?? "",
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: COLOR_PRIMARY_DARK),
                            errorWidget: (context, url, error) =>
                                Container(color: COLOR_PRIMARY_DARK),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent,Colors.transparent,Colors.black87,Colors.black]),
                            ),
                          ).frosted(blur: 6,frostColor: Colors.black),
                          Center(
                            child: SizedBox(
                              width: 175,
                              height: 175,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: modifyImageUrl(drummer?.imageUrl ??"","300x300"),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(),
                               if(false) SafeArea(
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          "@${drummer?.username}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ))),
                                if (drummer?.uid == currentID)
                                  SafeArea(
                                      child: GestureDetector(
                                    onTap: () {
                                      if(ConnectToChannel.engineInitialized)
                                        ConnectToChannel.disposeEngine();
                                      removedPreferences();
                                      FirebaseAuth.instance.signOut().then(
                                          (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()), (_) => false));
                                    },
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          "Logout",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        )),
                                  )),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Wrap(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent,Colors.black87,Colors.black]),
                                  ),
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 8),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              alignment: Alignment.topCenter,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Text(
                                                "@${drummer?.username}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 16,),
                                              )),
                                          Text(
                                            drummer?.name ?? "",
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "${drummer?.jobTitle} at ${drummer?.organisation}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white54),
                                          ),
                                          //Text("${widget.drummer?.badges}"),
                                        ],
                                      ),
                                     if(false) Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 8),
                                        child: Column(
                                          children: [
                                            Text(
                                              "${drummer?.badges}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            const Text(
                                              "dB",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ExpandableText(
                      drummer?.bio ?? "",
                      expandText: 'show more',
                      collapseText: 'show less',
                      maxLines: 2,
                      linkColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8,horizontal: 4),
                    color: COLOR_PRIMARY_DARK,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("${drummer?.followerCount??0}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                            Text("Followers",style: TextStyle(color: Colors.white60),),
                          ],
                        ),
                        Column(
                          children: [
                            Text("${drummer?.followingCount??0}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                            Text("Following",style: TextStyle(color: Colors.white60),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 32,
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
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (drummer?.uid != currentID)
                    if (!followed)
                      GestureDetector(
                        onTap: () {
                          followUser();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            "Follow",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  if (followed)
                    GestureDetector(
                      onTap: () {
                        unfollow();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          "Following",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 16,
                  ),
                  if(false)Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        "images/feed.png",
                        height: 32,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    height: 12,
                  ),
                 if(false) Container(
                    padding: const EdgeInsets.all(1),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: (articleCards.isNotEmpty)
                            ? COLOR_PRIMARY_DARK
                            : Colors.black,
                        border: const Border(
                          top: BorderSide(
                            color: Colors.white24,
                            width: 1.0,
                          ),
                        )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (articleCards.isNotEmpty)
                          Container(
                            alignment: Alignment.topCenter,
                            child: GridView.custom(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 2),
                              gridDelegate: SliverQuiltedGridDelegate(
                                crossAxisCount: 3,
                                mainAxisSpacing: 3,
                                crossAxisSpacing: 3,
                                repeatPattern: QuiltedGridRepeatPattern.inverted,
                                pattern: [
                                  const QuiltedGridTile(2, 1),
                                  const QuiltedGridTile(2, 1),
                                  const QuiltedGridTile(2, 1),
                                ],
                              ),
                              childrenDelegate: SliverChildBuilderDelegate(
                                childCount: articleCards.length,
                                (context, index) => articleCards.elementAt(index),
                              ),
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
          ),
          if(fromSearch)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
    if(widget.fromSearch!=null){
      setState(() {
        fromSearch = widget.fromSearch!;
      });
    }

  }

  void initialise(){
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
  }

  Future<void> _refreshData() async {
    // Simulate a delay
    // await Future.delayed(Duration(seconds: 2));
    initialise();

    // Refresh your data
    //getNews();
  }

  void getArticles(String? uid) async {
    List<Article> fetchedArticles =
        await FirebaseDBOperations.getArticlesByUser(
            uid ?? ""); //getUserBands();
    articles = fetchedArticles;

    setState(() {
      articleCards =
          articles.map((article) => ArticleImageCard(article)).toList();
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void removedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void followUser() async{
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
}
