import 'dart:math';
import 'package:btask/screens/notifications/time_ago_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationTile extends StatelessWidget {
  final dynamic notification;
  final List<String> svgIcons;
  final int index;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.svgIcons,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Get the time ago string (null if older than 2 days)
    final timeAgo = TimeAgoFormatter.formatTimeAgoOrDate(
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
            SizedBox(height: 8.h),
            Text(
              timeAgo,
              style: GoogleFonts.quicksand(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
