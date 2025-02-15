class PodcastEntity {
  final String audioTitle;
  final String audioUrl;
  final int status;
  final DateTime updatedAt;

  PodcastEntity({
    required this.audioTitle,
    required this.audioUrl,
    required this.status,
    required this.updatedAt,
  });
}
