import 'package:flutter/material.dart';

class SongItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final String? imageUrl;

  const SongItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.isPlaying = false,
    this.onPlayPause,
    this.imageUrl,
  });

  // ...existing code...
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: isPlaying ? Colors.pink.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (isPlaying)
              BoxShadow(
                color: Colors.pink.shade100.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: isPlaying ? Colors.pink.shade200 : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: imageUrl != null
              ? CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(imageUrl!),
                  backgroundColor: Colors.grey[200],
                )
              : null,
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPlaying ? Colors.pink.shade700 : Colors.black87,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: isPlaying ? Colors.pink.shade700 : Colors.black54,
              fontSize: 14,
            ),
          ),
          trailing: Material(
            color: isPlaying ? Colors.pink.shade300 : Colors.pink.shade100,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: onPlayPause,
            ),
          ),
        ),
      ),
    );
  }
}
