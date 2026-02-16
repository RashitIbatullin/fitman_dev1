import 'dart:convert';
import 'package:fitman_app/screens/client_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../modules/users/models/user.dart';
import '../modules/roles/models/role.dart';
import '../services/api_service.dart';

// 1. Единый класс состояния аутентификации
@immutable
class AuthState {
  final User? user;
  final Role? selectedRole;

  const AuthState({this.user, this.selectedRole});

  AuthState copyWith({User? user, Role? selectedRole}) {
    return AuthState(
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

// 2. Notifier управляет единым состоянием AuthState
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  // A simple comment to try and force analyzer refresh.
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    try {
      // First, ensure the token is loaded from prefs into the ApiService
      await ApiService.init();
      
      // If there's no token, we are not logged in.
      if (ApiService.currentToken == null) {
        state = AsyncValue.data(const AuthState(user: null, selectedRole: null));
        return;
      }

      // Validate the token and get fresh user data
      final user = await ApiService.checkTokenAndGetUser();
      
      // If validation is successful, update user data in storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      Role? selectedRole;
      if (user.roles.length == 1) {
        selectedRole = user.roles.first;
      }
      
      state = AsyncValue.data(
        AuthState(user: user, selectedRole: selectedRole),
      );

    } catch (e) {
      // This catch block is CRUCIAL. If checkTokenAndGetUser fails (e.g., 401 error),
      // we land here. We must log out the user.
      print('[_loadStoredUser] Token validation failed: $e. Logging out.');
      // Don't call logout() directly as it might cause state issues during build.
      // Just set the state to unauthenticated. The logout method will clear storage.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      state = AsyncValue.data(const AuthState(user: null, selectedRole: null));
    }
  }

  Future<void> login(String email, String password) async {
    print('[AuthNotifier] Login called for $email');
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.login(email, password);
      await _storeAuthData(authResponse);

      Role? selectedRole;
      if (authResponse.user.roles.length == 1) {
        selectedRole = authResponse.user.roles.first;
      }

      print(
        '[AuthNotifier] Login success. User: ${authResponse.user.email}, Roles: ${authResponse.user.roles.map((r) => r.name)}, SelectedRole: ${selectedRole?.name}',
      );

      // Атомарно обновляем состояние с пользователем и выбранной ролью
      state = AsyncValue.data(
        AuthState(user: authResponse.user, selectedRole: selectedRole),
      );
    } catch (e, st) {
      print('[AuthNotifier] Login error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void logout() async {
    print('[AuthNotifier] Logout called.');
    print('[AuthNotifier] State before logout: ${state.value}');
    try {
      await ApiService.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      _ref.read(clientDashboardIndexProvider.notifier).state = 0;
      state = AsyncValue.data(const AuthState(user: null, selectedRole: null));
      print('[AuthNotifier] Logout successful.');
      print('[AuthNotifier] State after logout: ${state.value}');
    } catch (e, st) {
      print('[AuthNotifier] Logout error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // Метод для установки роли, выбранной на экране RoleSelectionScreen
  void setSelectedRole(Role role) {
    state = state.whenData((value) => value.copyWith(selectedRole: role));
  }

  // Метод для обновления данных пользователя в состоянии
  Future<void> updateUser(User user) async {
    state = state.whenData((value) {
      // Сохраняем обновленного пользователя в SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('user_data', jsonEncode(user.toJson()));
      });
      // Возвращаем новое состояние, сохраняя выбранную роль
      return value.copyWith(user: user);
    });
  }

  Future<void> _storeAuthData(AuthResponse authResponse) async {
    await ApiService.saveToken(authResponse.token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(authResponse.user.toJson()));
  }

  Future<void> register(
    String email,
    String password,
    String firstName,
    String lastName,
    List<String> roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  ) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        roles: roles,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      await _storeAuthData(authResponse);

      Role? selectedRole;
      if (authResponse.user.roles.length == 1) {
        selectedRole = authResponse.user.roles.first;
      }

      state = AsyncValue.data(
        AuthState(user: authResponse.user, selectedRole: selectedRole),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// 3. Провайдер теперь предоставляет AsyncValue<AuthState>
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) => AuthNotifier(ref),
);
