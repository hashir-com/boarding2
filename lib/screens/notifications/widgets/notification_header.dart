import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar notificationAppBar(BuildContext context) {
  return AppBar(
    leading: GestureDetector(
      onTap: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Mimics original padding for icon
        child: SvgPicture.asset('assets/images/Group 597back.svg'),
      ),
    ),
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0), // Matches original all-around padding, adjusted for title
      child: Text(
        'Notifications',
        style: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(2.0),
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
      ),
    ),
    titleSpacing: 20.0, // Adds space between leading and title to match SizedBox(width: 20)
    automaticallyImplyLeading: false, // Disable default back button since we're using custom leading
  );
}