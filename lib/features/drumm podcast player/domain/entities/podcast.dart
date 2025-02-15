class PodcastEntity {
  final String audioTitle;
  final String audioUrl;
  final int requestStatus;
  final DateTime updatedAt;

  PodcastEntity({
    required this.audioTitle,
    required this.audioUrl,
    required this.requestStatus,
    required this.updatedAt,
  });
}
