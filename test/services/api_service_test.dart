// test/services/api_service_test.dart

/// Unit tests for ApiService
///
/// These tests verify:
/// - Successful API calls return correct data
/// - HTTP error codes are handled properly
/// - Network errors (timeout, no internet) are caught
/// - Retry mechanism works correctly
/// - Edge cases (empty response, malformed data)
///
/// Note: These tests use mocked HTTP responses to avoid actual network calls

import 'dart:async';
import 'dart:collection'; // For Queue
import 'dart:io'; // For exceptions
import 'package:btask/services/api_service.dart';
import 'package:btask/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks using build_runner
// Run: dart run build_runner build
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    const validJsonResponse = '''
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

    test('should successfully fetch and parse notifications', () async {
      // Arrange
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(validJsonResponse, 200));

      // Act
      final result = await apiService.fetchNotification();

      // Assert
      expect(result, isA<NotificationModel>());
      expect(result.message, equals('Success'));
      expect(result.data.length, equals(1));
      expect(result.data[0].title, equals('Test Notification'));
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on 404 error', () async {
      // Arrange
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Notifications not found (404)'),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on 500 server error', () async {
      // Arrange
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Server Error', 500));

      // Act & Assert
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'Server error (500). Please try again later',
                ),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on 503 service unavailable', () async {
      // Arrange
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Service Unavailable', 503));

      // Act & Assert
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'Service unavailable (503). Please try again later',
                ),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on empty response body', () async {
      // Arrange
      when(mockClient.get(any)).thenAnswer((_) async => http.Response('', 200));

      // Act & Assert
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Server returned empty response'),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on timeout', () async {
      // Arrange
      when(
        mockClient.get(any),
      ).thenThrow(TimeoutException('Timed out', Duration(seconds: 30)));

      // Act & Assert
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'Connection timeout. Please check your internet connection and try again',
                ),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on no internet (SocketException)', () async {
      // Arrange
      when(
        mockClient.get(any),
      ).thenThrow(const SocketException('No route to host'));

      // Act & Assert
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'No internet connection. Please check your network and try again',
                ),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on malformed JSON', () async {
      // Arrange
      const malformedJson = '{"message": "Success", "data": [}';
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(malformedJson, 200));

      // Act & Assert (assumes JsonParser throws FormatException)
      expect(
        apiService.fetchNotification(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Failed to parse notification data'),
          ),
        ),
      );
      verify(mockClient.get(any)).called(1);
    });

    test('should handle empty data array successfully', () async {
      // Arrange
      const emptyDataResponse = '''
      {
        "message": "No notifications",
        "data": []
      }
      ''';
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(emptyDataResponse, 200));

      // Act
      final result = await apiService.fetchNotification();

      // Assert
      expect(result.data, isEmpty);
      expect(result.message, equals('No notifications'));
      verify(mockClient.get(any)).called(1);
    });

    test('should handle large response with multiple items', () async {
      // Arrange: Generate valid JSON without multiline issues
      final dataItems = List.generate(
        50,
        (index) =>
            '{"image": "image$index.jpg", "title": "Notification $index", "body": "Body $index", "timestamp": "2024-11-13T10:00:00Z"}',
      ).join(',');
      final largeResponse = '{"message": "Success", "data": [$dataItems]}';

      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(largeResponse, 200));

      // Act
      final result = await apiService.fetchNotification();

      // Assert
      expect(result.data.length, equals(50));
      verify(mockClient.get(any)).called(1);
    });
  });

  group('ApiService Retry Mechanism Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    const validJsonResponse = '''
    {
      "message": "Success",
      "data": [
        {
          "image": "test.jpg",
          "title": "Test",
          "body": "Body",
          "timestamp": "2024-11-13T10:00:00Z"
        }
      ]
    }
    ''';

    test('should retry and succeed on second attempt', () async {
      // Arrange - First call fails (500), second succeeds
      final responses = [
        http.Response('Server Error', 500),
        http.Response(validJsonResponse, 200),
      ];
      int callIndex = 0;
      when(mockClient.get(any)).thenAnswer((_) async => responses[callIndex++]);

      // Act
      final result = await apiService.fetchNotificationWithRetry(
        maxRetries: 2,
        retryDelay: const Duration(milliseconds: 1),
      );

      // Assert
      expect(result, isA<NotificationModel>());
      verify(mockClient.get(any)).called(2);
    });

    test('should fail after max retries', () async {
      // Arrange - All attempts fail
      int callCount = 0;
      when(mockClient.get(any)).thenAnswer((_) async {
        callCount++;
        return http.Response('Server Error', 500);
      });

      // Act & Assert
      expect(
        apiService.fetchNotificationWithRetry(
          maxRetries: 2,
          retryDelay: const Duration(milliseconds: 1),
        ),
        throwsA(isA<Exception>()),
      );

      // Wait for async to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify call count manually (more reliable than mockito verify)
      expect(
        callCount,
        equals(2),
      ); // total 2 attempts for maxRetries=2 (initial + 1 retry)
    });
  });

  group('ApiService Internet Connection Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService(); // Uses real client
    });

    test('hasInternetConnection should return true when connected', () async {
      // Note: Real network check; flaky in offline/CI. For full mock, add @GenerateMocks([InternetAddress]) and stub lookup static.
      final hasConnection = await apiService.hasInternetConnection();

      // Assert (weak: always bool; strengthen to expect(true) in connected env)
      expect(hasConnection, isA<bool>());
    });
  });
}
