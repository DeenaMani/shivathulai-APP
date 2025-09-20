import 'package:flutter/material.dart';

import 'package:shivathuli/models/song_model.dart';
import 'package:shivathuli/services/api_service.dart';
import 'package:shivathuli/views/play_page.dart';
import 'package:shivathuli/widgets/thitrumuraikal_item.dart';

class SongListPage extends StatefulWidget {
  final int? categoryId;
  final int? groupId;
  final String collectionTitle;

  const SongListPage({
    super.key,
    this.categoryId,
    this.groupId,
    this.collectionTitle = "பாடல்கள்",
  });

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final ApiService apiService = ApiService();

  List<Song> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    try {
      List<Song> fetchedSongs = [];

      if (widget.groupId != null) {
        fetchedSongs = await apiService.fetchSongsByGroup(
          groupId: widget.groupId!,
        );
      } else if (widget.categoryId != null) {
        // Optional: implement this if needed
        // fetchedSongs = await apiService.fetchSongsByCategory(widget.categoryId!);
      }

      setState(() {
        songs = fetchedSongs;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to load songs: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.collectionTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {
              print("Notifications tapped from SongListPage");
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : songs.isEmpty
          ? const Center(child: Text("பாடல்கள் எதுவும் இல்லை"))
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return SongItem(
                  title: song.title,
                  subtitle: song.categoryName,
                  isPlaying: false,
                  imageUrl: song.image,
                  onPlayPause: () {
                    if (songs.isEmpty) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayerPage(songList: songs, initialIndex: index),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
