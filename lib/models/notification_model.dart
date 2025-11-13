class NotificationModel {
  final String message;
  final List<NotificationItem> data;

  NotificationModel({required this.message, required this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => NotificationItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

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

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '', // API uses 'body', not 'description'
      timestamp: json['timestamp'] ?? '', // API uses 'timestamp', not 'time'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'body': body, // Convert back to API format
      'timestamp': timestamp, // Convert back to API format
    };
  }
}