class PodcastEntity {
  final String audioTitle;
  final String podcastTitle;
  final String audioUrl;
  final int requestStatus;
  final DateTime updatedAt;

  PodcastEntity({
    required this.audioTitle,
    required this.podcastTitle,
    required this.audioUrl,
    required this.requestStatus,
    required this.updatedAt,
  });
}
