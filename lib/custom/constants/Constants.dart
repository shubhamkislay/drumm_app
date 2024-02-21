import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';

const TUTORIAL_MESSAGE_JOIN_TITLE = "You're about to start your first drumm!";
const TUTORIAL_MESSAGE_JOIN = "A notification will be sent to all the band members to join the drumm and discuss the article. You can start or join a drumm either by swiping right on the article or pressing the blue button. Happy drumming!";
const CONFIRM_JOIN_SHARED_PREF = "drummjoin";
const JOIN_CONFIRMATION = "Start a drumm";
const LEAVE_DRUMM_CONFIRMATION = "Are you sure you want to leave the drumm?";
const LEAVE_DRUMM_TITLE = "Leave Drumm";


const BOX_TYPE_CONFIRM = "confirm";
const BOX_TYPE_ALERT = "alert";


const ALERT_EXPLORE_ARTICLES_SHARED_PREF = "explorearticles";
const TUTORIAL_MESSAGE_EXPLORE_TITLE = "Explore News articles and updates!";
const TUTORIAL_MESSAGE_EXPLORE = "Swipe left to explore news articles and choose what you want to drumm about with your band members";


const ALERT_EXPLORE_LIVE_SHARED_PREF = "explorelive";
const TUTORIAL_MESSAGE_LIVE_TITLE = "Explore live drumms!";
const TUTORIAL_MESSAGE_LIVE = "Check out the drumms that are live and tap to join the conversation.";


const ALERT_EXPLORE_BANDS_SHARED_PREF = "explorebands";
const TUTORIAL_MESSAGE_BANDS_TITLE = "Welcome to Bands!";
const TUTORIAL_MESSAGE_BANDS = "A band is a community with similar interests. Here, you can check out the drumms that are currently active for the band. You can also join open drumm to connect with your band members without drumming a particular article";



const double CURVE=12;
const COLOR_BACKGROUND = COLOR_PRIMARY_DARK;

List<Color> JOIN_COLOR = [
  Colors.indigo.shade700.withOpacity(0.85),
  Colors.blue.shade800.withOpacity(0.75),
  Colors.blue.shade600,
];
//List<Color> EXPLORE_COLOR = [Colors.orange.shade800,Colors.red.shade800];
// List<Color> JOIN_COLOR =[
// Colors.indigo,
// Colors.blue.shade700,
// Colors.lightBlue,
// ];

List<Color> EXPLORE_COLOR =  [

Colors.red,
Colors.pinkAccent,
];

Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'business':
      return Colors.deepOrangeAccent;
    case 'sports':
      return Colors.indigoAccent;
    case 'technology':
      return Colors.tealAccent;
    case 'health':
      return Colors.amberAccent;
    case 'science':
      return Colors.deepPurpleAccent;
    case 'politics':
      return Colors.pinkAccent;
    case 'entertainment':
      return Colors.limeAccent;
    default:
      return Colors.grey; // default color for unknown category
  }
}


