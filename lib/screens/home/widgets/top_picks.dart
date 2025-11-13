import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:btask/core/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopPicks extends StatefulWidget {
  const TopPicks({super.key});

  @override
  State<TopPicks> createState() => _TopPicksState();
}

class _TopPicksState extends State<TopPicks> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> banners = [
      {
        'image': 'assets/images/fruit_image.png',
        'title': 'DISCOUNT\n25% ALL\nFRUITS',
        'buttonText': 'CHECK NOW',
        'color': AppColors.banner,
      },
    ];

    return Column(
      children: [
        // Title
        Padding(
          padding: EdgeInsets.only(left: 18.w, right: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Top picks for you",
                style: GoogleFonts.quicksand(
                  fontSize: 18.sp, // Responsive font size
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h), // Responsive height

        SizedBox(
          height: 160.h, // Responsive height
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: banner['color'],
                      borderRadius: BorderRadius.circular(
                        5.r,
                      ), // Responsive radius
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w), // Responsive padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            banner['title'],
                            maxLines: 3,
                            style: GoogleFonts.poppins(
                              letterSpacing: 1.2,
                              height: 1.1,
                              fontSize: 20.sp, // Responsive font size
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 24.h, // Responsive height
                            width: 140.w, // Responsive width
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tag,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                              ),
                              child: Text(
                                banner['buttonText'],
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp, // Responsive font size
                                  letterSpacing: sqrt1_2,
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -5.h,
                    right: 5.w, // Responsive position
                    child: Image.asset(
                      banner['image'],
                      height: 180.h, // Responsive height
                      width: 180.w,

                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(height: 180.h, width: 180.w);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
