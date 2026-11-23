/// Уровни логирования приложения.
enum AppLogLevel {
  debug,
  info,
  warning,
  error;

  /// Разбирает уровень из переменной окружения.
  ///
  /// Неизвестное значение не роняет приложение: используется [info].
  static AppLogLevel fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'debug':
        return AppLogLevel.debug;
      case 'warning':
      case 'warn':
        return AppLogLevel.warning;
      case 'error':
        return AppLogLevel.error;
      case 'info':
      default:
        return AppLogLevel.info;
    }
  }

  String get label => name.toUpperCase();
}

/// Формат записи лога.
enum AppLogFormat {
  text,
  json;

  static AppLogFormat fromString(String? value) {
    return value?.trim().toLowerCase() == 'json'
        ? AppLogFormat.json
        : AppLogFormat.text;
  }
}

/// Настройки логгера.
class LogConfig {
  const LogConfig({
    this.level = AppLogLevel.info,
    this.directory = 'logs',
    this.format = AppLogFormat.text,
    this.retentionDays = 30,
    this.maxFileSizeBytes = 50 * 1024 * 1024,
    this.enableConsole = true,
    this.enableFile = true,
  });

  /// Минимальный уровень, который попадает в лог.
  final AppLogLevel level;

  /// Каталог для файлов `fitman_backend_YYYY_MM_DD.log`.
  final String directory;

  /// Формат записей: читаемый текст или JSON.
  final AppLogFormat format;

  /// Сколько дней хранить файлы логов.
  final int retentionDays;

  /// Порог ротации одного файла (по умолчанию 50 МБ).
  final int maxFileSizeBytes;

  /// Выводить ли записи в stdout/stderr.
  final bool enableConsole;

  /// Писать ли записи в файл.
  final bool enableFile;
}
