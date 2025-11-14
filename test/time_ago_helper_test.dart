// TimeAgoFormatter Tests

// Tests for TimeAgoFormatter utility class
//
// This helper converts timestamps into human-readable relative time strings.
// Examples: "Just now", "5 mins ago", "3 hours ago", "1 day ago"
//
// Why relative time?
// - More intuitive than exact timestamps
// - Users care more about "how long ago" than exact time
// - Common pattern in social apps, notifications, chat apps

import 'package:btask/screens/notifications/time_ago_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeAgoFormatter Tests', () {
    test('Returns "Just now" for timestamps less than 1 minute old', () {
      final now = DateTime.now();
      // Subtract 30 seconds from current time
      final timestamp = now.subtract(Duration(seconds: 30)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      // Very recent notifications should say "Just now"
      expect(result, 'Just now');
    });

    test('Returns minutes ago for timestamps less than 1 hour old', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(minutes: 5)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      expect(result, '5 mins ago');
    });

    test('Returns singular "min" for 1 minute', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(minutes: 1)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      // Proper grammar: "1 min ago" not "1 mins ago"
      expect(result, '1 min ago');
    });

    test('Returns hours ago for timestamps less than 24 hours old', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(hours: 3)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      expect(result, '3 hours ago');
    });

    test('Returns singular "hour" for 1 hour', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(hours: 1)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      // Proper grammar: "1 hour ago" not "1 hours ago"
      expect(result, '1 hour ago');
    });

    test('Returns "1 day ago" for timestamps less than 2 days old', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(days: 1)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      expect(result, '1 day ago');
    });

    test('Returns null for timestamps 2 days or older', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(days: 2)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      // For old notifications, show exact date instead of relative time
      expect(result, null);
    });

    test('Returns null for timestamps older than 2 days', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(days: 10)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgo(timestamp);

      expect(result, null);
    });

    test('Handles invalid timestamp gracefully', () {
      const invalidTimestamp = 'invalid-timestamp';

      final result = TimeAgoFormatter.formatTimeAgo(invalidTimestamp);

      // Should not crash on bad data, just return null
      expect(result, null);
    });

    test('formatTimeAgoOrDate shows date for old timestamps', () {
      // This is a timestamp from January 2023 (old)
      final timestamp = '2023-01-10T11:06:54.754';

      final result = TimeAgoFormatter.formatTimeAgoOrDate(timestamp);

      // Old notifications show exact date for reference
      expect(result, '2023-01-10');
    });

    test('formatTimeAgoOrDate shows relative time for recent timestamps', () {
      final now = DateTime.now();
      final timestamp = now.subtract(Duration(minutes: 30)).toIso8601String();

      final result = TimeAgoFormatter.formatTimeAgoOrDate(timestamp);

      // Recent notifications show relative time (more intuitive)
      expect(result, '30 mins ago');
    });
  });
}
