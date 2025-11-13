// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:btask/core/appcolors.dart';
import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/screens/notifications/time_ago_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  // Define your 5 SVG asset paths here (adjust paths as needed)

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
    final List<String> svgIcons = [
      'assets/icons/notification1.svg',
      'assets/icons/notification2.svg',
    ];
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Height of the line
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            height: 1,
            // Or use decoration for BorderSide
            // Alternative: decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
          ),
        ),
        toolbarHeight: 80.h,
        leadingWidth: 50,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 0,
              top: 15,
              bottom: 15,
            ),
            child: SvgPicture.asset('assets/images/notback.svg'),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // Show loading spinner
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Show error message
          if (provider.errorMessage.isNotEmpty) {
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
          }

          // Show notifications list
          if (provider.notifications.isEmpty) {
            return Center(child: Text('No notifications'));
          }

          return ListView.separated(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];

              // Get the time ago string (null if older than 2 days)
              final timeAgo = TimeAgoFormatter.formatTimeAgo(
                notification.timestamp,
              );

              // Generate a random SVG icon for this notification
              // Note: This uses a seeded random based on index for consistency across rebuilds;
              // if you want true randomness (changes on rebuild), remove the seed.
              final random = Random(
                index,
              ); // Seed with index for stable per-item randomness
              final randomIconPath = svgIcons[random.nextInt(svgIcons.length)];

              return ListTile(
                leading: SvgPicture.asset(randomIconPath),
                title: Text(
                  notification.title,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.body,
                      style: GoogleFonts.quicksand(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Only show the time if it's less than 2 days old
                    if (timeAgo != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          );
        },
      ),
    );
  }
}
