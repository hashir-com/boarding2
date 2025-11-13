import 'package:btask/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:btask/screens/notifications/notifications_screen.dart';

class RouteNames {
  RouteNames._();
  static const String home = '/';
  static const String notification = '/notification';
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.notification,
      name: 'notification',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);
