import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'log_config.dart';

/// Обёртка над `package:logging`.
///
/// Пишет записи в stdout/stderr и в суточный файл
/// `$LOG_DIR/fitman_backend_YYYY_MM_DD.log`. Формат (JSON/текст), уровень и ретеншн
/// задаются через [LogConfig].
class AppLogger {
  AppLogger._() {
    _attach();
  }

  static final AppLogger instance = AppLogger._();

  static final Logger _logger = Logger('fitman');

  LogConfig _config = const LogConfig(enableFile: false);
  StreamSubscription<LogRecord>? _subscription;

  RandomAccessFile? _file;
  DateTime? _fileDay;
  int _fileIndex = 0;
  bool _fileErrorReported = false;

  /// Применяет настройки логирования.
  ///
  /// Вызывается один раз при загрузке [AppConfig]. Повторный вызов безопасен:
  /// старый файл закрывается, подписка пересоздаётся.
  void configure(LogConfig config) {
    _closeFile();
    _config = config;
    _fileDay = null;
    _fileIndex = 0;
    _fileErrorReported = false;

    if (config.enableFile) {
      try {
        Directory(config.directory).createSync(recursive: true);
        _cleanupOldFiles();
      } catch (error) {
        _reportFileError(error);
      }
    }

    Logger.root.level = _toLoggingLevel(config.level);
    _attach();
  }

  /// Уровень debug. В консоль не выводится.
  void debug(
    String message, {
    Map<String, Object?>? fields,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.fine(message, _LogEvent(message, fields, error), stackTrace);
  }

  /// Обычное информационное сообщение.
  void info(
    String message, {
    Map<String, Object?>? fields,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.info(message, _LogEvent(message, fields, error), stackTrace);
  }

  /// Предупреждение.
  void warning(
    String message, {
    Map<String, Object?>? fields,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.warning(message, _LogEvent(message, fields, error), stackTrace);
  }

  /// Ошибка. Стек и текст исключения остаются в логе, но не уходят клиенту.
  void error(
    String message, {
    Map<String, Object?>? fields,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.severe(message, _LogEvent(message, fields, error), stackTrace);
  }

  /// Сбрасывает буфер файла на диск.
  void flush() {
    try {
      _file?.flushSync();
    } catch (_) {
      // Логирование не должно ронять приложение из-за ошибок диска.
    }
  }

  /// Закрывает файл и снимает подписку. Используется при graceful shutdown.
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    _closeFile();
  }

  void _attach() {
    _subscription?.cancel();
    _subscription = Logger.root.onRecord.listen(_handleRecord);
  }

  void _handleRecord(LogRecord record) {
    try {
      // package:logging хранит в message строку, поэтому поля и исходную
      // ошибку передаём через error как _LogEvent.
      final payload = record.error is _LogEvent
          ? record.error as _LogEvent
          : _LogEvent(record.message, null, record.error);
      final level = _fromLoggingLevel(record.level);
      final fields = _sanitizeFields(payload.fields);
      final error = payload.error;

      final entry = <String, Object?>{
        'ts': record.time.toUtc().toIso8601String(),
        'level': level,
        'logger': record.loggerName,
        'msg': _redactText(record.message),
        ...fields,
        if (error != null) 'error': _redactText(error.toString()),
        if (record.stackTrace != null) 'stack': record.stackTrace.toString(),
      };

      final line = _config.format == AppLogFormat.json
          ? jsonEncode(entry)
          : _formatText(entry);

      if (_config.enableConsole && level != 'DEBUG') {
        final sink = level == 'ERROR' ? stderr : stdout;
        sink.writeln(line);
      }

      if (_config.enableFile) {
        _writeToFile(line);
      }
    } catch (error) {
      // Никогда не пробрасываем ошибки логгера в бизнес-логику.
      _reportFileError(error);
    }
  }

  void _writeToFile(String line) {
    try {
      _ensureFile();
      _file?.writeStringSync('$line\n');
      _file?.flushSync();
    } catch (error) {
      _reportFileError(error);
    }
  }

  void _ensureFile() {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    if (_fileDay != day) {
      _closeFile();
      _fileDay = day;
      _fileIndex = 0;
    }

    if (_file == null) {
      _openFile(_fileIndex);
    }

    // Ротация по размеру: fitman_backend_YYYY_MM_DD.1.log, .2.log и т. д.
    while (_file != null &&
        _file!.lengthSync() >= _config.maxFileSizeBytes &&
        _fileIndex < 999) {
      _closeFile();
      _fileIndex += 1;
      _openFile(_fileIndex);
    }
  }

  void _openFile(int index) {
    try {
      final path = _filePathFor(_fileDay ?? DateTime.now(), index);
      _file = File(path).openSync(mode: FileMode.append);
    } catch (error) {
      _file = null;
      _reportFileError(error);
    }
  }

  void _closeFile() {
    try {
      _file?.closeSync();
    } catch (_) {
      // ignore: пустой catch допустим при закрытии файла
    }
    _file = null;
  }

  String _filePathFor(DateTime day, int index) {
    final date = '${day.year.toString().padLeft(4, '0')}_'
        '${day.month.toString().padLeft(2, '0')}_'
        '${day.day.toString().padLeft(2, '0')}';
    final suffix = index == 0 ? '' : '.$index';
    return p.join(_config.directory, 'fitman_backend_$date$suffix.log');
  }

  /// Удаляет файлы старше [LogConfig.retentionDays].
  void _cleanupOldFiles() {
    if (_config.retentionDays <= 0) {
      return;
    }

    final directory = Directory(_config.directory);
    if (!directory.existsSync()) {
      return;
    }

    final cutoff = DateTime.now().subtract(
      Duration(days: _config.retentionDays),
    );
    final cutoffDay = DateTime(cutoff.year, cutoff.month, cutoff.day);
    final pattern =
        RegExp(r'^fitman_backend_(\d{4})_(\d{2})_(\d{2})(?:\.(\d+))?\.log$');

    for (final entity in directory.listSync()) {
      if (entity is! File) {
        continue;
      }
      final match = pattern.firstMatch(p.basename(entity.path));
      if (match == null) {
        continue;
      }
      final fileDay = DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
      if (fileDay.isBefore(cutoffDay)) {
        try {
          entity.deleteSync();
        } catch (error) {
          _reportFileError(error);
        }
      }
    }
  }

  Map<String, Object?> _sanitizeFields(Map<String, Object?>? fields) {
    if (fields == null || fields.isEmpty) {
      return const {};
    }

    final result = <String, Object?>{};
    for (final entry in fields.entries) {
      if (_reservedKeys.contains(entry.key)) {
        continue;
      }
      result[entry.key] = _sanitizeValue(entry.key, entry.value);
    }
    return result;
  }

  Object? _sanitizeValue(String key, Object? value) {
    if (_isSensitiveKey(key)) {
      return '***';
    }
    if (value == null || value is String || value is num || value is bool) {
      return value is String ? _truncate(_redactText(value)) : value;
    }
    if (value is Map) {
      final nested = <String, Object?>{};
      for (final entry in value.entries) {
        final nestedKey = entry.key.toString();
        nested[nestedKey] = _sanitizeValue(nestedKey, entry.value);
      }
      return nested;
    }
    if (value is Iterable) {
      return value.map((item) => _sanitizeValue(key, item)).toList();
    }
    return _truncate(_redactText(value.toString()));
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.isEmpty) {
      return false;
    }
    if (_sensitiveKeys.contains(normalized)) {
      return true;
    }
    return _sensitiveFragments.any(normalized.contains);
  }

  String _redactText(String value) {
    return value
        .replaceAll(
          RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'),
          '***',
        )
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._~+/-]+=*'), 'Bearer ***')
        .replaceAll(RegExp(r'eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]+'), '***');
  }

  String _truncate(String value) {
    const maxLength = 2000;
    return value.length <= maxLength
        ? value
        : '${value.substring(0, maxLength)}…';
  }

  String _formatText(Map<String, Object?> entry) {
    final message = entry['msg'].toString().replaceAll('\n', r'\n');
    final buffer = StringBuffer()
      ..write(entry['ts'])
      ..write(' ')
      ..write(entry['level'])
      ..write(' [')
      ..write(entry['logger'])
      ..write('] ')
      ..write(message);

    for (final field in entry.entries) {
      if (_baseKeys.contains(field.key)) {
        continue;
      }
      buffer
        ..write(' ')
        ..write(field.key)
        ..write('=')
        ..write(_formatTextValue(field.value));
    }
    return buffer.toString();
  }

  String _formatTextValue(Object? value) {
    if (value is String) {
      if (value.isEmpty || value.contains(RegExp(r'\s'))) {
        return jsonEncode(value);
      }
      return value;
    }
    if (value is Map || value is Iterable) {
      return jsonEncode(value);
    }
    return '$value';
  }

  Level _toLoggingLevel(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.debug:
        return Level.FINE;
      case AppLogLevel.info:
        return Level.INFO;
      case AppLogLevel.warning:
        return Level.WARNING;
      case AppLogLevel.error:
        return Level.SEVERE;
    }
  }

