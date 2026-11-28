import 'package:fitman_common/fitman_common.dart';

/// Стабильные коды прав. Пока права вычисляются в коде, позже
/// эти же коды лягут в матрицу ролей и персональных исключений.
abstract final class Permissions {
  static const String systemAdmin = 'system.admin';
  static const String systemManage = 'system.manage';

  static const String usersView = 'users.view';
  static const String usersManage = 'users.manage';
  static const String rolesManage = 'roles.manage';

  static const String clientsView = 'clients.view';
  static const String clientsManage = 'clients.manage';
  static const String instructorView = 'instructor.view';

  static const String staffView = 'staff.view';
  static const String groupsView = 'groups.view';
  static const String groupsManage = 'groups.manage';

  static const String scheduleManage = 'schedule.manage';
  static const String catalogsManage = 'catalogs.manage';

  static const String equipmentManage = 'equipment.manage';
  static const String roomsManage = 'rooms.manage';
  static const String supportStaffManage = 'support_staff.manage';

  static const String servicesCatalogView = 'services.catalog.view';
  static const String servicesCatalogManage = 'services.catalog.manage';
  static const String servicesPurchasesView = 'services.purchases.view';
  static const String servicesPurchasesCreate = 'services.purchases.create';
  static const String servicesPurchasesManage = 'services.purchases.manage';

  static const String appointmentsView = 'appointments.view';
  static const String appointmentsAct = 'appointments.act';
  static const String servicesStaff = 'services.staff';

  static const String auditView = 'audit.view';
  static const String analyticsManage = 'analytics.manage';
}

/// Именованные наборы ролей: одно место вместо литералов по модулям.
abstract final class RoleGroups {
  static const Set<String> admin = {'admin'};
  static const Set<String> manager = {'admin', 'manager'};
  static const Set<String> trainer = {'admin', 'trainer'};
  static const Set<String> instructor = {'admin', 'instructor'};
  static const Set<String> staff = {'admin', 'manager', 'trainer', 'instructor'};
  static const Set<String> servicesStaff = {
    'admin',
    'manager',
    'trainer',
    'instructor',
    'executor',
  };
  static const Set<String> clientsView = {'admin', 'manager', 'instructor'};
}

/// Политика доступа: роль → права и быстрые проверки групп ролей.
///
/// Это промежуточный шаг перед БД-матрицей. Поведение совпадает
/// с прежними хардкод-проверками ролей.
abstract final class AccessPolicy {
  static const Map<String, Set<String>> _rolePermissions = {
    Permissions.systemAdmin: RoleGroups.admin,
    Permissions.systemManage: RoleGroups.manager,

    Permissions.usersView: RoleGroups.staff,
    Permissions.usersManage: RoleGroups.admin,
    Permissions.rolesManage: RoleGroups.admin,

    Permissions.clientsView: RoleGroups.clientsView,
    Permissions.clientsManage: RoleGroups.admin,
    Permissions.instructorView: RoleGroups.instructor,

    Permissions.staffView: RoleGroups.staff,
    Permissions.groupsView: RoleGroups.staff,
    Permissions.groupsManage: RoleGroups.manager,

    Permissions.scheduleManage: RoleGroups.trainer,
    Permissions.catalogsManage: RoleGroups.admin,

    Permissions.equipmentManage: RoleGroups.admin,
    Permissions.roomsManage: RoleGroups.admin,
    Permissions.supportStaffManage: RoleGroups.admin,

    Permissions.servicesCatalogView: RoleGroups.servicesStaff,
    Permissions.servicesCatalogManage: RoleGroups.manager,
    Permissions.servicesPurchasesView: RoleGroups.servicesStaff,
    Permissions.servicesPurchasesCreate: RoleGroups.manager,
    Permissions.servicesPurchasesManage: RoleGroups.manager,

    Permissions.appointmentsView: RoleGroups.servicesStaff,
    Permissions.appointmentsAct: RoleGroups.servicesStaff,
    Permissions.servicesStaff: RoleGroups.servicesStaff,

    Permissions.auditView: RoleGroups.admin,
    Permissions.analyticsManage: RoleGroups.admin,
  };

  static Set<String> rolesOf(User user) {
    return user.roles.map((role) => role.name).toSet();
  }

  static bool allows(User user, String permission) {
    return allowsRoles(rolesOf(user), permission);
  }

  static bool allowsRoles(Iterable<String> roles, String permission) {
    final allowed = _rolePermissions[permission];
    if (allowed == null) {
      return false;
    }
    return roles.any(allowed.contains);
  }

  /// Проверка по строке ролей из `AuditContext.actorRole`.
  static bool allowsRoleCsv(String? rolesCsv, String permission) {
    if (rolesCsv == null || rolesCsv.isEmpty) {
      return false;
    }
    return allowsRoles(rolesCsv.split(',').map((role) => role.trim()), permission);
  }

  static bool hasAnyRole(User user, Set<String> roles) {
    return rolesOf(user).any(roles.contains);
  }

  static bool hasAnyRoleCsv(String? rolesCsv, Set<String> roles) {
    if (rolesCsv == null || rolesCsv.isEmpty) {
      return false;
    }
    return rolesCsv
        .split(',')
        .map((role) => role.trim())
        .any(roles.contains);
  }

  static bool isAdmin(User user) => hasAnyRole(user, RoleGroups.admin);
  static bool isManagerOrAdmin(User user) => hasAnyRole(user, RoleGroups.manager);
  static bool isStaff(User user) => hasAnyRole(user, RoleGroups.staff);
  static bool isClientsViewer(User user) =>
      hasAnyRole(user, RoleGroups.clientsView);
  static bool isClient(User user) => hasAnyRole(user, const {'client'});
  static bool isExecutor(User user) => hasAnyRole(user, const {'executor'});

  /// Исполнитель без управленческих/тренерских ролей видит только свои записи.
  static bool isExecutorOnly(User user) {
    return isExecutor(user) && !isStaff(user);
  }
}
