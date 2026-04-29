class TransactionHelpers {
  static String normalize(Object? value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute';
    } catch (_) {
      return dateTimeString;
    }
  }

  static bool canShowCompletionActions(Map<String, dynamic> transaction) {
    if (normalize(transaction['status']) != 'hired') {
      return false;
    }

    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;
    if (requesterCanceled || providerCanceled) {
      return false;
    }

    final isRequester = transaction['is_requester'] as bool? ?? false;
    final requesterCompleted =
        transaction['requester_completed'] as bool? ?? false;
    final providerCompleted =
        transaction['provider_completed'] as bool? ?? false;

    if (isRequester) {
      return providerCompleted && !requesterCompleted;
    }

    return !providerCompleted;
  }

  static bool canShowCancellationActions(Map<String, dynamic> transaction) {
    if (normalize(transaction['status']) != 'hired') {
      return false;
    }

    final isRequester = transaction['is_requester'] as bool? ?? false;
    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;

    final userCanceled = isRequester ? requesterCanceled : providerCanceled;
    final otherCanceled = isRequester ? providerCanceled : requesterCanceled;

    return !userCanceled || otherCanceled;
  }

  static bool canShowCompletionStatus(Map<String, dynamic> transaction) {
    return normalize(transaction['status']) == 'hired';
  }

  static bool canShowCancellationStatus(Map<String, dynamic> transaction) {
    final status = normalize(transaction['status']);
    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;

    return status == 'hired' && (requesterCanceled || providerCanceled);
  }

  static String getCompletionButtonText(Map<String, dynamic> transaction) {
    final isRequester = transaction['is_requester'] as bool? ?? false;
    final requesterCompleted =
        transaction['requester_completed'] as bool? ?? false;
    final providerCompleted =
        transaction['provider_completed'] as bool? ?? false;
    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;

    if (requesterCanceled || providerCanceled) {
      return 'Waiting for Cancellation';
    }

    final userCompleted = isRequester ? requesterCompleted : providerCompleted;
    final otherCompleted = isRequester ? providerCompleted : requesterCompleted;

    if (userCompleted && otherCompleted) {
      return 'Job Completed';
    }
    if (userCompleted) {
      return 'Waiting for Other Party';
    }
    if (otherCompleted) {
      return 'Confirm Completion';
    }
    return 'Mark Job as Completed';
  }

  static String getCancelButtonText(Map<String, dynamic> transaction) {
    final isRequester = transaction['is_requester'] as bool? ?? false;
    final requesterCanceled =
        transaction['requester_canceled'] as bool? ?? false;
    final providerCanceled = transaction['provider_canceled'] as bool? ?? false;

    final userCanceled = isRequester ? requesterCanceled : providerCanceled;
    final otherCanceled = isRequester ? providerCanceled : requesterCanceled;

    if (userCanceled && otherCanceled) {
      return 'Job Canceled';
    }
    if (userCanceled) {
      return 'Waiting for Other Party';
    }
    if (otherCanceled) {
      return 'Confirm Cancellation';
    }
    return 'Cancel Job';
  }
}
