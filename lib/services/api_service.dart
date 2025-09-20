// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:shivathuli/models/group_model.dart';
import 'package:shivathuli/models/singer_model.dart';

import 'package:shivathuli/models/song_model.dart';
import '../models/category_model.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String base1 =
      'http://10.199.56.145:8080/horizontamil/projects/webapp/api/V1'; //deena
  static const String base2 =
      'http://172.23.214.145:8080/horizontamil/projects/webapp/api/V1'; //kums
  static const String baseUrl =
      'http://10.199.56.145:8080/horizontamil/projects/webapp/api/V1';

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _dio.get('$baseUrl/category');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<List<Singer>> fetchSingers() async {
    try {
      final response = await _dio.get('$baseUrl/singers');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Fetched singers data: $data'); // Debug print
        return data
            .map((json) => Singer.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load singers');
      }
    } catch (e) {
      print('Error fetching singers: $e');
      rethrow;
    }
  }

  Future<List<Song>> fetchSongsByGroup({int groupId = 1}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/songs',
        queryParameters: {'group': groupId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load songs");
      }
    } catch (e) {
      print("Error fetching songs: $e");
      rethrow;
    }
  }

  Future<List<Group>> fetchGroups() async {
    try {
      final response = await _dio.get('$baseUrl/groups');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (e) {
      print('Error fetching groups: $e');
      rethrow;
    }
  }

  Future<String> fetchStreamUrl({required String url}) async {
    try {
      final response = await _dio.post(url);

      if (response.statusCode == 200) {
        // Assuming the server returns the stream URL in response.data['url'] or similar
        return response.data['url'] ?? '';
      } else {
        throw Exception('Failed to fetch stream URL');
      }
    } catch (e) {
      print('Error fetching stream URL: $e');
      rethrow;
    }
  }

  Future<Song> fetchSongById(String songId) async {
    try {
      final response = await _dio.post('$baseUrl/song/$songId');

      print('Response data: ${response.data}'); // Debug print

      if (response.statusCode == 200) {
        final data = response.data; // Use response.data directly

        if (data == null) {
          throw Exception('No song data found for ID: $songId');
        }

        if (data is List) {
          final fullSongList = data.map((json) => Song.fromJson(json)).toList();
          final matchedSong = fullSongList.firstWhere(
            (song) => song.songId == songId,
            orElse: () => throw Exception('Song not found in list'),
          );
          return matchedSong;
        }

        // data is a single object (Map)
        final song = Song.fromJson(data);
        return song;
      } else {
        throw Exception('Failed to load song');
      }
    } catch (e) {
      print('Error fetching song by ID: $e');
      rethrow;
    }
  }
}
