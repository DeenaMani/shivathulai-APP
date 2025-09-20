// models/song_model.dart
import 'audio_model.dart';

class Song {
  final String songId;
  final String title;
  final int categoryId;
  final int groupId;
  final String? lyrics; // Make nullable if lyrics can be null
  final String? description;
  final String image;
  final String coverImage;
  final String previousSongId;
  final String nextSongId;
  final String categoryName;
  final String groupName;
  final List<Audio> audios;

  Song({
    required this.songId,
    required this.title,
    required this.categoryId,
    required this.groupId,
    this.lyrics,
    this.description,
    required this.image,
    required this.coverImage,
    required this.previousSongId,
    required this.nextSongId,
    required this.categoryName,
    required this.groupName,
    required this.audios,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    var audioList = json['audios'] as List<dynamic>? ?? [];
    List<Audio> audios = audioList.map((a) => Audio.fromJson(a)).toList();

    return Song(
      songId: json['song_id'] ?? '',
      title: json['title'] ?? '',
      categoryId: json['category_id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      lyrics: json['lyrics'], // can be null
      description: json['description'],
      image: json['image'] ?? '',
      coverImage: json['cover_image'] ?? '',
      previousSongId: json['previous_song_id'] ?? '',
      nextSongId: json['next_song_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      groupName: json['group_name'] ?? '',
      audios: audios,
    );
  }
}
