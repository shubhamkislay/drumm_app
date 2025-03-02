import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:drumm_app/StatsDescriptionBox.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20drummer/domain/entities/drummer.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/custom/helper/image_uploader.dart';
import 'package:drumm_app/features/user%20page/presentation/pages/edit_profile.dart';
import 'package:drumm_app/model/StateItem.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:drumm_app/custom/helper/connect_channel.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/main.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/model/article_image_card.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../../../settings/presentation/pages/settings_page.dart';


class UserProfilePage extends StatefulWidget {
  final DrummerEntity? drummer;
  final bool currentUser;
  UserProfilePage({Key? key, required this.drummer, required this.currentUser}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin<UserProfilePage> {
  String profileImageUrl = "";

  String? currentID = "";
  int touchedIndex = -1;

  bool followed = false;
  bool fromSearch = false;
  List<PieChartSectionData> pieChartList = [];

  int totalState = 0;
  int magnitude = 0;
  int drummScore = 0;
  int level = 1;
  int mod = 0;
  String topVibe = "";

  double badgeOffset = 2;

  ValueNotifier<double> _valueNotifier = ValueNotifier(1);
  List<ChartLayer> chartLayer = [];
  List<ChartLayer> largeChartLayer = [];

  List<StatsItem> stateList = [];

  SvgPicture? svgRoot;
  String svgCode = multiavatar('pic',);

  @override
  Widget build(BuildContext context) {
    print(
        "User background image ${modifyImageUrl(widget.drummer?.imageUrl ?? "", "100x100")}");
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: true,
      disabled: false,
      minRadius: 10,
      maxRadius: 10,
      dragSensitivity: 1.0,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: DrummTheme.primaryItemColor(context),
                      borderRadius: BorderRadius.circular(CURVE),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 150,
                        ),
                        if (widget.drummer?.imageUrl != null)
                          Center(
                            child: SizedBox(
                              width: 175,
                              height: 175,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: modifyImageUrl(
                                      widget.drummer?.imageUrl ?? "", "300x300"),
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
                          "@${widget.drummer?.username}",
                          style: TextStyle(
                              fontSize: 12,
                              color: DrummTheme.primaryTextColor(context).withAlpha(100),
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.drummer?.name ?? "",
                          style: TextStyle(
                              fontSize: 24,
                              color: DrummTheme.primaryTextColor(context),
                              fontFamily: APP_FONT_BOLD,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        Text(
                          "${widget.drummer?.jobTitle ?? ""}\n${widget.drummer?.occupation ?? ""}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: APP_FONT_MEDIUM,
                            color: DrummTheme.primaryTextColor(context),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ExpandableText(
                            widget.drummer?.bio ?? "",
                            expandText: 'show more',
                            collapseText: 'show less',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: APP_FONT_MEDIUM,
                              color: DrummTheme.primaryTextColor(context),
                            ),
                            linkColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (widget.currentUser)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile(
                                            drummer: widget.drummer,
                                          )));
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                color: DrummTheme.primaryTextColor(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                    fontFamily: APP_FONT_BOLD,
                                    color: DrummTheme.primarySelectedTextColor(context),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 12,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    SafeArea(
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 28,
                            color: DrummTheme.primaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                  if (widget.currentUser)
                    SafeArea(
                        child: GestureDetector(
                      onTap: () {
                        openSettingsPage();
                      },
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 32,
                            color:DrummTheme.primaryTextColor(context),
                          )),
                    )),
                ],
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void removedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void openSettingsPage() {
    Navigator.push(
        context, SwipeablePageRoute(builder: (context) => SettingsPage()));
  }
}


