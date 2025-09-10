extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
  
  bool isValidApiKey() {
    // Simple validation for API key format
    return length > 10 && contains(RegExp(r'[A-Za-z0-9]'));
  }
}

extension DateTimeExtensions on DateTime {
  String toFormattedString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}