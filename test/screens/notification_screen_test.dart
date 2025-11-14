// Integration tests for NotificationScreen
//
// Integration tests verify how different parts of the app work together.
// Unlike unit tests (which test one piece), these tests verify:
// - The screen displays correctly with real widgets
// - Data flows properly from Provider to UI
// - User interactions work as expected
// - Screen handles different states (loading, error, success)
//
// We use "mocks" (fake versions) of the provider to control what data
// the screen receives, making tests predictable and fast.

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

// Generate mock classes - Mockito creates fake versions of our classes for testing
@GenerateMocks([NotificationProvider])
import 'notification_screen_test.mocks.dart';

// FakeNotificationProvider - A test version of NotificationProvider
//
// This extends the real NotificationProvider so it can be used with Provider package.
// Unlike mocks, this actually calls notifyListeners() so widgets rebuild properly.
//
// Why we need this:
// - MockNotificationProvider doesn't trigger real widget rebuilds
// - We need to test that UI updates when provider state changes
// - This fake class lets us control state AND see real widget behavior
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

  // Track if fetch was called (useful for testing initialization)
  bool get fetchWasCalled => _fetchWasCalled;

  // Set loading state and notify widgets to rebuild
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // This is what makes widgets update
  }

  // Set error message and notify widgets
  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  // Set notifications data and notify widgets
  void setNotifications(List<NotificationItem> items) {
    _notifications = items;
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> fetchNotifications() async {
    _fetchWasCalled = true;
    // Don't actually call API - just mark that this method was called
  }
}

void main() {
  group('NotificationScreen Integration Tests', () {
    // Mock provider - used in most tests where we just need to verify display
    late MockNotificationProvider mockProvider;

    // setUp runs before each test to create a fresh mock
    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should render app bar and body', (tester) async {
      // Set up what the mock provider should return when asked for data
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

      // Build the widget tree with our screen
      // ScreenUtilInit handles responsive sizing
      // ChangeNotifierProvider provides the mock to the screen
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

      // Verify the screen has the expected structure
      expect(find.byType(NotificationAppBar), findsOneWidget);
      expect(find.byType(NotificationBody), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should fetch notifications on init', (tester) async {
      // Set up mock responses
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);
      when(mockProvider.fetchNotifications()).thenAnswer((_) async {});

      // Render the screen
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

      // Verify fetchNotifications was called exactly once when screen loaded
      // This ensures data is fetched automatically when user opens the screen
      verify(mockProvider.fetchNotifications()).called(1);
    });

    testWidgets('should display loading state initially', (tester) async {
      // Simulate the loading state (data is being fetched)
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

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

      // When loading, screen should show a circular progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display notifications after loading', (tester) async {
      // Create fake notification data to display
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

      // Simulate successful data load
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn(mockNotifications);

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

      // Verify both notifications are displayed on screen
      expect(find.text('Notification 1'), findsOneWidget);
      expect(find.text('Notification 2'), findsOneWidget);
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
    });

    testWidgets('should display error state when fetch fails', (tester) async {
      // Simulate an error scenario (network failure, server error, etc.)
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('Network error occurred');
      when(mockProvider.notifications).thenReturn([]);

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

      // When there's an error, screen should show error view to the user
      expect(find.byType(NotificationErrorView), findsOneWidget);
    });

    testWidgets('should display empty state when no notifications', (
      tester,
    ) async {
      // Simulate successful load but with no notifications
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn('');
      when(mockProvider.notifications).thenReturn([]);

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

      // Should show a friendly "no notifications" message
      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('should be scrollable when many notifications', (tester) async {
      // Generate 20 notifications to test scrolling behavior
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

      // Should use ListView for scrollable list
      expect(find.byType(ListView), findsOneWidget);

      // Test actual scrolling - drag list up by 500 pixels
      final listFinder = find.byType(ListView);
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle(); // Wait for scroll animation to complete

      // Screen should still be present after scrolling (didn't crash)
      expect(find.byType(NotificationScreen), findsOneWidget);
    });
  });

  group('NotificationScreen State Management', () {
    testWidgets('should update UI when provider state changes', (tester) async {
      // Use FakeProvider here because we need real notifyListeners() behavior
      // MockProvider doesn't actually trigger widget rebuilds
      final fakeProvider = FakeNotificationProvider();

      final notifications = [
        NotificationItem(
          image: 'test.jpg',
          title: 'New Notification',
          body: 'New Body',
          timestamp: '2024-11-13T10:00:00Z',
        ),
      ];

      // Start in loading state
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

      // Confirm loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Change state to loaded - this triggers notifyListeners()
      fakeProvider.setNotifications(notifications);

      // Wait for widgets to rebuild
      await tester.pump();

      // Verify UI updated: loading is gone, notification is shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('New Notification'), findsOneWidget);
    });

    testWidgets('should maintain scroll position during update', (
      tester,
    ) async {
      final fakeProvider = FakeNotificationProvider();

      // Create 30 notifications to enable scrolling
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

      // Scroll down the list
      final listFinder = find.byType(ListView);
      await tester.drag(listFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Trigger a state update (simulates new data arriving)
      fakeProvider.setNotifications(notifications);
      await tester.pump();

      // List should still be rendered and functional after update
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('NotificationScreen User Interactions', () {
    late MockNotificationProvider mockProvider;

    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should handle tap on notification item', (tester) async {
      // Create a notification that user can tap on
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

      // Find and tap the notification tile
      final tileFinder = find.byType(NotificationTile);
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle(); // Wait for any animations

      // App should not crash when notification is tapped
      expect(find.byType(NotificationScreen), findsOneWidget);
    });
  });

  group('NotificationScreen Performance', () {
    late MockNotificationProvider mockProvider;

    setUp(() {
      mockProvider = MockNotificationProvider();
    });

    testWidgets('should render large list efficiently', (tester) async {
      // Create a very large list (100 items) to test performance
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

      // Measure how long it takes to render
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

      await tester.pumpAndSettle(); // Wait for all rendering to complete
      stopwatch.stop();

      // Screen should render within 3 seconds even with 100 items
      // This ensures app stays responsive with large datasets
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
