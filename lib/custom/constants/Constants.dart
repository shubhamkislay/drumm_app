import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drumm_app/model/Drummer.dart';
import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
const TUTORIAL_MESSAGE_BANDS = "A band is a community of drummers with similar interests. Here, you can check out the drumms that are currently active for the band. You can also join open drumm to connect with your band members without drumming a particular article";

const TOP_VIBE_DESCRIPTION = "Top Vibe is the category of the news articles that the user mostly vibes with.";

const DRUMM_LEVEL_DESCRIPTION = "Current level of the drummer. It increases with the drumm score.";

const DRUMM_SCORE_DESCRIPTION = "Total score earned by the drummer. The drumm score increases when the drummer opens an article, starts a drumm, or joins an existing drumm.";

const String STATE_TYPE_MILD = "MILD";
const String STATE_TYPE_MODERATE = "MODERATE";
const String STATE_TYPE_INTENSE = "INTENSE";

const int STATE_TYPE_MILD_SCORE = 1;
const int STATE_TYPE_MODERATE_SCORE = 7;
const int STATE_TYPE_INTENSE_SCORE = 15;

const double WEIGHT_BOOSTED = 1.0;
const double WEIGHT_JOINED = 0.9;
const double WEIGHT_SHARED = 0.8;
const double WEIGHT_LISTENED = 0.7;
const double WEIGHT_READ = 0.6;
const double WEIGHT_OPENED = 0.4;
const double WEIGHT_STARTED = 1.0;

const String INTERACTION_OPENED = "opened";
const String INTERACTION_READ = "read";
const String INTERACTION_JOINED = "joined";
const String INTERACTION_SHARED = "shared";
const String INTERACTION_STARTED = "started";

const String DEFAULT_IMAGE_URL = "https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Flogo_dark_300x300.png?alt=media&token=a2e1bc5c-a34c-4def-b86b-5a806443c921";


const double CURVE=12;
const COLOR_BACKGROUND = COLOR_PRIMARY_DARK;
var COLOR_BOOST = Colors.indigo;

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

Drummer CURRENT_DRUMMER = Drummer();

List<Color> EXPLORE_COLOR =  [

Colors.red,
Colors.pinkAccent,
];
/// Cosine similarity calculation
double cosineSimilarity(VectorValue vector1, VectorValue vector2) {
  List<double> a = vector1.toArray();
  List<double> b = vector2.toArray();

  double dotProduct = 0.0;
  double magnitudeA = 0.0;
  double magnitudeB = 0.0;

  for (int i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    magnitudeA += a[i] * a[i];
    magnitudeB += b[i] * b[i];
  }

  magnitudeA = sqrt(magnitudeA);
  magnitudeB = sqrt(magnitudeB);

  if (magnitudeA == 0 || magnitudeB == 0) {
    return 0.0; // Avoid division by zero
  }

  return dotProduct / (magnitudeA * magnitudeB);
}
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


