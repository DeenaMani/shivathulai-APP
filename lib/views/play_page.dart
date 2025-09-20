import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shivathuli/models/song_model.dart';
import 'package:shivathuli/services/api_service.dart';
import 'package:shivathuli/widgets/mini_player_controller.dart';

class PlayerPage extends StatefulWidget {
  final List<Song>? songList;
  final int? initialIndex;
  final String? songId;

  const PlayerPage({super.key, this.songList, this.initialIndex, this.songId});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  Song? _currentSong;

  int _currentAudioIndex = 0;
  bool _isPlaying = false;

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _currentPlaybackProgress = 0.0;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pageController = PageController(initialPage: 0);

    if (widget.songId != null) {
      _loadSingleSong(widget.songId!);
    } else if (widget.songList != null && widget.songList!.isNotEmpty) {
      _initWithSongList();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('பாடல்கள் கிடைக்கவில்லை')));
      });
    }
  }

  void _initWithSongList() {
    _currentIndex = widget.initialIndex ?? 0;

    final shortSong = widget.songList![_currentIndex];

    ApiService()
        .fetchSongById(shortSong.songId)
        .then((fullSong) {
          if (!mounted) return;

          setState(() {
            _currentSong = fullSong;
            _currentAudioIndex = 0;
          });

          if (_currentSong!.lyrics == null ||
              _currentSong!.lyrics!.trim().isEmpty) {
            print("No lyrics available for: ${_currentSong!.title}");
          } else {
            print("Loaded lyrics: ${_currentSong!.lyrics}");
          }

          if (_currentSong!.audios.isNotEmpty) {
            _playAudio(_currentSong!.audios[_currentAudioIndex].testUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('இப்பாடலுக்கு ஒலிக்கோப்பு இல்லை')),
            );
          }

          _subscribeToPlayerStreams();
        })
        .catchError((e) {
          print("Error fetching full song: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('பாடலை ஏற்ற முடியவில்லை')),
          );
          Navigator.of(context).pop();
        });
  }

  void _subscribeToPlayerStreams() {
    _positionSub = _audioPlayer.positionStream.listen((position) {
      if (!mounted) return;
      setState(() {
        _currentDuration = position;
        if (_totalDuration.inMilliseconds > 0) {
          _currentPlaybackProgress =
              position.inMilliseconds / _totalDuration.inMilliseconds;
        }
      });
    });

    _durationSub = _audioPlayer.durationStream.listen((duration) {
      if (!mounted) return;
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _loadSingleSong(String songId) async {
    try {
      final song = await ApiService().fetchSongById(songId);
      setState(() {
        _currentSong = song;
        _currentAudioIndex = 0;
        _currentIndex = 0;
      });
      print(
        'Lyrics: "${_currentSong!.lyrics}"',
      ); // Safe here since _currentSong is assigned

      if (song.audios.isNotEmpty) {
        _playAudio(song.audios[0].testUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('இப்பாடலுக்கு ஒலிக்கோப்பு இல்லை')),
        );
      }

      _subscribeToPlayerStreams();
    } catch (e) {
      print('Failed to load song: $e');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('பாடலை ஏற்ற முடியவில்லை')));
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to play audio')));
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _skipNext() {
    if (widget.songList == null) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.songList!.length;
      _currentSong = widget.songList![_currentIndex];
      _currentAudioIndex = 0;
      _playAudio(_currentSong!.audios[_currentAudioIndex].testUrl);
    });
  }

  void _skipPrevious() {
    if (widget.songList == null) return;

    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.songList!.length) %
          widget.songList!.length;
      _currentSong = widget.songList![_currentIndex];
      _currentAudioIndex = 0;
      _playAudio(_currentSong!.audios[_currentAudioIndex].testUrl);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _currentSong == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _buildLyricsPage(),
                      _buildArtworkPage(textTheme),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildPageIndicator(),
                const SizedBox(height: 8),
              ],
            ),
    );
  }

  Widget _buildLyricsPage() {
    return Column(
      children: [
        if (_currentSong != null &&
            _currentSong!.lyrics != null &&
            _currentSong!.lyrics!.trim().isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Html(data: _currentSong!.lyrics!),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Text(
                'Lyrics not available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        _buildSongCard(),
      ],
    );
  }

  Widget _buildArtworkPage(TextTheme textTheme) {
    if (_currentSong == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildArtworkSection(textTheme, _currentSong!),
          const SizedBox(height: 30),
          _buildPlaybackControls(textTheme),
          const SizedBox(height: 20),
          _buildSingersList(),
        ],
      ),
    );
  }

  Widget _buildSongCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_currentSong!.image),
            backgroundColor: Colors.grey[200],
          ),
          title: Text(
            _currentSong!.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(_currentSong!.categoryName),
          trailing: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.deepOrange,
            ),
            onPressed: _togglePlayPause,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(TextTheme textTheme) {
    return MiniPlayerController(
      isPlaying: _isPlaying,
      title: _currentSong!.title,
      subtitle: _currentSong!.categoryName,
      progress: _currentPlaybackProgress.clamp(0.0, 1.0),
      current: _currentDuration,
      total: _totalDuration,
      onPlayPause: _togglePlayPause,
      onSkipNext: _skipNext,
      onSkipPrevious: _skipPrevious,
      onTap: null,
    );
  }

  Widget _buildArtworkSection(TextTheme textTheme, Song song) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomLeft: Radius.circular(120),
        bottomRight: Radius.circular(120),
      ),
      child: Container(
        width: 240,
        height: 400,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(song.image, fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(120),
                    bottomRight: Radius.circular(120),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      song.categoryName,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingersList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _currentSong!.audios.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final audio = _currentSong!.audios[index];
            final isSelected = _currentAudioIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentAudioIndex = index;
                });
                _audioPlayer.stop();
                _playAudio(audio.testUrl);
              },
              child: Chip(
                label: Text(
                  audio.singerName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: isSelected ? Colors.deepOrange : Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.deepOrange),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double selectedness = 0;
            if (_pageController.hasClients && _pageController.page != null) {
              selectedness = (1 - ((_pageController.page! - index).abs()))
                  .clamp(0.0, 1.0);
            }
            final color = Color.lerp(
              Colors.grey,
              Colors.deepOrange,
              selectedness,
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            );
          },
        );
      }),
    );
  }
}
