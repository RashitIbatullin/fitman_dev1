import 'dart:io';

import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/migrations/migration_runner.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

/// Интеграционные тесты требуют отдельную локальную БД `fitman_test`.
///
/// Запуск:
///   RUN_DB_TESTS=true dart test test/audit/audit_integration_test.dart
///
/// Параметры БД можно переопределить через TEST_DB_HOST, TEST_DB_PORT,
/// TEST_DB_NAME, TEST_DB_USER, TEST_DB_PASS.
void main() {
  final enabled = Platform.environment['RUN_DB_TESTS'] == 'true';
  final skipReason = enabled
      ? null
      : 'Нужна тестовая БД: RUN_DB_TESTS=true dart test test/audit/audit_integration_test.dart';

  group('AuditService.sanitizeSnapshot', () {
    test('маскирует пароли и токены, включая вложенные профили', () {
      final snapshot = AuditService.sanitizeSnapshot({
        'id': 'user-1',
        'email': 'user@example.com',
        'password_hash': 'secret-hash',
        'employee_profile': {
          'specialization': 'Тренер',
          'password_hash': 'nested-hash',
        },
        'jwt_refresh_token': 'token-value',
        'roles': ['client'],
      });

      expect(snapshot['password_hash'], '***');
      expect(
        (snapshot['employee_profile'] as Map<String, Object?>)['password_hash'],
        '***',
      );
      expect(snapshot['jwt_refresh_token'], '***');
      expect(snapshot['email'], 'user@example.com');
      expect(snapshot['roles'], ['client']);
    });
  });

  group('AuditService', skip: skipReason, () {
    late Connection connection;
    late AuditService auditService;

    setUpAll(() async {
      connection = await Connection.open(
        Endpoint(
          host: Platform.environment['TEST_DB_HOST'] ?? '127.0.0.1',
          port:
              int.tryParse(Platform.environment['TEST_DB_PORT'] ?? '') ?? 5432,
          database: Platform.environment['TEST_DB_NAME'] ?? 'fitman_test',
          username: Platform.environment['TEST_DB_USER'] ?? 'postgres',
          password: Platform.environment['TEST_DB_PASS'] ?? 'postgres',
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );

      await connection.execute('CREATE EXTENSION IF NOT EXISTS pgcrypto');
      await connection.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id uuid PRIMARY KEY DEFAULT gen_random_uuid()
        )
      ''');
      // Тестовая БД может содержать полную схему users из database/users.sql.
      // Добавляем обязательные колонки, если их нет, чтобы вставка работала
      // и на минимальной, и на полной схеме.
      await connection.execute(
        'ALTER TABLE users ADD COLUMN IF NOT EXISTS login text',
      );
      await connection.execute(
        'ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash text',
      );
      await connection.execute('''
        INSERT INTO users (id, login, password_hash)
        VALUES (
          '00000000-0000-0000-0000-000000000001',
          'audit-test',
          'test-hash'
        )
        ON CONFLICT (id) DO NOTHING
      ''');

      await MigrationRunner(
        connectionFactory: () async => connection,
        migrationsDirectory: _findMigrationsDirectory(),
      ).run();

      auditService = const AuditService();
    });

    tearDownAll(() async {
      await connection.close();
    });

    test('commit сохраняет запись с актором, request_id и source', () async {
      final requestId = const Uuid().v4();
      final rowPk = const Uuid().v4();
      final context = AuditContext(
        actorId: '00000000-0000-0000-0000-000000000001',
        actorRole: 'admin',
        requestId: requestId,
      );

      await connection.runTx((session) async {
        await auditService.record(
          session: session,
          tableName: 'rooms',
          rowPk: rowPk,
          action: 'INSERT',
          context: context,
          newValues: {'name': 'Тестовое помещение'},
        );
      });

      final rows = await connection.execute(
        Sql.named(
          'SELECT action, source, changed_by, actor_role '
          'FROM audit_log WHERE request_id = CAST(@id AS uuid)',
        ),
        parameters: {'id': requestId},
      );

      expect(rows, hasLength(1));
      expect(rows.first[0], 'INSERT');
      expect(rows.first[1], 'api');
      expect(rows.first[2].toString(), '00000000-0000-0000-0000-000000000001');
      expect(rows.first[3], 'admin');
    });

    test('rollback не оставляет записи аудита', () async {
      final requestId = const Uuid().v4();
      final context = AuditContext(requestId: requestId);
      final rowPk = const Uuid().v4();

      await expectLater(
        connection.runTx((session) async {
          await auditService.record(
            session: session,
            tableName: 'rooms',
            rowPk: rowPk,
            action: 'UPDATE',
            context: context,
          );
          throw StateError('rollback');
        }),
        throwsStateError,
      );

      final rows = await connection.execute(
        Sql.named(
          'SELECT id FROM audit_log WHERE request_id = CAST(@id AS uuid)',
        ),
        parameters: {'id': requestId},
      );

      expect(rows, isEmpty);
    });

    test('audit_log запрещает UPDATE и DELETE', () async {
      final requestId = const Uuid().v4();
      await connection.runTx((session) async {
        await auditService.record(
          session: session,
          tableName: 'rooms',
          rowPk: const Uuid().v4(),
          action: 'INSERT',
          context: AuditContext(requestId: requestId),
        );
      });

      await expectLater(
        connection.execute(
          Sql.named(
            "UPDATE audit_log SET action = 'TAMPERED' WHERE request_id = CAST(@id AS uuid)",
          ),
          parameters: {'id': requestId},
        ),
        throwsA(isA<Exception>()),
      );

      await expectLater(
        connection.execute(
          Sql.named(
            'DELETE FROM audit_log WHERE request_id = CAST(@id AS uuid)',
          ),
          parameters: {'id': requestId},
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

Directory _findMigrationsDirectory() {
  var directory = Directory.current.absolute;
  while (true) {
    final candidate = Directory(
      p.join(directory.path, 'database', 'migrations'),
    );
    if (candidate.existsSync()) {
      return candidate;
    }
    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('database/migrations не найден');
    }
    directory = parent;
  }
}
