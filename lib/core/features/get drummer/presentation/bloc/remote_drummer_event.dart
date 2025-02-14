abstract class RemoteDrummerEvent {
  const RemoteDrummerEvent();
}

class GetDrummer extends RemoteDrummerEvent{
  final String ? uid;
  const GetDrummer({this.uid});
}

class GetDrummerByRid extends RemoteDrummerEvent{
  final int ? rid;
  const GetDrummerByRid({this.rid});
}

