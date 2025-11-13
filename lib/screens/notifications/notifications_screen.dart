// lib/screens/notifications/notification_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/screens/notifications/widgets/notification_header.dart';
import 'package:btask/screens/notifications/widgets/notification_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    Future.microtask(
      () => context.read<NotificationProvider>().fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NotificationAppBar(),
      body: const NotificationBody(),
    );
  }
}
