import 'package:btask/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:btask/screens/notifications/notifications_screen.dart';

/// Centralized route name constants to avoid hardcoded strings throughout the app
class RouteNames {
  RouteNames._(); // Private constructor to prevent instantiation
  
  static const String home = '/';
  static const String notification = '/notification';
}

/// Main router configuration for the application
/// Defines all available routes and their corresponding screen widgets
final GoRouter router = GoRouter(
  routes: [
    // Home screen route - the landing page of the app
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Notifications screen route - displays user notifications
    GoRoute(
      path: RouteNames.notification,
      name: 'notification',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);