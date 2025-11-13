import 'package:btask/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
      color: AppColors.background,
      child: Column(
        children: [
          // Location Row
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/Vectorlocation.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 5),
              Text(
                'ABCD, New Delhi',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(width: 8),
              SvgPicture.asset(
                'assets/images/back button.svg',
                width: 5,
                height: 10,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              Spacer(),
            ],
          ),

          SizedBox(height: 25),

          // Search Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for products/stores',
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 13.sp,
                      color: AppColors.primaryText.withOpacity(0.5),
                    ),
                    // FIX: Wrap SVG in Padding widget for proper sizing
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/images/Vectorsearch.svg',
                        width: 10,
                        height: 10,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.secondaryBackground,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              SizedBox(width: 15),
              GestureDetector(
                child: SvgPicture.asset(
                  'assets/images/notification.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.notification,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () => context.push('/notification'),
              ),
              SizedBox(width: 15),
              SvgPicture.asset(
                'assets/images/tag.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(AppColors.tag, BlendMode.srcIn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
