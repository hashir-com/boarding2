import 'dart:convert';
import 'dart:isolate';
import 'package:btask/models/notification_model.dart';

/// Service class for parsing JSON data using isolates
class JsonParser {
  /// Parse notification JSON data in a separate isolate
  /// This prevents UI blocking when parsing large JSON responses
  static Future<NotificationModel> parseNotificationJson(String jsonString) async {
    // Create a ReceivePort to get messages from the isolate
    final receivePort = ReceivePort();

    // Spawn an isolate and pass the parsing function and data
    await Isolate.spawn(
      _parseNotificationInIsolate,
      _IsolateData(
        sendPort: receivePort.sendPort,
        jsonString: jsonString,
      ),
    );

    // Wait for the result from the isolate
    final result = await receivePort.first;

    // Handle errors from the isolate
    if (result is Exception) {
      throw result;
    }

    return result as NotificationModel;
  }

  /// The function that runs in the isolate
  /// This performs the actual JSON parsing
  static void _parseNotificationInIsolate(_IsolateData data) {
    try {
      // Parse JSON string to Map
      final jsonData = json.decode(data.jsonString) as Map<String, dynamic>;
      
      // Convert Map to NotificationModel
      final notificationModel = NotificationModel.fromJson(jsonData);
      
      // Send the result back to the main isolate
      data.sendPort.send(notificationModel);
    } catch (e) {
      // Send error back to the main isolate
      data.sendPort.send(Exception('Failed to parse JSON in isolate: $e'));
    }
  }
}

/// Helper class to pass data to the isolate
/// Isolates can only receive one argument, so we bundle everything together
class _IsolateData {
  final SendPort sendPort;
  final String jsonString;

  _IsolateData({
    required this.sendPort,
    required this.jsonString,
  });
}