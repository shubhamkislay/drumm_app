import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/model/algolia_article.dart';
import 'package:drumm_app/register_user.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:drumm_app/AppleWatchMenu.dart';
import 'package:drumm_app/InterestPage.dart';
import 'package:drumm_app/ask_page.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/tab_icon.dart';
import 'package:drumm_app/jam_room_page.dart';
import 'package:drumm_app/launcher.dart';
import 'package:drumm_app/login_screen.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/band.dart';
import 'package:drumm_app/model/drumm_card.dart';
import 'package:drumm_app/model/drummer_image_card.dart';
import 'package:drumm_app/model/jam.dart';
import 'package:drumm_app/my_home_page.dart';
import 'package:drumm_app/onboarding.dart';
import 'package:drumm_app/swipe_page.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:drumm_app/theme/theme_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'custom/drumm_app_bar.dart';
import 'package:http/http.dart' as http;

import 'custom/helper/connect_channel.dart';
import 'firebase_options.dart';
import 'model/article.dart';

Future<String> triggerCloudFunction() async {
  final triggerUrl =
      'https://us-central1-drummapp.cloudfunctions.net/getTopHeadlines';

  final response = await http.post(Uri.parse(triggerUrl));

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Error triggering Cloud Function: ${response.statusCode}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ThemeManager themeManager = ThemeManager();

  runApp(MaterialApp(
    home: const MyApp(),
    themeMode: ThemeMode.dark,
    darkTheme: darkTheme,
    debugShowCheckedModeBanner: false,
  ));
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver //with SingleTickerProviderStateMixin
{
  // late int currentPage;
  // late TabController tabController;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  late SharedPreferences prefs;

  @override
  void dispose() {
    //tabController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    _themeManager.removeListener(themeListener);

    super.dispose();
  }

  @override
  void initState() {
    initNotification();
    WidgetsBinding.instance.addObserver(this);
    //FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);


    _themeManager.addListener(themeListener);
    _themeManager.darkTheme(true);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    setupForegroundNotification();

    try {
      FirebaseMessaging.instance.getToken().then((token) {
        print('Device Token FCM: $token');
        if (token != null) {
          if (FirebaseAuth.instance.currentUser != null)
            FirebaseDBOperations.updateDrummerToken(token);
        }
      });
    } catch (e) {}

    super.initState();

    // var metaSdk = FlutterMetaSdk();
    // metaSdk.setAdvertiserTracking(enabled: true);
    // metaSdk.logEvent(name: "App opened");
    final args = <String, dynamic>{
      'fields': "started_event_log",
    };
     var facebookAppEvents = FacebookAppEvents();
     facebookAppEvents.setAdvertiserTracking(enabled: true);
     facebookAppEvents.logEvent(name: "appinitialised",parameters: args);
  }

  void setupForegroundNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false, // Required to display a heads up notification
      badge: false,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("/// // onMessageReceived Foreground // ///:  ${message}");
      try {
        bool broadcast = jsonDecode(message.data["broadcast"]);

        if (broadcast) {
          setupPersonalisedNotification();
          return;
        } else {
          showForegroundNotification(message);
        }
      } catch (e) {
        print("It's not a broadcast message because ${e.toString()}");
        showForegroundNotification(message);
      }
    });
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    try {
      bool broadcast = jsonDecode(message.data["broadcast"]);

      if (broadcast) {
        setupPersonalisedNotification();
        return;
      }
    } catch (e) {
      print("It's not a broadcast message because ${e.toString()}");
    }

    Map<String, dynamic> json = jsonDecode(message.data["jam"]);
    Jam jam = Jam.fromJson(json);
    print("Handling a background message title: ${jam.title}");
    bool ring = jsonDecode(message.data["ring"]);
    String drummerID = message.data["drummerID"].toString();

    if (FirebaseAuth.instance.currentUser?.uid != drummerID)
      addToNotification(message);

    print(
        "Drummer ID: ${drummerID}\nUID: ${FirebaseAuth.instance.currentUser?.uid}");

    //Map userMap = jsonDecode(shared_User.getString('user'));
    //
    //
    //
    // var user = User.fromJson(userMap);

    if (FirebaseAuth.instance.currentUser?.uid != jam.startedBy) if (ring)
      startCallingNotification(message);
  }

  void startCallingNotification(RemoteMessage message) async {
    var uuid = const Uuid();
    Map<String, dynamic> json = jsonDecode(message.data["jam"]);
    Jam jam = Jam.fromJson(json);
    CallKitParams callKitParams = CallKitParams(
      id: uuid.v4(),
      nameCaller: "${jam.title}",
      avatar: jam.imageUrl,
      appName: 'Drumm',
      handle: '${message.notification?.title}',
      type: 0,
      textAccept: 'Join',
      textDecline: 'Ignore',
      duration: 30000,
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      extra: <String, dynamic>{
        'callID': message.data["qid"],
        'query': message.data["question"],
        'remoteId': message.data["rid"],
        'uid': message.data["uid"],
      },
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: '/android/app/src/main/res/raw/drummsound.mp3',
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call"),
      ios: const IOSParams(
        iconName: 'Drumm',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: false,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: '/ios/Runner/drummsound.caf', //'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    callHandle(message);
  }

  void callHandle(RemoteMessage message) {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      switch (event!.event) {
        case Event.actionCallIncoming:
          print("Call ACTION_CALL_INCOMING");
          break;
        case Event.actionCallStart:
          print("Call ACTION_CALL_START");
          break;
        case Event.actionCallAccept:
          print("Call Accepted");
          // NavigatorState? navigatorState =
          //     NavigationsService.navigatorKey.currentState;
          //
          // if (navigatorState != null) {
          //   navigatorState.pushNamed('/callScreen');
          // } else {
          //   debugPrint("Error navigating since navigatorState is null");
          //   //checkAndNavigationCallingPage();
          //   // go to second page using named route
          //   // go to second page using MaterialPageRoute
          //   //OneContext().pushNamed('/callScreen');
          //  // OneContext().push(MaterialPageRoute(builder: (_) => CallingWidget(callID: callID, query: query, remoteUID: remoteId)));
          //   // callID = message.data["qid"];
          //   // query = message.data["question"];
          //   // remoteId = message.data["rid"];
          //   //
          //   // print("CallID: $callID Query: $query RemoteID: $remoteId");
          //   // startCallingNotification(message);
          // }

          // NavigationService.instance.navigationKey.currentState?.pushNamed('/callScreen');
          try {
            Map<String, dynamic> json = jsonDecode(message.data["jam"]);
            bool open = jsonDecode(message.data["open"]);
            Jam jam = Jam.fromJson(json);
            print("/// // onMessageOpenedApp // ///:  ${jam.title}");
            joinRoom(jam, open, true);
          } catch (e) {
            print("NavigationService is null");
          }
          break;
        case Event.actionCallDecline:
          // TODO: declined an incoming call
          FlutterCallkitIncoming.endAllCalls();
          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          ConnectToChannel.leaveChannel();
          FlutterCallkitIncoming.endAllCalls();
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: Handle this case.
          break;
        case Event.actionCallTimeout:
          // TODO: Handle this case.
          break;
        case Event.actionCallCallback:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleHold:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleMute:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleDmtf:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleGroup:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: Handle this case.
          break;
        case Event.actionCallCustom:
          // TODO: Handle this case.
          break;
      }
    });
  }

  void initNotification() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map<String, dynamic> json = jsonDecode(message.data["jam"]);
      Jam jam = Jam.fromJson(json);
      bool open = jsonDecode(message.data["open"]);
      //joinRoom(jam);
      if (jam.jamId != ConnectToChannel.channelID) joinRoom(jam, open, false);
    });

    Future.delayed(const Duration(seconds: 2)).then((value) {
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          Map<String, dynamic> json = jsonDecode(message?.data["jam"]);
          // AnimatedSnackBar.material(
          //     'getInitialMessage: ${json}',
          //     type: AnimatedSnackBarType.success,
          //     mobileSnackBarPosition: MobileSnackBarPosition.top
          // ).show(context);

          Jam jam = Jam.fromJson(json);
          bool open = jsonDecode(message?.data["open"]);
          //joinRoom(jam);
          if (jam.jamId != ConnectToChannel.channelID)
            joinRoom(jam, open, false);
        }
      });
    });
  }

  // void changePage(int newPage) {
  //   setState(() {
  //     currentPage = newPage;
  //   });
  // }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drumm',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      themeMode: _themeManager.themeMode,
      home: SplashScreen(
        observer: observer,
        analytics: analytics,
        themeManager: _themeManager,
      ),
    );
  }

  triggerCloud() async {
    // final headlines = await triggerCloudFunction();
    // print(headlines);
  }

  void joinRoom(Jam jam, bool open, bool ring) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(0.0)),
            child: JamRoomPage(
              jam: jam,
              open: open,
              ring: ring,
            ),
          ),
        );
      },
    );
  }

  void showForegroundNotification(RemoteMessage message) async {
    String drummerID = message.data["drummerID"].toString();
    bool open = jsonDecode(message.data["open"]);
    Map<String, dynamic> json = jsonDecode(message.data["jam"]);
    Jam jam = Jam.fromJson(json);

    print(
        "Drummer ID: ${drummerID}\nUID: ${FirebaseAuth.instance.currentUser?.uid}");

    if (drummerID != FirebaseAuth.instance.currentUser?.uid) {
      bool existNotification = await notificationExists(message);
      Drummer drummer = await FirebaseDBOperations.getDrummer(drummerID);
      String drummerImage = drummer.imageUrl ?? "";

      Vibrate.feedback(FeedbackType.light);
      if (context == null) throw Exception();
      if(!existNotification) {
        if (jam.jamId != ConnectToChannel.channelID) {
          setState(() {
            AnimatedSnackBar(
                builder: ((context) {
                  return Wrap(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.grey.shade900,
                            Colors.grey.shade900
                          ]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: COLOR_PRIMARY_DARK,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: CachedNetworkImage(
                                        imageUrl: drummerImage,
                                        fit: BoxFit.cover,
                                        width: 20,
                                        height: 20,
                                      )),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (jam.jamId !=
                                          ConnectToChannel.channelID) {
                                        joinRoom(jam, open, false);
                                        FirebaseDBOperations
                                            .sendNotificationToTopic(
                                            jam, false, open);
                                      }
                                    },
                                    child: Text(
                                      "${drummer.username} joined the drumm",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: jam.imageUrl ?? "",
                                                fit: BoxFit.cover,
                                                width: 72,
                                                height: 72,
                                              )),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (jam.jamId !=
                                                      ConnectToChannel
                                                          .channelID) {
                                                    joinRoom(jam, open, false);
                                                    FirebaseDBOperations
                                                        .sendNotificationToTopic(
                                                        jam, false, open);
                                                  }
                                                },
                                                child: Text(
                                                  "${jam.title}",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  softWrap: true,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (jam.jamId !=
                                        ConnectToChannel.channelID) {
                                      joinRoom(jam, open, false);
                                      FirebaseDBOperations
                                          .sendNotificationToTopic(
                                          jam, false, open);
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Drop in",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                duration: const Duration(seconds: 8),
                mobileSnackBarPosition: MobileSnackBarPosition.bottom)
                .show(context);
          });
        }
        else {
          AnimatedSnackBar(
              builder: ((context) {
                return Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.grey.shade900,
                          Colors.grey.shade900
                        ]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: COLOR_PRIMARY_DARK,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      imageUrl: drummerImage,
                                      fit: BoxFit.cover,
                                      width: 20,
                                      height: 20,
                                    )),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "${drummer.username} joined the drumm",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              duration: const Duration(seconds: 8),
              mobileSnackBarPosition: MobileSnackBarPosition.bottom)
              .show(context);
        }
      }
    }
  }

  void addToNotification(RemoteMessage message) async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    List<String>? notifications = notiPref.getStringList("notifications");
    notifications ??= [];
    notifications.add(remoteMessageToJson(message));
    notiPref.setStringList("notifications", notifications);
  }

  Future<bool> notificationExists(RemoteMessage message) async {
    SharedPreferences notiPref = await SharedPreferences.getInstance();
    List<String>? notifications = notiPref.getStringList("notifications");
    notifications ??= [];
    if(!notifications.contains(remoteMessageToJson(message))) {
      notifications.add(remoteMessageToJson(message));
      notiPref.setStringList("notifications", notifications);
      return false;
    }else{
      return true;
    }
  }

  String remoteMessageToJson(RemoteMessage remoteMessage) {
    final Map<String, dynamic> data = remoteMessage.data;
    final Map<String, dynamic> jsonMessage = {
      'data': data,
    };
    return jsonEncode(jsonMessage);
  }
}

