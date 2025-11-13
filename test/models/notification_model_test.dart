// test/models/notification_model_test.dart

/// Unit tests for NotificationModel and NotificationItem
/// 
/// These tests verify:
/// - JSON parsing (fromJson)
/// - JSON serialization (toJson)
/// - Handling of null/missing fields
/// - Data integrity after parsing

import 'package:btask/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationModel Tests', () {
    
    // Test data
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
      // Arrange & Act
      final model = NotificationModel.fromJson(validJson);

      // Assert
      expect(model.message, equals('Success'));
      expect(model.data.length, equals(2));
      expect(model.data[0].title, equals('Test Notification 1'));
      expect(model.data[1].body, equals('Another test notification'));
    });

    test('should handle empty data array', () {
      // Arrange
      final emptyDataJson = {
        'message': 'No notifications',
        'data': []
      };

      // Act
      final model = NotificationModel.fromJson(emptyDataJson);

      // Assert
      expect(model.message, equals('No notifications'));
      expect(model.data, isEmpty);
    });

    test('should handle null data array gracefully', () {
      // Arrange
      final nullDataJson = {
        'message': 'Success',
        'data': null
      };

      // Act
      final model = NotificationModel.fromJson(nullDataJson);

      // Assert
      expect(model.message, equals('Success'));
      expect(model.data, isEmpty);
    });

    test('should handle missing message field', () {
      // Arrange
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

      // Act
      final model = NotificationModel.fromJson(noMessageJson);

      // Assert
      expect(model.message, equals(''));
      expect(model.data.length, equals(1));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final model = NotificationModel.fromJson(validJson);

      // Act
      final jsonOutput = model.toJson();

      // Assert
      expect(jsonOutput['message'], equals('Success'));
      expect(jsonOutput['data'], isList);
      expect((jsonOutput['data'] as List).length, equals(2));
    });

    test('should maintain data integrity after parse and serialize', () {
      // Arrange
      final original = NotificationModel.fromJson(validJson);

      // Act
      final serialized = original.toJson();
      final reparsed = NotificationModel.fromJson(serialized);

      // Assert
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
      // Act
      final item = NotificationItem.fromJson(validItemJson);

      // Assert
      expect(item.image, equals('https://example.com/image.jpg'));
      expect(item.title, equals('Test Title'));
      expect(item.body, equals('Test Body'));
      expect(item.timestamp, equals('2024-11-13T10:30:00Z'));
    });

    test('should handle missing fields with empty strings', () {
      // Arrange
      final incompleteJson = <String, dynamic>{};

      // Act
      final item = NotificationItem.fromJson(incompleteJson);

      // Assert
      expect(item.image, equals(''));
      expect(item.title, equals(''));
      expect(item.body, equals(''));
      expect(item.timestamp, equals(''));
    });

    test('should handle null values in fields', () {
      // Arrange
      final nullFieldsJson = {
        'image': null,
        'title': null,
        'body': null,
        'timestamp': null,
      };

      // Act
      final item = NotificationItem.fromJson(nullFieldsJson);

      // Assert
      expect(item.image, equals(''));
      expect(item.title, equals(''));
      expect(item.body, equals(''));
      expect(item.timestamp, equals(''));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final item = NotificationItem.fromJson(validItemJson);

      // Act
      final json = item.toJson();

      // Assert
      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['title'], equals('Test Title'));
      expect(json['body'], equals('Test Body'));
      expect(json['timestamp'], equals('2024-11-13T10:30:00Z'));
    });

    test('should maintain data after parse and serialize', () {
      // Arrange
      final original = NotificationItem.fromJson(validItemJson);

      // Act
      final serialized = original.toJson();
      final reparsed = NotificationItem.fromJson(serialized);

      // Assert
      expect(reparsed.image, equals(original.image));
      expect(reparsed.title, equals(original.title));
      expect(reparsed.body, equals(original.body));
      expect(reparsed.timestamp, equals(original.timestamp));
    });

    test('should handle special characters in strings', () {
      // Arrange
      final specialCharsJson = {
        'image': 'path/with spaces/image.jpg',
        'title': 'Title with "quotes" and émojis 🎉',
        'body': 'Body with\nnewlines\tand\ttabs',
        'timestamp': '2024-11-13T10:30:00+05:30',
      };

      // Act
      final item = NotificationItem.fromJson(specialCharsJson);

      // Assert
      expect(item.title, contains('quotes'));
      expect(item.title, contains('🎉'));
      expect(item.body, contains('\n'));
    });
  });
}