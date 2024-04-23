import 'package:drumm_app/model/jam.dart';

class ConnectionListener {
  static Function(bool,Jam,bool,bool)? onConnectionChanged;
  static Function(bool,Jam,bool)? onConnectionChangedinRoom;
  static Function(bool,Jam,bool)? onConnectionChangedinCard;
  static Function(bool,Jam,bool)? onConnectionChangedinVerticalHomeFeed;
  static Function(bool,int)? onJoinCallback;
  static Function(int)? onRemoteUserJoinedCallback;
  static Function(int)? onUserLeftCallback;
  static Function(int,bool)? onUserTalkingCallback;
  static Function(int,bool)? onUserMutedCallback;
  static Function()? onConnectionInterruptedCallback;
  static Function()? onRejoinSuccessCallback;

  static void updateConnectionDetails(bool connected, Jam? jam,bool open, bool micMute) {

    if (onConnectionChanged != null) {
      onConnectionChanged!(connected,jam!,open,micMute);
     // print("onConnectionChanged is cccalled!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    if (onConnectionChangedinRoom != null) {
      onConnectionChangedinRoom!(connected,jam!,open);
     // print("onConnectionChanged is cccalled!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    if (onConnectionChangedinCard != null) {
      onConnectionChangedinCard!(connected,jam!,open);
      // print("onConnectionChanged is cccalled!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    if (onConnectionChangedinVerticalHomeFeed != null) {
      onConnectionChangedinVerticalHomeFeed!(connected,jam!,open);
      // print("onConnectionChanged is cccalled!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    else{
    //  print("onConnectionChanged is nullll!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  static void updateJoinCallback(bool joined, int userId){
    onJoinCallback!(joined, userId);
  }
  static void updateRemoteUserJoined( int userId){
    onRemoteUserJoinedCallback!(userId);
  }
  static void updateUserLeft( int userId){
    onUserLeftCallback!(userId);
  }
  static void updateUserTalking(int userId,bool talking){
    onUserTalkingCallback!(userId,talking);
  }
  static void updateUserMuted(int userId,bool talking){
    onUserMutedCallback!(userId,talking);
  }
  static void connectionInterruptedCallback(){
    onConnectionInterruptedCallback;
  }
  static void rejoinSuccessCallback(){
    onRejoinSuccessCallback;
  }

}
