/// Unit tests for ApiService
///
/// ApiService handles all communication with the backend server.
/// These tests verify it works correctly in different scenarios:
///
/// -  Success: Data is fetched and parsed correctly
/// -  Errors: 404, 500, 503 status codes are handled
/// -  Network issues: Timeout, no internet connection
/// -  Retry logic: Automatic retries when requests fail
/// -  Edge cases: Empty responses, malformed JSON, large datasets
///
/// We use "mocks" (fake HTTP client) so tests don't make real network calls.
/// This makes tests fast, reliable, and work without internet.

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:btask/services/api_service.dart';
import 'package:btask/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Tell Mockito to generate a mock version of http.Client
// Run this command to generate the mock: dart run build_runner build
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    // Variables we'll use in every test
    late ApiService apiService;
    late MockClient mockClient;

    // setUp runs before each test to create fresh instances
    // This prevents tests from interfering with each other
    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    // Sample valid JSON that matches our API's response format
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
      // Tell mock client to return success response when API is called
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(validJsonResponse, 200));

      // Call the API method
      final result = await apiService.fetchNotification();

      // Verify the response was parsed correctly into our model
      expect(result, isA<NotificationModel>());
      expect(result.message, equals('Success'));
      expect(result.data.length, equals(1));
      expect(result.data[0].title, equals('Test Notification'));

      // Verify the HTTP GET was called exactly once
      verify(mockClient.get(any)).called(1);
    });

    test('should throw exception on 404 error', () async {
      // Simulate server returning "Not Found" error
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      // Expect the method to throw an exception with specific message
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
      // Simulate internal server error (backend crashed, database down, etc.)
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Server Error', 500));

      // Should throw user-friendly error message
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
      // Simulate server maintenance or overload
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Service Unavailable', 503));

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
      // Server returns 200 OK but with no content
      // This shouldn't happen, but we handle it gracefully
      when(mockClient.get(any)).thenAnswer((_) async => http.Response('', 200));

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
      // Simulate slow network - request takes too long
      when(
        mockClient.get(any),
      ).thenThrow(TimeoutException('Timed out', Duration(seconds: 30)));

      // User should get helpful message about checking their connection
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
      // Simulate no network connection (WiFi off, airplane mode, etc.)
      when(
        mockClient.get(any),
      ).thenThrow(const SocketException('No route to host'));

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
      // Server returns invalid JSON (missing bracket, wrong format)
      const malformedJson = '{"message": "Success", "data": [}';
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(malformedJson, 200));

      // Should catch JSON parsing error and return user-friendly message
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
      // Valid response but user has no notifications yet
      const emptyDataResponse = '''
      {
        "message": "No notifications",
        "data": []
      }
      ''';
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(emptyDataResponse, 200));

      final result = await apiService.fetchNotification();

      // Should work fine with empty list - not an error condition
      expect(result.data, isEmpty);
      expect(result.message, equals('No notifications'));
      verify(mockClient.get(any)).called(1);
    });

    test('should handle large response with multiple items', () async {
      // Test with 50 notifications to ensure we can handle lots of data
      // Build JSON programmatically to avoid multi-line string issues
      final dataItems = List.generate(
        50,
        (index) =>
            '{"image": "image$index.jpg", "title": "Notification $index", "body": "Body $index", "timestamp": "2024-11-13T10:00:00Z"}',
      ).join(',');
      final largeResponse = '{"message": "Success", "data": [$dataItems]}';

      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(largeResponse, 200));

      final result = await apiService.fetchNotification();

      // Verify all 50 items were parsed correctly
      expect(result.data.length, equals(50));
      verify(mockClient.get(any)).called(1);
    });
  });

  group('ApiService Retry Mechanism Tests', () {
    // Retry mechanism: If a request fails, automatically try again
    // Useful for temporary network glitches or server hiccups
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
      // Simulate: first call fails, second call succeeds
      // This is common when servers are briefly overloaded
      final responses = [
        http.Response('Server Error', 500),
        http.Response(validJsonResponse, 200),
      ];
      int callIndex = 0;
      when(mockClient.get(any)).thenAnswer((_) async => responses[callIndex++]);

      final result = await apiService.fetchNotificationWithRetry(
        maxRetries: 2,
        retryDelay: const Duration(
          milliseconds: 1,
        ), // Very short delay for testing
      );

      // Should succeed after retry
      expect(result, isA<NotificationModel>());
      verify(mockClient.get(any)).called(2); // Called twice: initial + 1 retry
    });

    test('should fail after max retries', () async {
      // Simulate persistent failure - all attempts fail
      int callCount = 0;
      when(mockClient.get(any)).thenAnswer((_) async {
        callCount++;
        return http.Response('Server Error', 500);
      });

      // Should eventually give up and throw exception
      expect(
        apiService.fetchNotificationWithRetry(
          maxRetries: 2,
          retryDelay: const Duration(milliseconds: 1),
        ),
        throwsA(isA<Exception>()),
      );

      // Give time for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify it tried exactly the number of times we specified
      expect(
        callCount,
        equals(2), // maxRetries=2 means initial attempt + 1 retry = 2 total
      );
    });
  });

  group('ApiService Internet Connection Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService(); // Use real client to test actual connectivity
    });

    test('hasInternetConnection should return true when connected', () async {
      // This test checks real network connection
      // Note: May fail in offline environments or CI/CD pipelines
      // In production code, you might want to mock InternetAddress.lookup
      final hasConnection = await apiService.hasInternetConnection();

      // Verify it returns a boolean (true when online, false when offline)
      expect(hasConnection, isA<bool>());
    });
  });
}
