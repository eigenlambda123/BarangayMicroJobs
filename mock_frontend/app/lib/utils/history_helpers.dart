String formatDate(dynamic dateInput) {
  DateTime dateTime;
  if (dateInput is String) {
    try {
      dateTime = DateTime.parse(dateInput);
    } catch (e) {
      return 'Unknown date';
    }
  } else if (dateInput is DateTime) {
    dateTime = dateInput;
  } else {
    return 'Unknown date';
  }

  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}
