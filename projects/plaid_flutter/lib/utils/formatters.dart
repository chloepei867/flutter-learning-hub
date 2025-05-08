String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}/${date.year}';
  } catch (e) {
    return dateStr;
  }
}

String formatDateTime(String dateTimeStr) {
  try {
    final dateTime = DateTime.parse(dateTimeStr);
    return '${formatDate(dateTime.toIso8601String().split('T')[0])} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateTimeStr;
  }
}

String capitalizeWords(String text) {
  return text.split('_').map((word) =>
  word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
  ).join(' ');
}

String formatPaymentChannel(String channel) {
  // Capitalize first letter
  return channel.substring(0, 1).toUpperCase() + channel.substring(1);
}

String formatCategoryDisplay(String category) {
  // Convert FOOD_AND_DRINK_FAST_FOOD to Fast Food
  List<String> parts = category.split('_');
  // Find the most specific part (usually at the end)
  if (parts.length > 2) {
    List<String> specificParts = parts.sublist(parts.length - 2);
    return specificParts.map((part) =>
    part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}'
    ).join(' ');
  }
  return capitalizeWords(category);
}