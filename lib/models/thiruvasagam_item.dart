class ThiruvasagamItem {
  final int id;
  final String title;
  final String duration;
  final String? audioUrl; // Optional: for actual playback

  ThiruvasagamItem({
    required this.id,
    required this.title,
    required this.duration,
    this.audioUrl,
  });
}
