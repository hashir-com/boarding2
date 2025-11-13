// test/widgets/notification_widgets_test.dart

/// Minimal widget tests for notification UI components
/// Focused on rendering and structure, not state transitions

import 'package:btask/models/notification_model.dart';
import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/screens/notifications/widgets/notification_error_view.dart';
import 'package:btask/screens/notifications/widgets/notification_header.dart';
import 'package:btask/screens/notifications/widgets/notification_list.dart';
import 'package:btask/screens/notifications/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../screens/notification_screen_test.mocks.dart';

@GenerateMocks([NotificationProvider])
void main() {
  final mockNotifications = [
    NotificationItem(
      image: 'test1.jpg',
      title: 'Notification 1',
      body: 'Body 1',
      timestamp: DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
    ),
    NotificationItem(
      image: 'test2.jpg',
      title: 'Notification 2',
      body: 'Body 2',
      timestamp: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    ),
  ];

  group('NotificationAppBar Widget Tests', () {
    testWidgets('should render app bar with correct title', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) =>
              MaterialApp(home: Scaffold(appBar: NotificationAppBar())),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have correct preferred size', (tester) async {
      const appBar = NotificationAppBar();
      expect(appBar.preferredSize.height, greaterThan(0));
    });
  });

  group('NotificationBody Widget Tests', () {
    late MockNotificationProvider mockProvider;

    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: Scaffold(body: NotificationBody()),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error view when error occurs', (tester) async {
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('Network error');
      when(mockProvider.notifications).thenReturn([]);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: Scaffold(body: NotificationBody()),
            ),
          ),
        ),
      );

      expect(find.byType(NotificationErrorView), findsOneWidget);
    });

    testWidgets('should show empty message when no notifications', (
      tester,
    ) async {
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: Scaffold(body: NotificationBody()),
            ),
          ),
        ),
      );

      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('should show list when data available', (tester) async {
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn(mockNotifications);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: Scaffold(body: NotificationBody()),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(NotificationTile), findsNWidgets(2));
    });
  });

  group('NotificationTile Widget Tests', () {
    testWidgets('should render notification data correctly', (tester) async {
      final notification = NotificationItem(
        image: 'test.jpg',
        title: 'Test Notification',
        body: 'This is a test notification body',
        timestamp: DateTime.now().toIso8601String(),
      );

      final svgIcons = [
        'assets/icons/notification1.svg',
        'assets/icons/notification2.svg',
      ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: NotificationTile(
                notification: notification,
                svgIcons: svgIcons,
                index: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification body'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should display leading icon', (tester) async {
      final notification = NotificationItem(
        image: 'test.jpg',
        title: 'Test',
        body: 'Body',
        timestamp: DateTime.now().toIso8601String(),
      );

      final svgIcons = ['assets/icons/notification1.svg'];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: NotificationTile(
                notification: notification,
                svgIcons: svgIcons,
                index: 0,
              ),
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.leading, isNotNull);
    });

    testWidgets('should handle empty notification data gracefully', (
      tester,
    ) async {
      final emptyNotification = NotificationItem(
        image: '',
        title: '',
        body: '',
        timestamp: DateTime.now().toIso8601String(),
      );

      final svgIcons = ['assets/icons/notification1.svg'];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: NotificationTile(
                notification: emptyNotification,
                svgIcons: svgIcons,
                index: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
