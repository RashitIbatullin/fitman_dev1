import 'package:fitman_backend/security/access_policy.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:test/test.dart';

User _user(List<String> roles) {
  return User(
    id: 'user-1',
    passwordHash: '',
    firstName: 'Тест',
    lastName: 'Тестов',
    roles: roles
        .map((name) => Role(id: name, name: name, title: name))
        .toList(),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  group('AccessPolicy', () {
    test('админ имеет доступ к управлению', () {
      final admin = _user(['admin']);

      expect(AccessPolicy.isAdmin(admin), isTrue);
      expect(AccessPolicy.allows(admin, Permissions.usersManage), isTrue);
      expect(AccessPolicy.allows(admin, Permissions.servicesCatalogManage), isTrue);
    });

    test('менеджер управляет услугами, но не пользователями', () {
      final manager = _user(['manager']);

      expect(
        AccessPolicy.allows(manager, Permissions.servicesCatalogManage),
        isTrue,
      );
      expect(
        AccessPolicy.allows(manager, Permissions.servicesPurchasesCreate),
        isTrue,
      );
      expect(AccessPolicy.allows(manager, Permissions.usersManage), isFalse);
      expect(AccessPolicy.isManagerOrAdmin(manager), isTrue);
    });

    test('исполнитель видит записи, но не каталог', () {
      final executor = _user(['executor']);

      expect(
        AccessPolicy.allows(executor, Permissions.appointmentsView),
        isTrue,
      );
      expect(
        AccessPolicy.allows(executor, Permissions.servicesCatalogManage),
        isFalse,
      );
      expect(AccessPolicy.isExecutorOnly(executor), isTrue);
    });

    test('клиент не получает сотруднических прав', () {
      final client = _user(['client']);

      expect(
        AccessPolicy.allows(client, Permissions.servicesCatalogManage),
        isFalse,
      );
      expect(AccessPolicy.allows(client, Permissions.appointmentsView), isFalse);
      expect(AccessPolicy.isClient(client), isTrue);
    });

    test('тренер управляет расписанием, инструктор смотрит клиентов', () {
      final trainer = _user(['trainer']);
      final instructor = _user(['instructor']);

      expect(
        AccessPolicy.allows(trainer, Permissions.scheduleManage),
        isTrue,
      );
      expect(
        AccessPolicy.allows(instructor, Permissions.scheduleManage),
        isFalse,
      );
      expect(
        AccessPolicy.allows(instructor, Permissions.clientsView),
        isTrue,
      );
      expect(
        AccessPolicy.allows(instructor, Permissions.instructorView),
        isTrue,
      );
      expect(
        AccessPolicy.allows(trainer, Permissions.instructorView),
        isFalse,
      );
    });

    test('неизвестное право запрещено', () {
      expect(AccessPolicy.allows(_user(['admin']), 'unknown.permission'), isFalse);
    });

    test('проверка по строке ролей из AuditContext', () {
      expect(
        AccessPolicy.allowsRoleCsv('manager,executor', Permissions.appointmentsAct),
        isTrue,
      );
      expect(
        AccessPolicy.allowsRoleCsv('executor', Permissions.servicesCatalogManage),
        isFalse,
      );
      expect(AccessPolicy.allowsRoleCsv(null, Permissions.appointmentsView), isFalse);
    });
  });
}
