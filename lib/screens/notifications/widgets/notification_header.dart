// lib/screens/notifications/widgets/notification_header.dart
import 'package:btask/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
