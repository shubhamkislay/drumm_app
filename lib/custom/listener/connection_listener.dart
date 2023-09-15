import 'package:drumm_app/model/jam.dart';

class ConnectionListener {
  static Function(bool,Jam,bool)? onConnectionChanged;
  static Function(bool,Jam,bool)? onConnectionChangedinRoom;
  static Function(bool,Jam,bool)? onConnectionChangedinCard;

  static void updateConnectionDetails(bool connected, Jam? jam,bool open) {

    if (onConnectionChanged != null) {
      onConnectionChanged!(connected,jam!,open);
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
    else{
      print("onConnectionChanged is nullll!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }
}
