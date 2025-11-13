import 'package:btask/core/appcolors.dart';
import 'package:btask/screens/home/widgets/craze_deals.dart';
import 'package:btask/screens/home/widgets/home_bottom_nav.dart';
import 'package:btask/screens/home/widgets/home_category.dart';
import 'package:btask/screens/home/widgets/home_header.dart';
import 'package:btask/screens/home/widgets/nearby_stores.dart';
import 'package:btask/screens/home/widgets/top_picks.dart';
import 'package:btask/screens/home/widgets/trending.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              HomeHeader(), //header section
              CategoriesSection(), // categories section
              TopPicks(), // top picks section
              Trending(), // trending section
              CrazeDeals(), // craze deals section
              NearbyStores(), // nearby stores section
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(), // bottom navigation bar
    );
  }
}
