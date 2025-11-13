
import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/screens/notifications/widgets/notification_tile.dart';
import 'package:btask/screens/notifications/widgets/notification_error_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationBody extends StatelessWidget {
  const NotificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> svgIcons = [
      'assets/icons/notification1.svg',
      'assets/icons/notification2.svg',
    ];
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        // Show loading spinner
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (provider.errorMessage.isNotEmpty) {
          return NotificationErrorView();
        }

        // Show notifications list
        if (provider.notifications.isEmpty) {
          return Center(child: Text('No notifications'));
        }

        return ListView.separated(
          itemCount: provider.notifications.length,
          itemBuilder: (context, index) {
            final notification = provider.notifications[index];
            return NotificationTile(
              notification: notification,
              svgIcons: svgIcons,
              index: index,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        );
      },
    );
  }
}