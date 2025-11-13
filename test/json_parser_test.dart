import 'package:flutter_test/flutter_test.dart';
import 'package:btask/services/json_parser.dart';
import 'package:btask/models/notification_model.dart';

void main() {
  group('JsonParser Tests', () {
    test('Parse valid JSON successfully', () async {
      // Arrange
      const jsonString = '''
      {
        "message": "Notification listed successfully",
        "data": [
          {
            "image": "order_assigned.png",
            "title": "Your order has been assigned",
            "body": "Your order containing 2 items will be delivered",
            "timestamp": "2023-01-11T11:06:54.754"
          }
        ]
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(jsonString);

      // Assert
      expect(result, isA<NotificationModel>());
      expect(result.message, 'Notification listed successfully');
      expect(result.data.length, 1);
      expect(result.data[0].title, 'Your order has been assigned');
      expect(
        result.data[0].body,
        'Your order containing 2 items will be delivered',
      );
    });

    test('Parse empty data array', () async {
      // Arrange
      const jsonString = '''
      {
        "message": "No notifications",
        "data": []
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(jsonString);

      // Assert
      expect(result.data.isEmpty, true);
      expect(result.message, 'No notifications');
    });

    test('Handle invalid JSON', () async {
      // Arrange
      const jsonString = 'invalid json string';

      // Act & Assert
      expect(
        () => JsonParser.parseNotificationJson(jsonString),
        throwsA(isA<Exception>()),
      );
    });

    test('Parse multiple notifications', () async {
      // Arrange
      const jsonString = '''
      {
        "message": "Success",
        "data": [
          {
            "image": "test1.png",
            "title": "Title 1",
            "body": "Body 1",
            "timestamp": "2023-01-11T11:06:54.754"
          },
          {
            "image": "test2.png",
            "title": "Title 2",
            "body": "Body 2",
            "timestamp": "2023-01-12T11:06:54.754"
          }
        ]
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(jsonString);

      // Assert
      expect(result.data.length, 2);
      expect(result.data[0].title, 'Title 1');
      expect(result.data[1].title, 'Title 2');
    });

    test('Handle missing optional fields with defaults', () async {
      // Arrange
      const jsonString = '''
      {
        "message": "Success",
        "data": [
          {
            "image": "",
            "title": "",
            "body": "",
            "timestamp": ""
          }
        ]
      }
      ''';

      // Act
      final result = await JsonParser.parseNotificationJson(jsonString);

      // Assert
      expect(result.data.length, 1);
      expect(result.data[0].image, '');
      expect(result.data[0].title, '');
    });
  });

  group('NotificationItem Model Tests', () {
    test('fromJson creates valid NotificationItem', () {
      // Arrange
      final json = {
        'image': 'test.png',
        'title': 'Test Title',
        'body': 'Test Body',
        'timestamp': '2023-01-11T11:06:54.754',
      };

      // Act
      final item = NotificationItem.fromJson(json);

      // Assert
      expect(item.image, 'test.png');
      expect(item.title, 'Test Title');
      expect(item.body, 'Test Body');
      expect(item.timestamp, '2023-01-11T11:06:54.754');
    });

    test('toJson converts NotificationItem to Map', () {
      // Arrange
      final item = NotificationItem(
        image: 'test.png',
        title: 'Test Title',
        body: 'Test Body',
        timestamp: '2023-01-11T11:06:54.754',
      );

      // Act
      final json = item.toJson();

      // Assert
      expect(json['image'], 'test.png');
      expect(json['title'], 'Test Title');
      expect(json['body'], 'Test Body');
      expect(json['timestamp'], '2023-01-11T11:06:54.754');
    });
  });
}
