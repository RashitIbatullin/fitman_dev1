import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';

import '../logging/app_logger.dart';
import 'sql_splitter.dart';

/// Применяет SQL-миграции из каталога и ведёт таблицу `schema_migrations`.
class MigrationRunner {
  MigrationRunner({
    required Future<Connection> Function() connectionFactory,
    required Directory migrationsDirectory,
  })  : _connectionFactory = connectionFactory,
        _migrationsDirectory = migrationsDirectory;

  final Future<Connection> Function() _connectionFactory;
  final Directory _migrationsDirectory;

  /// Возвращает количество применённых миграций.
  Future<int> run() async {
    if (!_migrationsDirectory.existsSync()) {
      throw StateError(
        'Каталог миграций не найден: ${_migrationsDirectory.path}',
      );
    }

    final connection = await _connectionFactory();
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version    text PRIMARY KEY,
        applied_at timestamptz NOT NULL DEFAULT now()
      )
    ''');

    final appliedRows =
        await connection.execute('SELECT version FROM schema_migrations');
    final applied = appliedRows.map((row) => row[0] as String).toSet();

    final files = _migrationsDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    var count = 0;
    for (final file in files) {
      final version = p.basename(file.path);
      if (applied.contains(version)) {
        appLog.debug('Миграция уже применена', fields: {'version': version});
        continue;
      }

      final statements = splitSqlStatements(file.readAsStringSync());
      if (statements.isEmpty) {
        appLog.warning('Пустая миграция', fields: {'version': version});
        continue;
      }

      await connection.runTx((session) async {
        for (final statement in statements) {
          await session.execute(statement);
        }
        await session.execute(
          Sql.named(
            'INSERT INTO schema_migrations (version) VALUES (@version)',
          ),
          parameters: {'version': version},
        );
      });

      count++;
      appLog.info(
        'Миграция применена',
        fields: {'version': version, 'statements': statements.length},
      );
    }

    return count;
  }
}
