import 'package:btask/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationErrorView extends StatelessWidget {
  const NotificationErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  provider.fetchNotifications(); // Retry button
                },
                child: Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
