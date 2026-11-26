import '../../errors/app_exception.dart';

/// Бизнес-правила пользователей и ролей.
///
/// Вынесены из контроллера и сервиса, чтобы их можно было проверить
/// unit-тестами без БД и HTTP.
class UserPolicy {
  const UserPolicy._();

  /// Системные имена ролей из ТЗ.
  static const Set<String> allowedRoles = {
    'client',
    'instructor',
    'trainer',
    'manager',
    'admin',
  };

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9\s-]{7,15}$');

  /// Проверяет данные создания пользователя.
  ///
  /// Клиент может иметь только одну роль; сотрудник — одну или несколько.
  static void validateCreate({
    required String? email,
    required String? phone,
    required String password,
    required List<String> roles,
  }) {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      throw const ValidationException('Укажите email или телефон для входа');
    }
    validateEmail(email);
    validatePhone(phone);
    validatePassword(password);
    validateRoles(roles: roles);
  }

  /// Проверяет данные обновления профиля.
  static void validateUpdate({
    String? email,
    String? phone,
    bool archivedAtProvided = false,
    DateTime? archivedAt,
    String? archivedReason,
  }) {
    validateEmail(email);
    validatePhone(phone);

    if (archivedAtProvided &&
        archivedAt != null &&
        (archivedReason == null || archivedReason.trim().length < 5)) {
      throw const ValidationException(
        'Причина архивации обязательна и должна быть не короче 5 символов',
      );
    }
  }

  /// Проверяет набор ролей пользователя.
  static void validateRoles({required List<String> roles}) {
    if (roles.isEmpty) {
      throw const ValidationException(
        'У пользователя должна быть хотя бы одна роль',
      );
    }

    final unique = roles.toSet();
    if (unique.length != roles.length) {
      throw const ValidationException('Роли не должны повторяться');
    }

    for (final role in roles) {
      if (!allowedRoles.contains(role)) {
        throw ValidationException('Неизвестная роль: $role');
      }
    }

    if (unique.contains('client') && unique.length > 1) {
      throw const ValidationException(
        'Роль «Клиент» не может сочетаться с другими ролями',
      );
    }
  }

  /// Проверяет смену ролей с учётом текущего набора.
  ///
  /// Основную (единственную) роль удалить нельзя; клиент не может получить
  /// вторую роль, а сотрудник — стать клиентом.
  static void validateRoleChange({
    required List<String> currentRoles,
    required List<String> newRoles,
  }) {
    validateRoles(roles: newRoles);

    final current = currentRoles.toSet();
    final next = newRoles.toSet();

    if (next.contains('client') && !current.contains('client')) {
      throw const ValidationException(
        'Роль «Клиент» нельзя добавить сотруднику',
      );
    }
    if (current.contains('client') && next.any((role) => role != 'client')) {
      throw const ValidationException('Клиенту нельзя добавить другие роли');
    }
    if (current.isNotEmpty && next.isEmpty) {
      throw const ValidationException(
        'У пользователя должна остаться хотя бы одна роль',
      );
    }
    if (current.length == 1 && !next.contains(current.first)) {
      throw const ValidationException(
        'Нельзя удалить основную (единственную) роль пользователя',
      );
    }
  }

  /// Действие аудита по изменению признака архивации.
  static String actionFor({
    required bool wasArchived,
    required bool isArchived,
  }) {
    if (!wasArchived && isArchived) {
      return 'ARCHIVE';
    }
    if (wasArchived && !isArchived) {
      return 'RESTORE';
    }
    return 'UPDATE';
  }

  /// Проверяет и нормализует час уведомления (0–72).
  static int normalizeNotificationHour(int value) {
    if (value < 0 || value > 72) {
      throw const ValidationException(
        'Время уведомления должно быть от 0 до 72 часов',
      );
    }
    return value;
  }

  static void validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      throw const ValidationException('Неверный формат email');
    }
  }

  static void validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return;
    }
    if (!_phonePattern.hasMatch(phone)) {
      throw const ValidationException('Неверный формат телефона');
    }
  }

  /// Политика паролей из ТЗ: длина, регистр, цифра, спецсимвол.
  static void validatePassword(String password) {
    if (password.length < 8) {
      throw const ValidationException(
        'Пароль должен быть не короче 8 символов',
      );
    }
    if (!password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      throw const ValidationException(
        'Пароль должен содержать строчные и заглавные буквы, цифру и спецсимвол',
      );
    }
  }
}
