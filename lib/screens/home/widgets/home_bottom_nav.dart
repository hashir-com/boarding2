import 'package:btask/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.secondaryText.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0, // just a placeholder index
        onTap: (_) {}, // no functionality yet
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 111, 111, 111),
        unselectedItemColor: AppColors.secondaryText,
        selectedLabelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/homenav.svg'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/cartnav.svg'),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/myorder.svg'),
            label: 'My order',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/account.svg'),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
