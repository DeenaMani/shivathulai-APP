import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your Notifications',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
