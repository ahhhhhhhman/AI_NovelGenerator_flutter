import 'package:flutter/foundation.dart';
import '../domain/services/log_service.dart';

class ErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Global error handling
    if (kDebugMode) {
      LogService().logError('Error: $error');
      LogService().logError('Stack trace: $stackTrace');
    }
    
    // In a real implementation, you might want to:
    // 1. Log the error to a remote service
    // 2. Show a user-friendly error message
    // 3. Report the error to analytics
  }
}