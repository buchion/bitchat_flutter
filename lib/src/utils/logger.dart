import 'dart:developer' as developer;

/// BitChat logger utility for consistent logging across the package
class BitChatLogger {
  static const String _defaultTag = 'BitChat';
  
  /// Log an info message
  void info(String tag, String message) {
    _log('INFO', tag, message);
  }
  
  /// Log a warning message
  void warning(String tag, String message) {
    _log('WARNING', tag, message);
  }
  
  /// Log an error message
  void error(String tag, String message) {
    _log('ERROR', tag, message);
  }
  
  /// Log a debug message
  void debug(String tag, String message) {
    _log('DEBUG', tag, message);
  }
  
  /// Log a verbose message
  void verbose(String tag, String message) {
    _log('VERBOSE', tag, message);
  }
  
  void _log(String level, String tag, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] [$tag] $message';
    
    // Use Flutter's developer.log for better integration
    developer.log(
      logMessage,
      name: 'BitChat',
      level: _getLogLevel(level),
    );
    
    // Also print to console for debugging
    if (level == 'ERROR') {
      print('❌ $logMessage');
    } else if (level == 'WARNING') {
      print('⚠️  $logMessage');
    } else if (level == 'INFO') {
      print('ℹ️  $logMessage');
    } else {
      print('🔍 $logMessage');
    }
  }
  
  int _getLogLevel(String level) {
    switch (level) {
      case 'ERROR':
        return 1000;
      case 'WARNING':
        return 900;
      case 'INFO':
        return 800;
      case 'DEBUG':
        return 500;
      case 'VERBOSE':
        return 100;
      default:
        return 800;
    }
  }
}
