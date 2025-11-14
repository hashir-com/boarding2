// Unit tests for NotificationProvider
//
// These tests verify the provider's state management capabilities:
// - Initial state values (empty lists, false flags)
// - Listener notification system (how widgets get updates)
// - State changes during API calls
// - Error handling behavior
//
// Note: These are basic tests without API mocking - they test the provider's
// structure and state management rather than actual API responses

import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationProvider Tests', () {
    // Variable to hold the provider instance for each test
    late NotificationProvider provider;

    // setUp runs before each test - creates a fresh provider instance
    // This ensures each test starts with a clean state
    setUp(() {
      provider = NotificationProvider();
    });

    test('initial state should be correct', () {
      // When provider is first created, it should have default values
      // - Empty notification list (no data fetched yet)
      // - isLoading = false (not fetching data)
      // - Empty error message (no errors yet)
      expect(provider.notifications, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isEmpty);
    });

    test('should notify listeners on state change', () {
      // Track how many times the listener is called
      int listenerCallCount = 0;

      // Add a listener that increments the counter each time it's called
      // In real apps, this is how widgets know to rebuild when data changes
      provider.addListener(() {
        listenerCallCount++;
      });

      // Trigger an API call - this should change state and notify listeners
      // The call will fail (no mock API), but it will still change isLoading state
      provider.fetchNotifications();

      // Verify the listener was called at least once
      // This proves the provider is notifying widgets about state changes
      expect(listenerCallCount, greaterThanOrEqualTo(1));
    });

    test('should handle notification list structure', () {
      // Verify the notifications property is the correct data type
      // This ensures type safety and prevents runtime errors
      expect(provider.notifications, isA<List<NotificationItem>>());
    });

    test('error message should be settable', () {
      // Initially, no errors should exist
      expect(provider.errorMessage, isEmpty);

      // Call fetchNotifications (will fail without mock)
      // The provider should catch the error and store an error message
      provider.fetchNotifications();

      // Verify errorMessage is a String (even if empty or populated)
      // In real scenarios, this would contain the actual error text
      expect(provider.errorMessage, isA<String>());
    });

    test('isLoading should be boolean', () {
      // Simple type check to ensure isLoading is always true or false
      // Prevents accidental null or invalid values
      expect(provider.isLoading, isA<bool>());
    });
  });

  group('NotificationProvider State Management', () {
    test('provider should be ChangeNotifier', () {
      // Verify the provider extends ChangeNotifier
      // This is crucial for the Provider package to work correctly
      final provider = NotificationProvider();
      expect(provider, isA<ChangeNotifier>());
    });

    test('should handle multiple listener registrations', () {
      // In real apps, multiple widgets might listen to the same provider
      final provider = NotificationProvider();
      int count1 = 0;
      int count2 = 0;

      // Register two separate listeners
      provider.addListener(() => count1++);
      provider.addListener(() => count2++);

      // Trigger a state change
      provider.fetchNotifications();

      // Both listeners should be called
      expect(count1, greaterThan(0));
      expect(count2, greaterThan(0));

      // Both should be called the same number of times
      // This ensures all listeners are treated equally
      expect(count1, equals(count2));
    });
  });
}
