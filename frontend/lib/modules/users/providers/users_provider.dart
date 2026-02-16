import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../../services/api_service.dart';

// --- Provider to fetch a single user by their ID ---
final userByIdProvider = FutureProvider.family<User, int>((ref, userId) async {
  return ApiService.getUserById(userId);
});


class UsersState {
  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  final List<User> users;
  final bool isLoading;
  final String? error;

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UsersNotifier extends Notifier<UsersState> {
  @override
  UsersState build() {
    return const UsersState();
  }

  Future<void> fetchUsers({String? role}) async {
    try {
      state = state.copyWith(isLoading: true);
      final users = await ApiService.getUsers(role: role);
      state = state.copyWith(users: users, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final usersProvider = NotifierProvider<UsersNotifier, UsersState>(UsersNotifier.new);

final clientsProvider = Provider<List<User>>((ref) {
  final usersState = ref.watch(usersProvider);
  return usersState.users.where((user) => user.roles.any((role) => role.name == 'client')).toList();
});