void setupPersonalisedNotification() async {
  print("///Calling algolia personalised");
  AlgoliaArticles algoliaArticles = await FirebaseDBOperations
      .getArticleFromAlgoliaForPersonalisedNotificaiton();
  Article? personalisedArticle = algoliaArticles.articles?.elementAt(0);
  if (personalisedArticle != null) {
    Jam jam = Jam();
    jam.startedBy = "Drumm";
    jam.bandId = "dCMkdrzofMhepCfXk9bM";
    jam.count = 0;
    jam.jamId = personalisedArticle.jamId;
    jam.articleId = personalisedArticle.articleId;
    jam.title = personalisedArticle.title;
    jam.question = personalisedArticle.question;
    jam.membersID = [];
    jam.broadcast = false;
    jam.imageUrl = personalisedArticle.imageUrl;

    FirebaseDBOperations.sendNotificationToDeviceToken(jam);
  }
}

class SplashScreen extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  final ThemeManager themeManager;

  const SplashScreen({
    required this.observer,
    required this.analytics,
    required this.themeManager,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOnboarded = false;
  bool toggleLogo = false;

  @override
  void initState() {
    _checkOnboardingStatus();
    super.initState();
  }

  void _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('isOnboarded') ?? false;
    //prefs.remove('isOnboarded');
    if (_isOnboarded) {
      // Future.delayed(const Duration(seconds: 1),(){
      //
      //   setState(() {
      //     toggleLogo = true;
      //   });

      // Future.delayed(const Duration(milliseconds: 1000),(){
      //   Navigator.of(context).push(PageRouteBuilder(
      //       opaque: false,
      //       pageBuilder: (context, animation, _) {
      //         return LauncherPage(themeManager: widget.themeManager,
      //           analytics: widget.analytics,
      //           observer: widget.observer,);
      //       }));
      // });


      Future.delayed(Duration(milliseconds: 500),(){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => LauncherPage(
              themeManager: widget.themeManager,
              analytics: widget.analytics,
              observer: widget.observer,
            ),
            transitionDuration: Duration(seconds: 0),
            reverseTransitionDuration: Duration(seconds: 0),
          ),
        );
      });


      // });
    } else {
      if ((FirebaseAuth.instance.currentUser != null)) {
        bool notify = prefs.getBool("notify") ?? true;
        if (notify) FirebaseDBOperations.subscribeToUserBands();
        Drummer drummer = await FirebaseDBOperations.getDrummer(
            FirebaseAuth.instance.currentUser?.uid ?? "");
        if (drummer != null) {
          int userLen = drummer.username?.length ?? 0;
          if (userLen > 0) {
            await prefs.setBool("isOnboarded", true);
            await prefs.setString('uid', drummer.uid ?? "");
            await prefs.setInt('rid', drummer.rid ?? 0);

            print("This part is being called");

            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, animation, _) {
                  return LauncherPage(
                    themeManager: widget.themeManager,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  );
                }));
          } else {
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, animation, _) {
                  return RegisterUser(
                      themeManager: widget.themeManager,
                      analytics: widget.analytics,
                      observer: widget.observer,
                      name: "",
                      email: "");
                }));
          }
        } else {
          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, _) {
                return RegisterUser(
                    themeManager: widget.themeManager,
                    analytics: widget.analytics,
                    observer: widget.observer,
                    name: "",
                    email: "");
              }));
        }
      } else {
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, _) {
              return OnBoarding(
                themeManager: widget.themeManager,
                analytics: widget.analytics,
                observer: widget.observer,
              );
            }));
      }
    }

    setState(() {
      _isOnboarded = prefs.getBool('isOnboarded') ?? false;
    });
    String userID = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userID.length > 0) {
      Drummer drummer = await FirebaseDBOperations.getDrummer(userID);
      if (userID.length > 1) {
        await prefs.setString('uid', userID);
        await prefs.setInt('rid', drummer.rid ?? 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if ((FirebaseAuth.instance.currentUser != null))
    //   FirebaseDBOperations.subscribeToUserBands();

    return Scaffold(
      body: Container(
        color: Colors.black, //Color(0xff202020),
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              child: Container(
                alignment: Alignment.center,
                //child: Lottie.asset('images/breaking_news.json',height: MediaQuery.of(context).size.height,fit:BoxFit.cover),
              ),
            ),
            //if(!toggleLogo)
            Image.asset(
              "images/logo_dark.png",
              fit: BoxFit.fitWidth,
            ),
            // if(toggleLogo)const Text(
            //   "Drumm",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 54,
            //     fontWeight: FontWeight.bold,
            //     fontFamily: APP_FONT_BOLD,
            //   ),
            // ),
          ],
        ),
      ),
    );

    return (FirebaseAuth.instance.currentUser != null)
        ? _isOnboarded
            ? LauncherPage(
                themeManager: widget.themeManager,
                analytics: widget.analytics,
                observer: widget.observer,
              )
            : InterestsPage(
                themeManager: widget.themeManager,
                analytics: widget.analytics,
                observer: widget.observer,
              )
        : OnBoarding(
            themeManager: widget.themeManager,
            analytics: widget.analytics,
            observer: widget.observer,
          );
    /*LoginScreen(
            themeManager: widget.themeManager,
            observer: widget.observer,
            analytics: widget.analytics,
          );*/
  }
}
