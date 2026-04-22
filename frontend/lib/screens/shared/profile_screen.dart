import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/modules/clients/providers/training_catalogs_provider.dart';

import '../../modules/users/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late String? _photoUrl;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  // State for form fields
  String? _selectedGoalId;
  String? _selectedLevelId;
  bool _isLoading = false;

  // Client profile specific state
  late bool _trackCalories;
  late double _coeffActivity;


  @override
  void initState() {
    super.initState();
    _photoUrl = widget.user.photoUrl;
    // Initialize from the nested clientProfile object
    _selectedGoalId = widget.user.clientProfile?.goalTrainingId;
    _selectedLevelId = widget.user.clientProfile?.levelTrainingId;
    _trackCalories = widget.user.clientProfile?.trackCalories ?? true;
    _coeffActivity = widget.user.clientProfile?.coeffActivity ?? 1.2;
  }

  bool _isDirty() {
    final profile = widget.user.clientProfile;
    return _selectedGoalId != profile?.goalTrainingId ||
        _selectedLevelId != profile?.levelTrainingId ||
        _trackCalories != profile?.trackCalories ||
        _coeffActivity != profile?.coeffActivity;
  }

  Future<void> _saveProfile() async {
    if (!_isDirty()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет изменений для сохранения.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authUser = ref.read(authProvider).value?.user;
      final isSelfEdit = (authUser != null) && (authUser.id == widget.user.id);

      late User updatedUser;

      final clientProfileData = {
        'goal_training_id': _selectedGoalId,
        'level_training_id': _selectedLevelId,
        'track_calories': _trackCalories,
        'coeff_activity': _coeffActivity,
      };

      if (isSelfEdit) {
        updatedUser = await ApiService.updateClientProfile(clientProfileData);
      } else {
        final request = UpdateUserRequest(
          id: widget.user.id,
          clientProfile: clientProfileData,
        );
        updatedUser = await ApiService.updateUser(request);
      }

      if (!mounted) return;

      ref.read(authProvider.notifier).updateUser(updatedUser);

      setState(() {
        _selectedGoalId = updatedUser.clientProfile?.goalTrainingId;
        _selectedLevelId = updatedUser.clientProfile?.levelTrainingId;
        _trackCalories = updatedUser.clientProfile?.trackCalories ?? true;
        _coeffActivity = updatedUser.clientProfile?.coeffActivity ?? 1.2;
        _photoUrl = updatedUser.photoUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль успешно обновлен', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления профиля: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value?.user;
    // Allow editing if the current user is not a client.
    final canEditClientProfile = currentUser != null && !currentUser.roles.any((r) => r.name == 'client');

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Center(
          child: Column(
            children: [
              RepaintBoundary(
                key: _repaintBoundaryKey,
                child: ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 1,
                      maxScale: 4,
                      child: _photoUrl != null
                          ? Image.network(
                              Uri.parse(ApiService.baseUrl).replace(path: _photoUrl!).toString(),
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.person, size: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileInfoCard(canEditClientProfile),
      ],
    );
  }

  Widget _buildProfileInfoCard(bool canEditClientProfile) {
    final isClientProfile = widget.user.roles.any((r) => r.name == 'client');

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(label: 'ФИО', value: widget.user.fullName),
            _buildInfoRow(label: 'Телефон', value: widget.user.phone ?? 'не указан'),
            _buildInfoRow(label: 'Пол', value: widget.user.gender ?? 'не указан'),
            _buildInfoRow(
                label: 'Дата рождения',
                value: widget.user.dateOfBirth != null
                    ? '${widget.user.dateOfBirth!.day}.${widget.user.dateOfBirth!.month}.${widget.user.dateOfBirth!.year}'
                    : 'не указана'),
            _buildInfoRow(
                label: 'Возраст',
                value: widget.user.age?.toString() ?? 'не указан'),
            _buildInfoRow(label: 'Email', value: widget.user.email),
            if (widget.user.roles.length > 1 && widget.user.roles.every((r) => r.name != 'client'))
              _buildRolesSection(),
            const Divider(height: 30),
            _buildSettingsSection(canEditClientProfile),
            if (isClientProfile && canEditClientProfile) ...[
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Сохранить изменения'),
                      ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRolesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SelectableText(
          'Роли',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.user.roles.map((role) => SelectableText('  - ${role.title}')),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsSection(bool canEdit) {
    final clientProfile = widget.user.clientProfile;
    final isClientRole = widget.user.roles.any((r) => r.name == 'client');
    final goalsAsync = ref.watch(trainingGoalsProvider);
    final levelsAsync = ref.watch(trainingLevelsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SelectableText('Настройки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const SelectableText('Получать уведомления'),
          value: widget.user.sendNotification,
          onChanged: null, // TODO: Implement settings change
        ),
        _buildInfoRow(
          label: 'Уведомлять за (часы)',
          value: widget.user.hourNotification.toString(),
        ),
        if (isClientRole && clientProfile != null) ...[
            SwitchListTile(
              title: const SelectableText('Отслеживать калории'),
              value: _trackCalories,
              onChanged: canEdit ? (value) => setState(() => _trackCalories = value) : null,
            ),
            _buildActivityCoeffRow(canEdit: canEdit),
            const SizedBox(height: 16),
            goalsAsync.when(
              data: (goals) => DropdownButtonFormField<String>(
                key: ValueKey<String>('goal_$_selectedGoalId'),
                initialValue: _selectedGoalId,
                decoration: const InputDecoration(labelText: 'Цель тренировок', border: OutlineInputBorder()),
                items: goals.map((goal) => DropdownMenuItem<String>(value: goal.id, child: Text(goal.name))).toList(),
                onChanged: canEdit ? (value) => setState(() => _selectedGoalId = value) : null,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Ошибка загрузки: $err'),
            ),
            const SizedBox(height: 16),
            levelsAsync.when(
              data: (levels) => DropdownButtonFormField<String>(
                key: ValueKey<String>('level_$_selectedLevelId'),
                initialValue: _selectedLevelId,
                decoration: const InputDecoration(labelText: 'Уровень подготовки', border: OutlineInputBorder()),
                items: levels.map((level) => DropdownMenuItem<String>(value: level.id, child: Text(level.name))).toList(),
                onChanged: canEdit ? (value) => setState(() => _selectedLevelId = value) : null,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Ошибка загрузки: $err'),
            ),
        ]
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SelectableText(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(value),
        ],
      ),
    );
  }

  Widget _buildActivityCoeffRow({required bool canEdit}) {
    const helpText = '''Коэффициент физической активности:
1.2 - Сидячий образ жизни (мало или нет физических нагрузок),
1.375 - Легкая активность (1-3 тренировки в неделю),
1.55 - Средняя активность (3-5 тренировок в неделю),
1.725 - Высокая активность (6-7 тренировок в неделю),
1.9 - Экстремальная активность (тяжелые тренировки 2 раза в день)''';

    final List<double> coefficients = [1.2, 1.375, 1.55, 1.725, 1.9];
    final currentCoeff = coefficients.contains(_coeffActivity) ? _coeffActivity : coefficients.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Коэффициент активности',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canEdit)
                  DropdownButton<double>(
                    value: currentCoeff,
                    items: coefficients
                        .map((coeff) => DropdownMenuItem(
                            value: coeff, child: Text(coeff.toString())))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _coeffActivity = newValue;
                        });
                      }
                    },
                  )
                else
                  SelectableText(_coeffActivity.toString()),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Коэффициент Активности'),
                        content: const SelectableText(helpText),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}