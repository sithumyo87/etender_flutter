import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.notification_important);
  }

  void goToDetailedPage() {
    print('goToDetailedPage');
  }
}
