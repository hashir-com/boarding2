/// Unit tests for NotificationModel and NotificationItem
/// Verifies JSON parsing, serialization, null handling, and data integrity
import 'package:btask/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationModel Tests', () {
    
    // Sample valid JSON data matching the API response structure
    final validJson = {
      'message': 'Success',
      'data': [
        {
          'image': 'https://example.com/image1.jpg',
          'title': 'Test Notification 1',
          'body': 'This is a test notification',
          'timestamp': '2024-11-13T10:30:00Z',
        },
        {
          'image': 'https://example.com/image2.jpg',
          'title': 'Test Notification 2',
          'body': 'Another test notification',
          'timestamp': '2024-11-13T11:45:00Z',
        }
      ]
    };

    test('should parse valid JSON correctly', () {
      final model = NotificationModel.fromJson(validJson);

      expect(model.message, equals('Success'));
      expect(model.data.length, equals(2));
      expect(model.data[0].title, equals('Test Notification 1'));
      expect(model.data[1].body, equals('Another test notification'));
    });

    test('should handle empty data array', () {
      final emptyDataJson = {
        'message': 'No notifications',
        'data': []
      };

      final model = NotificationModel.fromJson(emptyDataJson);

      expect(model.message, equals('No notifications'));
      expect(model.data, isEmpty);
    });

    test('should handle null data array gracefully', () {
      final nullDataJson = {
        'message': 'Success',
        'data': null
      };

      final model = NotificationModel.fromJson(nullDataJson);

      // Should default to empty list instead of throwing error
      expect(model.message, equals('Success'));
      expect(model.data, isEmpty);
    });

    test('should handle missing message field', () {
      final noMessageJson = {
        'data': [
          {
            'image': 'test.jpg',
            'title': 'Test',
            'body': 'Body',
            'timestamp': '2024-11-13T10:00:00Z',
          }
        ]
      };

      final model = NotificationModel.fromJson(noMessageJson);

      // Should default to empty string for missing message
      expect(model.message, equals(''));
      expect(model.data.length, equals(1));
    });

    test('should serialize to JSON correctly', () {
      final model = NotificationModel.fromJson(validJson);
      final jsonOutput = model.toJson();

      expect(jsonOutput['message'], equals('Success'));
      expect(jsonOutput['data'], isList);
      expect((jsonOutput['data'] as List).length, equals(2));
    });

    test('should maintain data integrity after parse and serialize', () {
      final original = NotificationModel.fromJson(validJson);

      // Convert to JSON and back to verify no data loss
      final serialized = original.toJson();
      final reparsed = NotificationModel.fromJson(serialized);

      expect(reparsed.message, equals(original.message));
      expect(reparsed.data.length, equals(original.data.length));
      expect(reparsed.data[0].title, equals(original.data[0].title));
    });
  });

  group('NotificationItem Tests', () {
    
    final validItemJson = {
      'image': 'https://example.com/image.jpg',
      'title': 'Test Title',
      'body': 'Test Body',
      'timestamp': '2024-11-13T10:30:00Z',
    };

    test('should parse valid notification item', () {
      final item = NotificationItem.fromJson(validItemJson);

      expect(item.image, equals('https://example.com/image.jpg'));
      expect(item.title, equals('Test Title'));
      expect(item.body, equals('Test Body'));
      expect(item.timestamp, equals('2024-11-13T10:30:00Z'));
    });

    test('should handle missing fields with empty strings', () {
      final incompleteJson = <String, dynamic>{};
      final item = NotificationItem.fromJson(incompleteJson);

      // All fields should default to empty strings
      expect(item.image, equals(''));
      expect(item.title, equals(''));
      expect(item.body, equals(''));
      expect(item.timestamp, equals(''));
    });

    test('should handle null values in fields', () {
      final nullFieldsJson = {
        'image': null,
        'title': null,
        'body': null,
        'timestamp': null,
      };

      final item = NotificationItem.fromJson(nullFieldsJson);

      // Null values should be converted to empty strings
      expect(item.image, equals(''));
      expect(item.title, equals(''));
      expect(item.body, equals(''));
      expect(item.timestamp, equals(''));
    });

    test('should serialize to JSON correctly', () {
      final item = NotificationItem.fromJson(validItemJson);
      final json = item.toJson();

      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['title'], equals('Test Title'));
      expect(json['body'], equals('Test Body'));
      expect(json['timestamp'], equals('2024-11-13T10:30:00Z'));
    });

    test('should maintain data after parse and serialize', () {
      final original = NotificationItem.fromJson(validItemJson);

      // Test round-trip conversion integrity
      final serialized = original.toJson();
      final reparsed = NotificationItem.fromJson(serialized);

      expect(reparsed.image, equals(original.image));
      expect(reparsed.title, equals(original.title));
      expect(reparsed.body, equals(original.body));
      expect(reparsed.timestamp, equals(original.timestamp));
    });

    test('should handle special characters in strings', () {
      final specialCharsJson = {
        'image': 'path/with spaces/image.jpg',
        'title': 'Title with "quotes" and émojis 🎉',
        'body': 'Body with\nnewlines\tand\ttabs',
        'timestamp': '2024-11-13T10:30:00+05:30',
      };

      final item = NotificationItem.fromJson(specialCharsJson);

      // Verify special characters are preserved correctly
      expect(item.title, contains('quotes'));
      expect(item.title, contains('🎉'));
      expect(item.body, contains('\n'));
    });
  });
}