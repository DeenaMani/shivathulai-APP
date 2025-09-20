import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Explore Content Here',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
