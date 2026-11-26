import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/users/user_policy.dart';
import 'package:test/test.dart';

void main() {
  group('UserPolicy.validateCreate', () {
    test('пропускает сотрудника с несколькими ролями', () {
      expect(
        () => UserPolicy.validateCreate(
          email: 'trainer@example.com',
          phone: '+79990000000',
          password: 'Passw0rd!',
          roles: const ['trainer', 'manager'],
        ),
        returnsNormally,
      );
    });

    test('отклоняет клиента с дополнительной ролью', () {
      expect(
        () => UserPolicy.validateCreate(
          email: 'client@example.com',
          phone: null,
          password: 'Passw0rd!',
          roles: const ['client', 'trainer'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('отклоняет пустой набор ролей', () {
      expect(
        () => UserPolicy.validateCreate(
          email: 'user@example.com',
          phone: null,
          password: 'Passw0rd!',
          roles: const [],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('отклоняет неверный email', () {
      expect(
        () => UserPolicy.validateCreate(
          email: 'not-an-email',
          phone: null,
          password: 'Passw0rd!',
          roles: const ['client'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('отклоняет короткий пароль', () {
      expect(
        () => UserPolicy.validateCreate(
          email: 'user@example.com',
          phone: null,
          password: 'Pa1!',
          roles: const ['client'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('отклоняет пароль без спецсимвола', () {
      expect(
        () => UserPolicy.validateCreate(
          email: 'user@example.com',
          phone: null,
          password: 'Passw0rd',
          roles: const ['client'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('UserPolicy.validateRoleChange', () {
    test('запрещает удалить единственную роль', () {
      expect(
        () => UserPolicy.validateRoleChange(
          currentRoles: const ['trainer'],
          newRoles: const [],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('запрещает добавить клиенту вторую роль', () {
      expect(
        () => UserPolicy.validateRoleChange(
          currentRoles: const ['client'],
          newRoles: const ['client', 'trainer'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('запрещает заменять единственную (основную) роль', () {
      expect(
        () => UserPolicy.validateRoleChange(
          currentRoles: const ['instructor'],
          newRoles: const ['trainer'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('UserPolicy.validateUpdate', () {
    test('требует причину архивации', () {
      expect(
        () => UserPolicy.validateUpdate(
          archivedAtProvided: true,
          archivedAt: DateTime(2026, 1, 1),
          archivedReason: 'кор',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('пропускает обновление без архивации', () {
      expect(
        () => UserPolicy.validateUpdate(
          email: 'user@example.com',
          archivedAtProvided: false,
        ),
        returnsNormally,
      );
    });
  });

  test('actionFor различает архивацию и восстановление', () {
    expect(
      UserPolicy.actionFor(wasArchived: false, isArchived: true),
      'ARCHIVE',
    );
    expect(
      UserPolicy.actionFor(wasArchived: true, isArchived: false),
      'RESTORE',
    );
    expect(
      UserPolicy.actionFor(wasArchived: false, isArchived: false),
      'UPDATE',
    );
  });

  test('normalizeNotificationHour ограничивает диапазон', () {
    expect(UserPolicy.normalizeNotificationHour(2), 2);
    expect(
      () => UserPolicy.normalizeNotificationHour(100),
      throwsA(isA<ValidationException>()),
    );
  });
}
