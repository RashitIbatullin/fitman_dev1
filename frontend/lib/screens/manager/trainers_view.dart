import 'package:fitman_app/modules/users/models/user.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

// Провайдер для получения тренеров для конкретного менеджера
final assignedTrainersProvider = FutureProvider.family<List<User>, int>((
  ref,
  managerId,
) async {
  final user = ref.watch(authProvider).value?.user;
  // We can only get trainers if we are an admin.
  if (user?.roles.any((role) => role.name == 'admin') ?? false) {
    return ApiService.getAssignedTrainers(managerId);
  }
  return [];
});

class TrainersView extends ConsumerWidget {
  final int managerId;
  const TrainersView({super.key, required this.managerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainersAsyncValue = ref.watch(assignedTrainersProvider(managerId));

    return trainersAsyncValue.when(
      data: (trainers) {
        if (trainers.isEmpty) {
          return const Center(child: Text('Нет назначенных тренеров.'));
        }
        return ListView.builder(
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            final trainer = trainers[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(trainer.fullName),
              subtitle: Text(trainer.email),
              onTap: () {
                // TODO: Implement navigation to trainer details
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Ошибка загрузки тренеров: $error')),
    );
  }
}
