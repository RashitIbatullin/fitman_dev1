import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/users/repositories/user_repository.dart';
import 'package:fitman_backend/modules/users/services/user_service.dart';

/// Сборка зависимостей модуля пользователей.
class UserProviders {
  UserProviders._();

  static final UserProviders instance = UserProviders._();

  factory UserProviders() => instance;

  late final UserRepository userRepository = UserRepositoryImpl(Database());
  late final UserService userService = UserService(
    userRepository,
    const AuditService(),
    Database(),
  );
}
