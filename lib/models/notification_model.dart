/// Model class for the notification API response
/// Contains a message and a list of notification items
class NotificationModel {
  final String message;
  final List<NotificationItem> data;

  NotificationModel({required this.message, required this.data});

  /// Creates a NotificationModel instance from JSON
  /// Safely handles null values with default empty values
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => NotificationItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  /// Converts the model back to JSON format
  /// Useful for caching or sending data back to the API
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model class representing a single notification item
/// Contains all details needed to display a notification in the UI
class NotificationItem {
  final String image;
  final String title;
  final String body;
  final String timestamp;

  NotificationItem({
    required this.image,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  /// Creates a NotificationItem from JSON response
  /// Maps API field names to model properties with null safety
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  /// Converts the notification item to JSON format
  /// Maintains consistency with API field naming
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }
}