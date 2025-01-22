abstract class RemoteAuthEvent {
  const RemoteAuthEvent();
}


class IsAuthenticated extends RemoteAuthEvent{
  final String uid;
  const IsAuthenticated(this.uid);
}
