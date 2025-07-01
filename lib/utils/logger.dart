import 'dart:io' show Platform, stdout; // For checking if running on a TTY

import 'package:logger/logger.dart';

/// A custom logger for the Dart Frog backend.
class AppLogger {
  // Private constructor to prevent direct instantiation
  AppLogger._();
  // Private static instance of Logger
  static final Logger _logger = Logger(
    // Customize the printer for better console output
    printer: PrettyPrinter(
      methodCount:
          0, // Number of method calls to be displayed (0 for backend context)
      lineLength: 80, // Width of the output
      colors:
          stdout.supportsAnsiEscapes, // Enable colors if console supports it
      dateTimeFormat: DateTimeFormat.dateAndTime, // Show timestamp for each log
    ),
    // Define the minimum level for logs to be displayed
    // You can change this based on your environment (debug, production)
    level: Level.debug, // Default to debug
  );

  /// Logs a verbose message. Useful for detailed debugging.
  static void verbose(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a debug message.
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message. Indicates a potential issue.
  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message. Indicates a recoverable error.
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a severe/fatal message. Indicates a critical, unrecoverable error.
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
