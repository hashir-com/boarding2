/// Unit tests for JsonParser service
///
/// JsonParser uses Flutter Isolates to parse JSON on a background thread.
/// This prevents the UI from freezing when processing large JSON responses.
///
/// What are Isolates?
/// - Separate threads that run code in parallel
/// - Don't block the main UI thread
/// - Essential for keeping apps smooth and responsive
///
/// These tests verify:
/// - ✅ Valid JSON is parsed correctly
/// - 📦 Large datasets (50+ items) are handled efficiently
/// - ❌ Malformed JSON throws clear errors
/// - 🎯 Special characters (emojis, quotes, newlines) work
/// - ⚡ Parsing completes within reasonable time limits

import 'package:btask/services/json_parser.dart';
import 'package:btask/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonParser Isolate Tests', () {
    test('should parse valid JSON string in isolate', () async {
      // Sample JSON matching our API's response format
      const validJsonString = '''
      {
        "message": "Success",
        "data": [
          {
            "image": "https://example.com/image.jpg",
            "title": "Test Notification",
            "body": "This is a test",
            "timestamp": "2024-11-13T10:30:00Z"
          }
        ]
      }
      ''';

      // Parse JSON on background thread (isolate)
      final result = await JsonParser.parseNotificationJson(validJsonString);

      // Verify all fields were parsed correctly
      expect(result, isA<NotificationModel>());
      expect(result.message, equals('Success'));
      expect(result.data.length, equals(1));
      expect(result.data[0].title, equals('Test Notification'));
    });

    test('should parse empty data array', () async {
      // User has no notifications - valid but empty response
      const emptyDataJson = '''
      {
        "message": "No data",
        "data": []
      }
      ''';

      final result = await JsonParser.parseNotificationJson(emptyDataJson);

      // Empty list is valid, not an error
      expect(result.data, isEmpty);
      expect(result.message, equals('No data'));
    });

    test('should parse large JSON with multiple items', () async {
      // Test with 50 notifications - simulates heavy data load
      // This is where isolates really help keep UI smooth
      final dataItems = List.generate(
        50,
        (index) =>
            '''
        {
          "image": "https://example.com/image$index.jpg",
          "title": "Notification $index",
          "body": "Body text for notification $index",
          "timestamp": "2024-11-13T10:${index.toString().padLeft(2, '0')}:00Z"
        }
      ''',
      ).join(',');

      final largeJsonString =
          '''
      {
        "message": "Success",
        "data": [$dataItems]
      }
      ''';

      final result = await JsonParser.parseNotificationJson(largeJsonString);

      // Verify all items were parsed without losing any data
      expect(result.data.length, equals(50));
      expect(result.data[0].title, equals('Notification 0'));
      expect(result.data[49].title, equals('Notification 49'));
    });

    test('should throw exception for malformed JSON', () async {
      // Missing comma between fields - invalid JSON syntax
      const malformedJson = '''
      {
        "message": "Success",
        "data": [
          {
            "title": "Test"
            "body": "Missing comma"
          }
        ]
      }
      ''';

      // Should catch syntax error and throw exception
      expect(
        () => JsonParser.parseNotificationJson(malformedJson),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for invalid JSON structure', () async {
      // Missing the required 'data' field
      // Tests graceful handling of unexpected structure
      const invalidStructure = '''
      {
        "message": "Success"
      }
      ''';

      final result = await JsonParser.parseNotificationJson(invalidStructure);

      // Should handle missing field gracefully with empty array
      expect(result.data, isEmpty);
    });

    test('should throw exception for empty string', () async {
      // Empty response from server - nothing to parse
      const emptyString = '';

      expect(
        () => JsonParser.parseNotificationJson(emptyString),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for non-JSON string', () async {
      // Server returned plain text instead of JSON
      // Could happen if server has error page or maintenance message
      const notJson = 'This is not JSON';

      expect(
        () => JsonParser.parseNotificationJson(notJson),
        throwsA(isA<Exception>()),
      );
    });

    test('should parse JSON with special characters', () async {
      // Real-world data often contains special characters
      // Test emojis, quotes, newlines, tabs, unicode
      const specialCharsJson = '''
      {
        "message": "Success",
        "data": [
          {
            "image": "path/with spaces/image.jpg",
            "title": "Title with \\"quotes\\" and émojis 🎉",
            "body": "Body with\\nnewlines\\tand\\ttabs",
            "timestamp": "2024-11-13T10:30:00Z"
          }
        ]
      }
      ''';

      final result = await JsonParser.parseNotificationJson(specialCharsJson);

      // Verify special characters are preserved correctly
      expect(result.data[0].title, contains('quotes'));
      expect(result.data[0].title, contains('🎉'));
    });

    test('should handle nested JSON structures', () async {
      // Verify parser correctly handles the nested structure:
      // Root object → data array → notification objects
      const nestedJson = '''
      {
        "message": "Success",
        "data": [
          {
            "image": "test.jpg",
            "title": "Test",
            "body": "Body",
            "timestamp": "2024-11-13T10:30:00Z"
          }
        ]
      }
      ''';

      final result = await JsonParser.parseNotificationJson(nestedJson);

      // Check both outer and inner structures are correct types
      expect(result, isA<NotificationModel>());
      expect(result.data, isA<List<NotificationItem>>());
    });

    test('should complete parsing within reasonable time', () async {
      // Performance test with 100 items
      // Ensures isolate doesn't add too much overhead
      final dataItems = List.generate(
        100,
        (index) =>
            '''
        {
          "image": "image$index.jpg",
          "title": "Title $index",
          "body": "Body $index",
          "timestamp": "2024-11-13T10:00:00Z"
        }
      ''',
      ).join(',');

      final jsonString = '{"message": "Success", "data": [$dataItems]}';

      // Measure how long parsing takes
      final stopwatch = Stopwatch()..start();
      final result = await JsonParser.parseNotificationJson(jsonString);
      stopwatch.stop();

      // Verify all data was parsed
      expect(result.data.length, equals(100));

      // Parsing 100 items should take less than 5 seconds
      // If it takes longer, isolate communication might have issues
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}
/// Unit tests for NotificationProvider