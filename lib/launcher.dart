import 'dart:async';

import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drumm_app/custom/transparent_slider.dart';
import 'package:drumm_app/model/AiVoice.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_onboarding_slider/background_final_button.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:drumm_app/bands_page.dart';
import 'package:drumm_app/custom/ai_summary.dart';
import 'package:drumm_app/custom/create_bottom_sheet.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/explore_page.dart';
import 'package:drumm_app/home_feed.dart';
import 'package:drumm_app/jam_room.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/profile_page.dart';
import 'package:drumm_app/search_page.dart';
import 'package:drumm_app/swipe_page.dart';
import 'package:drumm_app/user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BottomJamWindow.dart';
import 'BottomTabBar.dart';
import 'DiscoverHome.dart';
import 'InterestPage.dart';
import 'TutorialScreen.dart';
import 'UserProfileIcon.dart';
import 'ask_page.dart';
import 'band_details_page.dart';
import 'custom/CustomSwiper.dart';
import 'custom/bottom_sheet.dart';
import 'custom/constants/Constants.dart';
import 'custom/create_jam_bottom_sheet.dart';
import 'custom/helper/circular_reveal_clipper.dart';
import 'custom/helper/image_uploader.dart';
import 'custom/listener/connection_listener.dart';
import 'custom/rounded_button.dart';
import 'jam_room_page.dart';
import 'model/band.dart';
import 'my_home_page.dart';
import 'news_feed.dart';
import 'theme/theme_constants.dart';
import 'theme/theme_manager.dart';

