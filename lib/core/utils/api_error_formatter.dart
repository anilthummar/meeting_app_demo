/// Formats raw API error messages into user-friendly snackbar text.
class ApiErrorFormatter {
  ApiErrorFormatter._();

  static String format(String? message, {required String fallback}) {
    if (message == null || message.trim().isEmpty) {
      return fallback;
    }

    final normalized = message.toLowerCase();
    if (normalized.contains('notfoundexception') ||
        normalized.contains('meeting') && normalized.contains('not found')) {
      return 'This meeting no longer exists or has expired. '
          'Tap Create Meeting to start a new one, then join with the new ID.';
    }

    if (message.length > 160) {
      return fallback;
    }

    return message;
  }
}
