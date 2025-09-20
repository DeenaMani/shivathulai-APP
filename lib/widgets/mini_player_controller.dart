import 'package:flutter/material.dart';

class MiniPlayerController extends StatelessWidget {
  final bool isPlaying;
  final String title;
  final String subtitle;
  final double progress;
  final Duration current;
  final Duration total;
  final VoidCallback onPlayPause;
  final VoidCallback? onTap;
  final VoidCallback? onSkipNext;
  final VoidCallback? onSkipPrevious;

  const MiniPlayerController({
    super.key,
    required this.isPlaying,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.current,
    required this.total,
    required this.onPlayPause,
    this.onTap,
    this.onSkipNext,
    this.onSkipPrevious,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatDuration(current),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Expanded(
                              child: Slider(
                                value: progress,
                                min: 0.0,
                                max: 1.0,
                                onChanged: (_) {},
                              ),
                            ),
                            Text(
                              _formatDuration(total),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: onSkipPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.deepOrange,
                      size: 32,
                    ),
                    onPressed: onPlayPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: onSkipNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
