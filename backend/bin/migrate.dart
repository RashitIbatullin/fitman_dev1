import 'dart:io';

import 'package:fitman_backend/config/app_config.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/migrations/migration_runner.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  // Загрузка конфигурации и настройка логгера.
  AppConfig.instance;

  final database = Database();
  try {
    final migrationsDirectory = _findMigrationsDirectory();
    final applied = await MigrationRunner(
      connectionFactory: () => database.connection,
      migrationsDirectory: migrationsDirectory,
    ).run();

    appLog.info(
      'Миграции завершены',
      fields: {
        'applied': applied,
        'directory': migrationsDirectory.path,
      },
    );
  } catch (error, stackTrace) {
    appLog.error(
      'Ошибка применения миграций',
      error: error,
      stackTrace: stackTrace,
    );
    exitCode = 1;
  } finally {
    await database.disconnect();
    await AppLogger.instance.close();
  }
}

/// Ищет `database/migrations` вверх от текущего каталога.
Directory _findMigrationsDirectory() {
  var directory = Directory.current.absolute;

  while (true) {
    final candidate = Directory(p.join(directory.path, 'database', 'migrations'));
    if (candidate.existsSync()) {
      return candidate;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      break;
    }
    directory = parent;
  }

  throw StateError(
    'Не найден каталог database/migrations. '
    'Запустите команду из каталога backend или корня проекта.',
  );
}
