import 'dart:io';
import 'package:dotenv/dotenv.dart';

import '../logging/app_logger.dart';
import '../logging/log_config.dart';

/// AppConfig - синглтон для доступа к конфигурации приложения.
///
/// Загружает переменные из окружения при первом доступе.
/// Это позволяет централизованно управлять настройками, такими как
/// секретные ключи, параметры базы данных и другие переменные окружения.
///
/// Пример использования:
/// ```dart
/// final dbHost = AppConfig.instance.dbHost;
/// ```
class AppConfig {
  // Приватный конструктор для реализации синглтона.
  AppConfig._();

  // Статический экземпляр синглтона.
  static final AppConfig instance = AppConfig._().._load();

  //
  // --- Поля конфигурации ---
  //

  // Настройки JWT
  late final String jwtSecret;
  late final int jwtExpiryHours;

  // Настройки CORS
  late final List<String> allowedOrigins;

  // Настройки базы данных
  late final String dbHost;
  late final int dbPort;
  late final String dbName;
  late final String dbUser;
  late final String dbPass;

  // Настройки сервера
  // Замечание: порт для dart_frog задается через `dart_frog dev --port <port>`
  // Это значение здесь для справки или для других нужд.
  late final int serverPort;
  late final String serverHost;

  // Настройки логирования
  late final String logLevel;
  late final String logDir;
  late final String logFormat;
  late final int logRetentionDays;
  late final int logMaxFileMb;

  /// _load - внутренний метод для загрузки переменных из окружения.
  void _load() {
    // Определяем окружение (dev, test, prod) по переменной DART_ENV.
    final env = Platform.environment['DART_ENV'] ?? 'dev';
    final envFile = '.env.$env';

    // Загружаем переменные из .env файла.
    // `includePlatformEnvironment: true` объединяет системные переменные
    // с теми, что в файле (переменные из файла имеют приоритет).
    final dotEnv = DotEnv(includePlatformEnvironment: true)..load([envFile]);

    // Теперь используем `dotEnv` для доступа к переменным как к Map.

    // JWT
    jwtSecret = dotEnv['JWT_SECRET'] ?? 'insecure-default-key';
    jwtExpiryHours = int.tryParse(dotEnv['JWT_EXPIRY_HOURS'] ?? '24') ?? 24;

    // CORS
    allowedOrigins = (dotEnv['ALLOWED_ORIGINS'] ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();

    // Database
    dbHost = dotEnv['DB_HOST'] ?? 'localhost';
    dbPort = int.tryParse(dotEnv['DB_PORT'] ?? '5432') ?? 5432;
    dbName = dotEnv['DB_NAME'] ?? 'fitman_dev1';
    dbUser = dotEnv['DB_USER'] ?? 'postgres';
    dbPass = dotEnv['DB_PASS'] ?? 'postgres';

    // Server
    serverHost = dotEnv['SERVER_HOST'] ?? '0.0.0.0';
    serverPort = int.tryParse(dotEnv['SERVER_PORT'] ?? '8080') ?? 8080;

    // Logging
    logLevel = dotEnv['LOG_LEVEL'] ?? 'info';
    logDir = dotEnv['LOG_DIR'] ?? 'logs';
    logFormat = dotEnv['LOG_FORMAT'] ?? (env == 'prod' ? 'json' : 'text');
    logRetentionDays = int.tryParse(dotEnv['LOG_RETENTION_DAYS'] ?? '30') ?? 30;
    final parsedMaxFileMb =
        int.tryParse(dotEnv['LOG_MAX_FILE_MB'] ?? '50') ?? 50;
    logMaxFileMb = parsedMaxFileMb > 0 ? parsedMaxFileMb : 50;

    AppLogger.instance.configure(
      LogConfig(
        level: AppLogLevel.fromString(logLevel),
        directory: logDir,
        format: AppLogFormat.fromString(logFormat),
        retentionDays: logRetentionDays,
        maxFileSizeBytes: logMaxFileMb * 1024 * 1024,
      ),
    );

    appLog.info(
      'Конфигурация загружена',
      fields: {
        'env': env,
        'log_level': logLevel,
        'log_format': logFormat,
        'log_dir': logDir,
        'log_max_file_mb': logMaxFileMb,
      },
    );

    // Предупреждение о безопасности, если секретный ключ не установлен.
    if (jwtSecret == 'insecure-default-key') {
      appLog.warning(
        'JWT_SECRET не установлен в .env файле; используется ключ по умолчанию',
      );
    }
  }


  //
  // --- Статические константы и методы, не зависящие от окружения ---
  //

  static const int bcryptRounds = 12;
  static const int minPasswordLength = 6;
  static const List<String> allowedRoles = ['client', 'trainer', 'instructor', 'manager', 'admin'];

  // Валидация email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Валидация роли
  static bool isValidRole(String role) {
    return allowedRoles.contains(role);
  }

  // Валидация пароля
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
}
