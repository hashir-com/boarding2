import 'package:btask/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CrazeDeals extends StatelessWidget {
  const CrazeDeals({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Craze deals",
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 150.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Image.asset('assets/images/Group 110craze.png');
              },
            ),
          ),

          //Refer and Earn Section
          SizedBox(height: 15.h),
          Container(
            height: 70.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Refer & Earn",
                        style: GoogleFonts.quicksand(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Invite your friends & earn",
                            style: GoogleFonts.quicksand(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                        Text(
                          " 15% off  ",
                          style: GoogleFonts.quicksand(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.background,
                          ),
                        ),
                        Icon(
                          Icons.arrow_circle_right,
                          color: AppColors.background,
                          size: 15.sp,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 10.w),
                SvgPicture.asset("assets/images/gift.svg"),
              ],
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}
