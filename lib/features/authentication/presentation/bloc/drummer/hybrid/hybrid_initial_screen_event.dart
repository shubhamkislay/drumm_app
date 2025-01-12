abstract class HybridInitialScreenEvent {
  const HybridInitialScreenEvent();
}

class GetInitialScreen extends HybridInitialScreenEvent{
  final String uid;
  const GetInitialScreen(this.uid);
}
