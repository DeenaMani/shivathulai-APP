// models/audio_model.dart
class Audio {
  final String url;
  final String singerImage;
  final String singerName;
  final String testUrl;

  Audio({
    required this.url,
    required this.singerImage,
    required this.singerName,
    required this.testUrl,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      url: json['url'] ?? '',
      singerImage: json['singer_image'] ?? '',
      singerName: json['singer_name'] ?? '',
      testUrl: json['test_url'] ?? '',
    );
  }
}
