import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;

class AppLogger {
  static const int _maxFileSize = 2 * 1024 * 1024; // 2 MB
  static const int _maxFiles = 3;
  static File? _currentLogFile;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create();
      }
      _currentLogFile = File('${logDir.path}/app_0.log');
      _initialized = true;
      info('Logger initialized');
    } catch (e) {
      debugPrint('Failed to initialize logger: $e');
    }
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, error, stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log('WARN', message, error, stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, error, stackTrace);
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, error, stackTrace);
  }

  static Future<void> _log(String level, String message, Object? error, StackTrace? stackTrace) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message${error != null ? '\nError: $error' : ''}${stackTrace != null ? '\nStack: $stackTrace' : ''}';
    
    if (kDebugMode) {
      developer.log(message, name: level, error: error, stackTrace: stackTrace);
    }

    if (!_initialized || _currentLogFile == null) return;

    try {
      if (await _currentLogFile!.exists() && await _currentLogFile!.length() > _maxFileSize) {
        await _rotateFiles();
      }
      await _currentLogFile!.writeAsString('$logMessage\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write log: $e');
    }
  }

  static Future<void> _rotateFiles() async {
    final dir = _currentLogFile!.parent;
    for (int i = _maxFiles - 1; i >= 0; i--) {
      final oldFile = File('${dir.path}/app_$i.log');
      if (await oldFile.exists()) {
        if (i == _maxFiles - 1) {
          await oldFile.delete();
        } else {
          await oldFile.rename('${dir.path}/app_${i + 1}.log');
        }
      }
    }
  }

  static Future<List<File>> getLogFiles() async {
    if (!_initialized || _currentLogFile == null) return [];
    final dir = _currentLogFile!.parent;
    return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.log')).toList();
  }
}
