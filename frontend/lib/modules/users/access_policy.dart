import 'package:fitman_common/fitman_common.dart';

/// Локальная политика UI-доступа.
///
/// Промежуточный шаг: те же группы ролей, что на бэкенде.
/// Позже будет заменена правами из `/api/me/permissions`.
abstract final class AppAccess {
  static const Set<String> adminRoles = {'admin'};
  static const Set<String> managerRoles = {'admin', 'manager'};
  static const Set<String> staffRoles = {
    'admin',
    'manager',
    'trainer',
    'instructor',
  };
  static const Set<String> servicesStaffRoles = {
    'admin',
    'manager',
    'trainer',
    'instructor',
    'executor',
  };

  static Set<String> rolesOf(User user) {
    return user.roles.map((role) => role.name).toSet();
  }

  static bool hasAnyRole(User? user, Set<String> roles) {
    if (user == null) {
      return false;
    }
    return rolesOf(user).any(roles.contains);
  }

  static bool isAdmin(User? user) => hasAnyRole(user, adminRoles);
  static bool isManagerOrAdmin(User? user) =>
      hasAnyRole(user, managerRoles);
  static bool isStaff(User? user) => hasAnyRole(user, staffRoles);
  static bool isServicesStaff(User? user) =>
      hasAnyRole(user, servicesStaffRoles);
  static bool isClient(User? user) => hasAnyRole(user, const {'client'});

  static bool isExecutorOnly(User? user) {
    return hasAnyRole(user, const {'executor'}) && !isStaff(user);
  }
}
