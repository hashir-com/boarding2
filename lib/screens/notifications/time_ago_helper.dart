/// Helper class to format timestamps as "time ago" strings
class TimeAgoFormatter {
  /// Converts a timestamp string to a relative time format
  /// Returns null if the notification is older than 2 days (to hide the date)
  /// Examples: "Just now", "5 mins ago", "2 hours ago", "1 day ago"
  static String? formatTimeAgo(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // If older than 2 days, return null (don't show date)
      if (difference.inDays >= 2) {
        return null;
      }

      // Less than 1 minute
      if (difference.inSeconds < 60) {
        return 'Just now';
      }

      // Less than 1 hour
      if (difference.inMinutes < 60) {
        final mins = difference.inMinutes;
        return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
      }

      // Less than 24 hours
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      }

      // Less than 2 days (1 day)
      if (difference.inDays < 2) {
        return '1 day ago';
      }

      return null;
    } catch (e) {
      // If parsing fails, don't show the date
      return null;
    }
  }

  /// Alternative method that always shows the date for older notifications
  ///  to show actual dates for notifications older than 2 days
  static String formatTimeAgoOrDate(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // Less than 1 minute
      if (difference.inSeconds < 60) {
        return 'Just now';
      }

      // Less than 1 hour
      if (difference.inMinutes < 60) {
        final mins = difference.inMinutes;
        return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
      }

      // Less than 24 hours
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      }

      // Less than 2 days
      if (difference.inDays < 2) {
        return '1 day ago';
      }

      // Older than 2 days - show actual date
      return timestamp.substring(0, 10); // Format: YYYY-MM-DD
    } catch (e) {
      return timestamp;
    }
  }
}