import 'package:btask/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NearbyStores extends StatelessWidget {
  const NearbyStores({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: 12.h),
        _buildStoreRow(
          imagePath: "assets/images/freshlybaker.png",
          name: "Freshly Bakery",
          category: "Sweets, North indian",
          location: "Site No -1 | 6.4kms",
          rating: "4.1",
          time: "45 mins",
        ),
        SizedBox(height: 24.h),
        _buildStoreRow(
          imagePath: "assets/images/freshlybaker.png",
          name: "Freshly Bakery",
          category: "Sweets, North indian",
          location: "Site No -1 | 6.4kms",
          rating: "4.1",
          time: "45 mins",
        ),
        _button(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nearby Stores',
            style: GoogleFonts.quicksand(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "See all",
            style: GoogleFonts.quicksand(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreRow({
    required String imagePath,
    required String name,
    required String category,
    required String location,
    required String rating,
    required String time,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath),
          SizedBox(width: 15.w),
          Expanded(
            child: Container(
              width: 250.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStoreInfo(name, category, location),
                      _buildRatingTime(rating, time),
                    ],
                  ),
                  Divider(color: AppColors.secondaryText.withOpacity(0.2)),
                  _offanditem(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo(String name, String category, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.quicksand(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          category,
          style: GoogleFonts.quicksand(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          location,
          style: GoogleFonts.quicksand(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.h),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.topbg.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: Text(
            "Top Store",
            style: GoogleFonts.quicksand(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingTime(String rating, String time) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 15.sp, color: AppColors.secondaryText),
            SizedBox(width: 4.w),
            Text(
              rating,
              style: GoogleFonts.quicksand(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: GoogleFonts.quicksand(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.tag,
          ),
        ),
      ],
    );
  }

  Widget _offanditem() {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset("assets/images/Vectoroffer.svg"),
              SizedBox(width: 6.w),
              Text(
                "Upto 10% OFF",
                style: GoogleFonts.quicksand(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(width: 10.w),
              SvgPicture.asset("assets/images/grocery available.svg"),
              SizedBox(width: 6.w),
              Text(
                "3400+ items available",
                style: GoogleFonts.quicksand(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34.0),
      child: Container(
        width: 240.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            "View all stores",
            style: GoogleFonts.quicksand(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
