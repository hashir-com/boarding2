import 'package:btask/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': 'assets/images/fooddelivery.svg',
        'name': 'Food Delivery',
        'offer': '10% OFF',
      },
      {
        'icon': 'assets/images/medicine 1medicines.svg',
        'name': 'Medicines',
        'offer': '10% OFF',
      },
      {
        'icon': 'assets/images/Vectorpet.svg',
        'name': 'Pet Supplies',
        'offer': '10% OFF',
      },
      {'icon': 'assets/images/Groupgift.svg', 'name': 'Gifts'},
      {'icon': 'assets/images/meat.svg', 'name': 'Meat'},
      {'icon': 'assets/images/Make Up.svg', 'name': 'Cosmetics'},
      {'icon': 'assets/images/Groupstationery.svg', 'name': 'Stationery'},
      {
        'icon': 'assets/images/stores.svg',
        'name': 'Stores',
        'offer': '10% OFF',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What would you like to do today?",
            style: GoogleFonts.quicksand(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 20.w,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
              final item = categories[index];
              return CategoryCard(
                iconPath: item['icon']!,
                categoryName: item['name']!,
                offerText: item['offer'],
              );
            },
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "More",
                style: GoogleFonts.quicksand(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 3.w),
              SvgPicture.asset(
                'assets/images/back button.svg',
                width: 5.w,
                height: 8.h,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String iconPath;
  final String categoryName;
  final String? offerText;

  const CategoryCard({
    super.key,
    required this.iconPath,
    required this.categoryName,
    this.offerText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                spreadRadius: 1.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: SvgPicture.asset(iconPath, height: 40.h, width: 40.w),
              ),
              if (offerText != null)
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.offer,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      offerText!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 4.5.h),
        SizedBox(
          width: 70.w,
          child: Text(
            categoryName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
