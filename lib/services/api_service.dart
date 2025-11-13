import 'dart:io';
import 'dart:async';

import 'package:btask/models/notification_model.dart';
import 'package:btask/services/json_parser.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl =
      "https://raw.githubusercontent.com/sayanp23/test-api/main/test-notifications.json";

  // Timeout duration for API calls
  static const Duration timeoutDuration = Duration(seconds: 30);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch notifications from API and parse using isolate
  Future<NotificationModel> fetchNotification() async {
    try {
      // Make HTTP GET request with timeout
      final response = await _client
          .get(Uri.parse(apiUrl))
          .timeout(timeoutDuration);

      // Check for successful response
      if (response.statusCode == 200) {
        // Check if response body is not empty
        if (response.body.isEmpty) {
          throw Exception('Server returned empty response');
        }

        try {
          // Parse JSON data using isolate for better performance
          // This prevents blocking the UI thread with heavy JSON parsing
          return await JsonParser.parseNotificationJson(response.body);
        } catch (e) {
          // Parsing error from isolate
          throw Exception('Failed to parse notification data: $e');
        }
      }
      // Handle different HTTP status codes
      else if (response.statusCode == 404) {
        throw Exception('Notifications not found (404)');
      } else if (response.statusCode == 500) {
        throw Exception('Server error (500). Please try again later');
      } else if (response.statusCode == 503) {
        throw Exception('Service unavailable (503). Please try again later');
      } else {
        throw Exception(
          'Failed to load notifications. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      // No internet connection
      throw Exception(
        'No internet connection. Please check your network and try again',
      );
    } on TimeoutException {
      // Request timeout
      throw Exception(
        'Connection timeout. Please check your internet connection and try again',
      );
    } on HttpException {
      // HTTP error
      throw Exception('Could not connect to the server. Please try again');
    } on FormatException catch (e) {
      // URL or format error
      throw Exception('Bad request format: ${e.message}');
    } catch (e) {
      // Any other unexpected error
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Optional: Method to check internet connectivity before making request
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Optional: Retry mechanism for failed requests
  /// maxRetries = total number of attempts (including the initial one)
  Future<NotificationModel> fetchNotificationWithRetry({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    Exception? lastException;

    // Try maxRetries times (including initial attempt)
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await fetchNotification();
      } catch (e) {
        lastException = e as Exception;
        
        // If this was the last attempt, throw the error
        if (attempt >= maxRetries) {
          rethrow;
        }
        
        // Wait before next retry (but not after the last attempt)
        await Future.delayed(retryDelay);
      }
    }

    // This should never be reached, but just in case
    throw lastException ?? Exception('Failed after $maxRetries attempts');
  }
}