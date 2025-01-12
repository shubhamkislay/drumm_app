abstract class RemoteDrummerEvent {
  const RemoteDrummerEvent();
}

class GetDrummer extends RemoteDrummerEvent{
  final String uid;
  const GetDrummer(this.uid);
}

class IsAuthenticated extends RemoteDrummerEvent{
  final String uid;
  const IsAuthenticated(this.uid);
}