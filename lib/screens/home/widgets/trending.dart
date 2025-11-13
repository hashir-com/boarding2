import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:btask/core/appcolors.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    final trending = List.generate(10, (index) {
      return {
        'name': 'Mithas Bhandar',
        'type': 'Sweets, North Indian',
        'address': '(store location) | 6.4 kms',
        'rating': '4.1 | 45 mins',
        'image': 'assets/images/icecream.png',
      };
    });

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trending",
                style: GoogleFonts.quicksand(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "See All",
                style: GoogleFonts.quicksand(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Two Row Grid
        SizedBox(
          height: 200.h,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0.w,
              crossAxisSpacing: 0.h,
              childAspectRatio: 0.45,
            ),
            itemCount: trending.length,
            itemBuilder: (context, index) {
              return _buildProductCard(trending[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> trending) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(trending['image']),
        SizedBox(width: 15.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              trending['name'],
              style: GoogleFonts.quicksand(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              trending['type'],
              style: GoogleFonts.quicksand(
                fontSize: 10.sp,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              trending['address'],
              style: GoogleFonts.quicksand(
                fontSize: 10.sp,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.star, size: 12.sp, color: AppColors.secondaryText),
                SizedBox(width: 4.w),
                Text(
                  trending['rating'],
                  style: GoogleFonts.quicksand(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
