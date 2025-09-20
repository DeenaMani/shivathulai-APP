import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shivathuli/models/song_model.dart';
import 'package:dio/dio.dart';
import 'package:shivathuli/services/api_service.dart';

class MiniPlayerPage extends StatefulWidget {
  final Song currentPlayingSong;
  final List<Song> songList;

  const MiniPlayerPage({
    super.key,
    required this.currentPlayingSong,
    required this.songList,
  });

  @override
  State<MiniPlayerPage> createState() => _MiniPlayerPageState();
}

class _MiniPlayerPageState extends State<MiniPlayerPage> {
  late int _currentPlayingIndex;
  late AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    _currentPlayingIndex = widget.songList.indexOf(widget.currentPlayingSong);
    if (_currentPlayingIndex == -1) _currentPlayingIndex = 0;

    _audioPlayer = AudioPlayer();
    _setupAudio();

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying =
            state.playing && state.processingState != ProcessingState.completed;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() => _totalDuration = duration);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() => _currentDuration = position);
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _skipNext();
      }
    });
  }

  Future<void> _setupAudio() async {
    final song = widget.songList[_currentPlayingIndex];

    if (song.audios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('இந்தப் பாடலுக்கு audio இல்லை')),
      );
      return;
    }

    final String audiourl = song.audios.first.url;

    try {
      final streamUrl = await _apiService.fetchStreamUrl(url: audiourl);

      if (streamUrl.isEmpty) throw Exception("Empty stream URL");

      await _audioPlayer.setUrl(streamUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Audio load/play error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio சேமிக்க முடியவில்லை: $e')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _skipNext() async {
    _currentPlayingIndex = (_currentPlayingIndex + 1) % widget.songList.length;
    await _playCurrentIndex();
  }

  void _skipPrevious() async {
    _currentPlayingIndex =
        (_currentPlayingIndex - 1 + widget.songList.length) %
        widget.songList.length;
    await _playCurrentIndex();
  }

  Future<void> _playCurrentIndex() async {
    setState(() {
      _currentDuration = Duration.zero;
      _totalDuration = Duration.zero;
    });
    await _setupAudio();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songList[_currentPlayingIndex];
    final progress = _totalDuration.inMilliseconds == 0
        ? 0.0
        : _currentDuration.inMilliseconds / _totalDuration.inMilliseconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSong.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              currentSong.title,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              currentSong.categoryName ?? "Unknown Category",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (currentSong.coverImage != null &&
                currentSong.coverImage!.isNotEmpty)
              Image.network(currentSong.coverImage!, height: 200),
            const SizedBox(height: 20),
            Slider(
              value: progress.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              onChanged: (value) {
                final position = _totalDuration * value;
                _audioPlayer.seek(position);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_currentDuration)),
                Text(_formatDuration(_totalDuration)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _skipPrevious,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 48,
                    color: Colors.deepPurple,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _skipNext,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.songList.length,
                itemBuilder: (context, index) {
                  final song = widget.songList[index];
                  final isCurrent = index == _currentPlayingIndex;
                  return ListTile(
                    title: Text(song.title),
                    subtitle: Text(song.categoryName ?? ""),
                    trailing: isCurrent && _isPlaying
                        ? const Icon(Icons.equalizer)
                        : null,
                    onTap: () async {
                      _currentPlayingIndex = index;
                      await _playCurrentIndex();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
