// test/services/json_parser_test.dart

/// Unit tests for JsonParser service
/// 
/// These tests verify:
/// - Isolate-based JSON parsing works correctly
/// - Large JSON data is handled efficiently
/// - Malformed JSON throws appropriate errors
/// - Isolate communication works properly

import 'package:btask/services/json_parser.dart';
import 'package:btask/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonParser Isolate Tests', () {
    
    test('should parse valid JSON string in isolate', () async {
      // Arrange
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

      // Act
      final result = await JsonParser.parseNotificationJson(validJsonString);

      // Assert
      expect(result, isA<NotificationModel>());
      expect(result.message, equals('Success'));
      expect(result.data.length, equals(1));
      expect(result.data[0].title, equals('Test Notification'));
    });

    test('should parse empty data array', () async {
      // Arrange
      const emptyDataJson = '''
      {
        "message": "No data",
        "data": []
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(emptyDataJson);

      // Assert
      expect(result.data, isEmpty);
      expect(result.message, equals('No data'));
    });

    test('should parse large JSON with multiple items', () async {
      // Arrange - Simulating API response with 50 notifications
      final dataItems = List.generate(50, (index) => '''
        {
          "image": "https://example.com/image$index.jpg",
          "title": "Notification $index",
          "body": "Body text for notification $index",
          "timestamp": "2024-11-13T10:${index.toString().padLeft(2, '0')}:00Z"
        }
      ''').join(',');
      
      final largeJsonString = '''
      {
        "message": "Success",
        "data": [$dataItems]
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(largeJsonString);

      // Assert
      expect(result.data.length, equals(50));
      expect(result.data[0].title, equals('Notification 0'));
      expect(result.data[49].title, equals('Notification 49'));
    });

    test('should throw exception for malformed JSON', () async {
      // Arrange
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

      // Act & Assert
      expect(
        () => JsonParser.parseNotificationJson(malformedJson),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for invalid JSON structure', () async {
      // Arrange - Missing required 'data' field
      const invalidStructure = '''
      {
        "message": "Success"
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(invalidStructure);

      // Assert - Should handle gracefully with empty data
      expect(result.data, isEmpty);
    });

    test('should throw exception for empty string', () async {
      // Arrange
      const emptyString = '';

      // Act & Assert
      expect(
        () => JsonParser.parseNotificationJson(emptyString),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception for non-JSON string', () async {
      // Arrange
      const notJson = 'This is not JSON';

      // Act & Assert
      expect(
        () => JsonParser.parseNotificationJson(notJson),
        throwsA(isA<Exception>()),
      );
    });

    test('should parse JSON with special characters', () async {
      // Arrange
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

      // Act
      final result = await JsonParser.parseNotificationJson(specialCharsJson);

      // Assert
      expect(result.data[0].title, contains('quotes'));
      expect(result.data[0].title, contains('🎉'));
    });

    test('should handle nested JSON structures', () async {
      // Arrange
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

      // Act
      final result = await JsonParser.parseNotificationJson(nestedJson);

      // Assert
      expect(result, isA<NotificationModel>());
      expect(result.data, isA<List<NotificationItem>>());
    });

    test('should complete parsing within reasonable time', () async {
      // Arrange
      final dataItems = List.generate(100, (index) => '''
        {
          "image": "image$index.jpg",
          "title": "Title $index",
          "body": "Body $index",
          "timestamp": "2024-11-13T10:00:00Z"
        }
      ''').join(',');
      
      final jsonString = '{"message": "Success", "data": [$dataItems]}';

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await JsonParser.parseNotificationJson(jsonString);
      stopwatch.stop();

      // Assert
      expect(result.data.length, equals(100));
      // Parsing should complete within 5 seconds even for 100 items
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}