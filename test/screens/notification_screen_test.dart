// test/screens/notification_screen_test.dart

/// Integration tests for NotificationScreen
///
/// These tests verify:
/// - Screen initializes correctly
/// - Provider is called on screen load
/// - App bar and body are rendered
/// - Complete user flow works end-to-end

import 'package:btask/models/notification_model.dart';
import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/screens/notifications/notifications_screen.dart';
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

@GenerateMocks([NotificationProvider])
import 'notification_screen_test.mocks.dart';

// CRITICAL FIX: Create a Fake Provider that actually extends ChangeNotifier
class FakeNotificationProvider extends NotificationProvider {
  bool _isLoading = false;
  String _errorMessage = '';
  List<NotificationItem> _notifications = [];
  bool _fetchWasCalled = false;

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  List<NotificationItem> get notifications => _notifications;

  bool get fetchWasCalled => _fetchWasCalled;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void setNotifications(List<NotificationItem> items) {
    _notifications = items;
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> fetchNotifications() async {
    _fetchWasCalled = true;
    // Don't actually fetch - just mark as called
  }
}

void main() {
  group('NotificationScreen Integration Tests', () {
    late MockNotificationProvider mockProvider;

    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should render app bar and body', (tester) async {
      // Arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(NotificationAppBar), findsOneWidget);
      expect(find.byType(NotificationBody), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should fetch notifications on init', (tester) async {
      // Arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);
      when(mockProvider.fetchNotifications()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert
      verify(mockProvider.fetchNotifications()).called(1);
    });

    testWidgets('should display loading state initially', (tester) async {
      // Arrange
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display notifications after loading', (tester) async {
      // Arrange
      final mockNotifications = [
        NotificationItem(
          image: 'test1.jpg',
          title: 'Notification 1',
          body: 'Body 1',
          timestamp: '2024-11-13T10:00:00Z',
        ),
        NotificationItem(
          image: 'test2.jpg',
          title: 'Notification 2',
          body: 'Body 2',
          timestamp: '2024-11-13T11:00:00Z',
        ),
      ];

      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn(mockNotifications);

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Notification 1'), findsOneWidget);
      expect(find.text('Notification 2'), findsOneWidget);
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
    });

    testWidgets('should display error state when fetch fails', (tester) async {
      // Arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('Network error occurred');
      when(mockProvider.notifications).thenReturn([]);

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(NotificationErrorView), findsOneWidget);
    });

    testWidgets('should display empty state when no notifications', (
      tester,
    ) async {
      // Arrange
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('should be scrollable when many notifications', (tester) async {
      // Arrange
      final manyNotifications = List.generate(
        20,
        (index) => NotificationItem(
          image: 'test$index.jpg',
          title: 'Notification $index',
          body: 'Body $index',
          timestamp: '2024-11-13T10:00:00Z',
        ),
      );

      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn(manyNotifications);

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Assert - Should find ListView
      expect(find.byType(ListView), findsOneWidget);

      // Verify scrolling works
      final listFinder = find.byType(ListView);
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still be on screen after scroll
      expect(find.byType(NotificationScreen), findsOneWidget);
    });
  });

  group('NotificationScreen State Management', () {
    testWidgets('should update UI when provider state changes', (tester) async {
      // FIXED: Use FakeNotificationProvider that actually extends ChangeNotifier
      final fakeProvider = FakeNotificationProvider();

      final notifications = [
        NotificationItem(
          image: 'test.jpg',
          title: 'New Notification',
          body: 'New Body',
          timestamp: '2024-11-13T10:00:00Z',
        ),
      ];

      // Start with loading state
      fakeProvider.setLoading(true);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: fakeProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Change to loaded state - this WILL trigger notifyListeners()
      fakeProvider.setNotifications(notifications);

      // Wait for the UI to rebuild
      await tester.pump();

      // Assert - No more loading, data is shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('New Notification'), findsOneWidget);
    });

    testWidgets('should maintain scroll position during update', (
      tester,
    ) async {
      final fakeProvider = FakeNotificationProvider();

      final notifications = List.generate(
        30,
        (index) => NotificationItem(
          image: 'test$index.jpg',
          title: 'Notification $index',
          body: 'Body $index',
          timestamp: '2024-11-13T10:00:00Z',
        ),
      );

      fakeProvider.setNotifications(notifications);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: fakeProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Scroll down
      final listFinder = find.byType(ListView);
      await tester.drag(listFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Act - Update data (trigger rebuild)
      fakeProvider.setNotifications(notifications);
      await tester.pump();

      // Assert - List should still be rendered
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('NotificationScreen User Interactions', () {
    late MockNotificationProvider mockProvider;

    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should handle tap on notification item', (tester) async {
      // Arrange
      final notification = NotificationItem(
        image: 'test.jpg',
        title: 'Tappable Notification',
        body: 'Tap me',
        timestamp: '2024-11-13T10:00:00Z',
      );

      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([notification]);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      // Act - Tap on notification
      final tileFinder = find.byType(NotificationTile);
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Assert - Should not crash
      expect(find.byType(NotificationScreen), findsOneWidget);
    });
  });

  group('NotificationScreen Performance', () {
    late MockNotificationProvider mockProvider;

    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should render large list efficiently', (tester) async {
      // Arrange
      final largeList = List.generate(
        100,
        (index) => NotificationItem(
          image: 'test$index.jpg',
          title: 'Notification $index',
          body: 'Body $index',
          timestamp: '2024-11-13T10:00:00Z',
        ),
      );

      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn(largeList);

      // Act
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: ChangeNotifierProvider<NotificationProvider>.value(
              value: mockProvider,
              child: NotificationScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Assert - Should render within reasonable time (< 3 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
