import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/users/repositories/user_repository.dart';
import 'package:fitman_backend/modules/users/services/user_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

/// Тесты сервиса на фейковом репозитории: проверяем транзакционный сценарий,
/// аудит и отказы без реальной БД.
void main() {
  late _FakeUserRepository repository;
  late _RecordingAuditService auditService;
  late UserService service;
  late AuditContext audit;

  setUp(() {
    repository = _FakeUserRepository();
    auditService = _RecordingAuditService();
    service = UserService(repository, auditService, _FakeDatabase());
    audit = AuditContext(
      actorId: const Uuid().v4(),
      actorRole: 'admin',
      requestId: const Uuid().v4(),
    );
  });

  test('создание пишет аудит users, user_roles и user_settings', () async {
    final created = await service.createUser(
      const CreateUserInput(
        email: 'client@example.com',
        password: 'Passw0rd!',
        firstName: 'Иван',
        lastName: 'Клиентов',
        roles: ['client'],
        phone: '+79990000000',
      ),
      audit: audit,
    );

    expect(created.id, isNotEmpty);
    expect(created.roles.map((role) => role.name), ['client']);
    expect(auditService.records.map((record) => record.tableName).toSet(), {
      'users',
      'user_roles',
      'user_settings',
    });
    expect(
      auditService.records.every(
        (record) => record.requestId == audit.requestId,
      ),
      isTrue,
    );
  });

  test('повторный email отклоняется и не пишет аудит', () async {
    repository.addExisting(
      _user(email: 'busy@example.com', phone: '+79991111111'),
    );

    await expectLater(
      service.createUser(
        const CreateUserInput(
          email: 'busy@example.com',
          phone: '+79992222222',
          password: 'Passw0rd!',
          firstName: 'Пётр',
          lastName: 'Занятый',
          roles: ['client'],
        ),
        audit: audit,
      ),
      throwsA(isA<ConflictException>()),
    );

    expect(auditService.records, isEmpty);
  });

  test('клиент с дополнительной ролью отклоняется до транзакции', () async {
    await expectLater(
      service.createUser(
        const CreateUserInput(
          email: 'bad@example.com',
          password: 'Passw0rd!',
          firstName: 'Клиент',
          lastName: 'Тренер',
          roles: ['client', 'trainer'],
        ),
        audit: audit,
      ),
      throwsA(isA<ValidationException>()),
    );

    expect(auditService.records, isEmpty);
  });

  test('нельзя снять единственную роль пользователя', () async {
    final user = _user(email: 'trainer@example.com', phone: '+79992222222')
        .copyWith(
          roles: [Role(id: 'trainer', name: 'trainer', title: 'Тренер')],
        );
    repository.addExisting(user);

    await expectLater(
      service.updateRoles(user.id, const [], audit: audit),
      throwsA(isA<ValidationException>()),
    );

    expect(auditService.records, isEmpty);
  });
}

User _user({required String email, String? phone}) {
  final now = DateTime(2026, 1, 1);
  return User(
    id: const Uuid().v4(),
    email: email,
    passwordHash: 'hash',
    firstName: 'Тест',
    lastName: 'Пользователь',
    roles: const [],
    phone: phone,
    createdAt: now,
    updatedAt: now,
  );
}

class _AuditRecord {
  const _AuditRecord({
    required this.tableName,
    required this.action,
    required this.requestId,
  });

  final String tableName;
  final String action;
  final String? requestId;
}

class _RecordingAuditService extends AuditService {
  _RecordingAuditService();

  final List<_AuditRecord> records = [];

  @override
  Future<void> record({
    required Session session,
    required String tableName,
    required String rowPk,
    required String action,
    required AuditContext context,
    Map<String, Object?>? oldValues,
    Map<String, Object?>? newValues,
    String? reason,
  }) async {
    records.add(
      _AuditRecord(
        tableName: tableName,
        action: action,
        requestId: context.requestId,
      ),
    );
  }
}

class _FakeDatabase implements Database {
  @override
  Future<T> runTx<T>(Future<T> Function(TxSession session) action) {
    return action(_FakeTxSession());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('Database.${invocation.memberName}');
  }
}

class _FakeTxSession implements TxSession {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('TxSession.${invocation.memberName}');
  }
}

class _FakeUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  final Map<String, List<String>> _roleIdsByUser = {};

  void addExisting(User user) {
    _users[user.id] = user;
  }

  @override
  Future<User?> getUserByEmail(String email, {Session? session}) async {
    for (final user in _users.values) {
      if (user.email == email) return user;
    }
    return null;
  }

  @override
  Future<User?> getUserByPhone(String phone, {Session? session}) async {
    for (final user in _users.values) {
      if (user.phone == phone) return user;
    }
    return null;
  }

  @override
  Future<User?> getUserByIdentifier(String identifier, {Session? session}) async {
    for (final user in _users.values) {
      if (user.phone == identifier ||
          (user.email != null &&
              user.email!.toLowerCase() == identifier.toLowerCase())) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<User?> getUserById(String id, {Session? session}) async {
    return _users[id];
  }

  @override
  Future<User> createUser(
    User user,
    List<String> roleNames, {
    String? creatorId,
    Session? session,
  }) async {
    final created = user.copyWith(
      id: const Uuid().v4(),
      roles: roleNames
          .map((name) => Role(id: name, name: name, title: name))
          .toList(),
    );
    _users[created.id] = created;
    _roleIdsByUser[created.id] = roleNames;
    return created;
  }

  @override
  Future<List<Role>> getAllRoles({Session? session}) async {
    return const [
      'client',
      'instructor',
      'trainer',
      'manager',
      'admin',
    ].map((name) => Role(id: name, name: name, title: name)).toList();
  }

  @override
  Future<List<Role>> getRolesForUser(String userId, {Session? session}) async {
    final names = _roleIdsByUser[userId] ?? const <String>[];
    return names
        .map((name) => Role(id: name, name: name, title: name))
        .toList();
  }

  @override
  Future<void> updateUserRoles(
    String userId,
    List<String> newRoleIds, {
    String? updatedBy,
    Session? session,
  }) async {
    _roleIdsByUser[userId] = newRoleIds;
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(
        roles: newRoleIds
            .map((name) => Role(id: name, name: name, title: name))
            .toList(),
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('UserRepository.${invocation.memberName}');
  }
}