class LauncherPage extends StatefulWidget {
  ThemeManager? themeManager;
  FirebaseAnalytics? analytics;
  FirebaseAnalyticsObserver? observer;
  LauncherPage({
    super.key,
     this.themeManager,
     this.analytics,
     this.observer,
  });

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage>
    with TickerProviderStateMixin {
  GlobalKey<DiscoverHomeState> discoverHomeKey = GlobalKey<DiscoverHomeState>();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();

  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';


  late TabController tabController;
  double iconPadding = 6;
  double textSize = 28;
  double marginHeight = 200;
  late AnimationController _animationController;
  Color disableColor =
      Colors.grey.shade800; //Color(0xff4d4d4d); //Colors.grey.shade800;

  double tabsWidthDivision = 8.5; //Value will be 10 for Wave mode

  bool userConnected = false;

  late Jam currentJam = Jam();
  bool openDrumm = false;
  bool isTutorialDone = true;

  Drummer drummer = Drummer();

  @override
  Widget build(BuildContext context) {
    tabController = TabController(
        length: 3, vsync: this, animationDuration: const Duration(milliseconds: 0));
    FirebaseDBOperations.searchArticles("",0);
    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      body: Stack(
        children: [
          FrostedBottomBar(
            opacity: 1,
            sigmaX: 200,
            sigmaY: 200,
            bottom: 0,
            hideOnScroll: false,
            //currentPage == 0 ? true:false,
            width: MediaQuery.of(context).size.width,
            bottomBarColor: Colors.black, //Color(0xff101010),

            body: (context, controller) => Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 0,
                    ),
                    child: TabBarView(
                      dragStartBehavior: DragStartBehavior.down,
                      physics:
                          const NeverScrollableScrollPhysics(), //const BouncingScrollPhysics(),
                      children: [
                        DiscoverHome(key: discoverHomeKey,),//const NewsFeed(),
                        //ExplorePage(),
                        SwipePage(),
                        BandSearchPage(),
                        //UserProfilePage(),
                        //CustomSwiper(),

                      ],
                      controller: tabController,
                    ),
                  ),
                ),
                const BottomJamWindow(),
                const SizedBox(height: 80), //Wave Mode it was 88
              ],
            ),
            child: BottomTabBar(tabController: tabController, refreshDiscover: () { refreshHomePage(); },),
          ),
          //TutotrialManager(),
        ],
      ),
    );
  }


  void initDeepLinkData() {
    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_string', 'abcd')
      ..addCustomMetadata('custom_number', 12345)
      ..addCustomMetadata('custom_bool', true)
      ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
      ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
    //--optional Custom Metadata
      ..contentSchema = BranchContentSchema.COMMERCE_PRODUCT
      ..price = 50.99
      ..currencyType = BranchCurrencyType.BRL
      ..quantity = 50
      ..sku = 'sku'
      ..productName = 'productName'
      ..productBrand = 'productBrand'
      ..productCategory = BranchProductCategory.ELECTRONICS
      ..productVariant = 'productVariant'
      ..condition = BranchCondition.NEW
      ..rating = 100
      ..ratingAverage = 50
      ..ratingMax = 100
      ..ratingCount = 2
      ..setAddress(
          street: 'street',
          city: 'city',
          region: 'ES',
          country: 'Brazil',
          postalCode: '99999-987')
      ..setLocation(31.4521685, -114.7352207);

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        canonicalUrl: 'https://flutter.dev',
        title: 'Flutter Branch Plugin',
        imageUrl: imageURL,
        contentDescription: 'Flutter Branch Description',
        /*
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
         */
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$android_redirect_timeout', 750)
      ..addControlParam('referring_user_id', 'user_id');

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
    //--optional Event data
      ..transactionID = '12344555'
      ..currency = BranchCurrencyType.BRL
      ..revenue = 1.5
      ..shipping = 10.2
      ..tax = 12.3
      ..coupon = 'test_coupon'
      ..affiliation = 'test_affiliation'
      ..eventDescription = 'Event_description'
      ..searchQuery = 'item 123'
      ..adType = BranchEventAdType.BANNER
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  void listenDynamicLinks() async {
    // streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
    //   print('listenDynamicLinks - DeepLink Data: $data');
    //   controllerData.sink.add((data.toString()));
    //
    //   /*
    //   if (data.containsKey('+is_first_session') &&
    //       data['+is_first_session'] == true) {
    //     // wait 3 seconds to obtain installation data
    //     await Future.delayed(const Duration(seconds: 3));
    //     Map<dynamic, dynamic> params =
    //         await FlutterBranchSdk.getFirstReferringParams();
    //     controllerData.sink.add(params.toString());
    //     return;
    //   }
    //    */
    //
    //   if (data.containsKey('+clicked_branch_link') &&
    //       data['+clicked_branch_link'] == true) {
    //     print(
    //         '------------------------------------Link clicked----------------------------------------------');
    //     print('Custom string: ${data['custom_string']}');
    //     print('Custom number: ${data['custom_number']}');
    //     print('Custom bool: ${data['custom_bool']}');
    //     print('Custom list number: ${data['custom_list_number']}');
    //     print(
    //         '------------------------------------------------------------------------------------------------');
    //   }
    // }, onError: (error) {
    //   print('listSesseion error: ${error.toString()}');
    // });

    FlutterBranchSdk.initSession().listen((data) {

        if(data.containsKey("jam")){
          Jam jam = Jam.fromJsonObject(data['jam']);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.grey.shade900,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(0.0)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom:
                    MediaQuery.of(context).viewInsets.bottom),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(0.0)),
                  child: JamRoomPage(
                    jam: jam,
                    open: openDrumm,
                  ),
                ),
              );
            },
          );
          return;
        }
        else if(data.containsKey('band')){

          Band band = Band.fromJsonObject(data['band']);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BandDetailsPage(
                      band: band,
                    ),
              ));


          return;
        }

        else if (data.containsKey('page') &&
            data['page'] == "profile") {
          // wait 3 seconds to obtain installation data
          tabController.animateTo(4);
          return;
        }

      //print('listenDynamicLinks - DeepLink Data: $data');
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    listenDynamicLinks();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
    ConnectionListener.onConnectionChanged = null;
  }

  void refreshHomePage() {
    print("Trying to call disccoverHomeKey");
    discoverHomeKey.currentState?.getToTop();
  }
}



class TutotrialManager extends StatefulWidget {

  TutotrialManager({ super.key});

  @override
  State<TutotrialManager> createState() => _TutotrialManagerState();
}

class _TutotrialManagerState extends State<TutotrialManager> {
  bool isTutorialDone = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setOnboarded();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (!isTutorialDone)?
        TutorialScreen(finishTutorial: () {
          finishedTutorial();
        },):Container(height: 0,width: 0,),
    );
  }

  void finishedTutorial() async {

    Future.delayed(const Duration(milliseconds: 750),(){
      FirebaseDBOperations.ANIMATION_CONTROLLER.forward();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTutorialDone = true;
    });
    await prefs.setBool('isTutorialDone', true);
  }

  void setOnboarded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkTutorial = await prefs.getBool('isTutorialDone') ?? false;
    setState(() {
      isTutorialDone = checkTutorial;
      if (!isTutorialDone) {
        playWelcomeAudio();
      }
    });
    await prefs.setBool('isOnboarded', false);
    await prefs.setBool('addedOccupation', false);
  }

  void playWelcomeAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    AiVoice aiVoice = await FirebaseDBOperations.getAiVoice("welcome");
    audioPlayer.setUrl(aiVoice.aiVoiceUrl ?? "");
    audioPlayer.play();
  }
}