  String _fromLoggingLevel(Level level) {
    if (level >= Level.SEVERE) {
      return 'ERROR';
    }
    if (level >= Level.WARNING) {
      return 'WARNING';
    }
    if (level >= Level.INFO) {
      return 'INFO';
    }
    return 'DEBUG';
  }

  void _reportFileError(Object error) {
    if (_fileErrorReported) {
      return;
    }
    _fileErrorReported = true;
    try {
      stderr.writeln('AppLogger: не удалось записать лог: $error');
    } catch (_) {
      // Последний рубеж: молча игнорируем сбой stderr.
    }
  }

  static const Set<String> _baseKeys = {
    'ts',
    'level',
    'logger',
    'msg',
  };

  static const Set<String> _reservedKeys = {
    ..._baseKeys,
    'error',
    'stack',
  };

  static const Set<String> _sensitiveKeys = {
    'password',
    'passwordhash',
    'token',
    'accesstoken',
    'refreshtoken',
    'jwt',
    'authorization',
    'cookie',
    'cookies',
    'phone',
    'phonenumber',
    'email',
    'firstname',
    'lastname',
    'fullname',
    'fio',
    'birthdate',
    'birthday',
    'address',
    'passport',
    'medical',
    'medicaldata',
    'anthropometry',
    'bioimpedance',
    'smscode',
    'body',
    'requestbody',
    'responsebody',
    'sql',
    'sqlparams',
    'query',
  };

  static const List<String> _sensitiveFragments = [
    'password',
    'secret',
    'token',
    'authorization',
    'cookie',
    'phone',
    'email',
    'passport',
    'medical',
    'bioimpedance',
    'anthropometr',
    'firstname',
    'lastname',
    'fullname',
    'birthdate',
    'birthday',
    'smscode',
    'requestbody',
    'responsebody',
    'sqlparam',
  ];
}

/// Глобальная точка доступа к логгеру.
AppLogger get appLog => AppLogger.instance;

class _LogEvent {
  const _LogEvent(this.message, this.fields, this.error);

  final String message;
  final Map<String, Object?>? fields;
  final Object? error;
}
