abstract class RemoteBandEvent {
  const RemoteBandEvent();
}

class GetCurrentUserBands extends RemoteBandEvent {
  const GetCurrentUserBands();
}

class GetBands extends RemoteBandEvent {
  List<String>? bandIds;
  GetBands({this.bandIds});
}
