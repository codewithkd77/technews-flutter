import 'package:intl/intl.dart';

/// Utility functions for date and time operations
class DateUtils {
  /// Formats a date string to a more readable format
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Formats a date string to show time ago (e.g., "2 hours ago")
  static String timeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown time';

    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else {
        return formatDate(dateString);
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  /// Checks if a date string is today
  static bool isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;

    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      final DateTime now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (e) {
      return false;
    }
  }
}
