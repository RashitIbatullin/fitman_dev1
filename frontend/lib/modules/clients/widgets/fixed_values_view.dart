import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';

final fixedAnthropometryProvider =
    FutureProvider.family<AnthropometryFixed?, String>((ref, clientId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    // Return null or throw an exception if the user is not authenticated
    // and this view should not be displayed.
    return null;
  }
  
  final userRoles = user.roles.map((r) => r.name).toSet();
  final isStaff = userRoles.contains('admin') || userRoles.contains('trainer') || userRoles.contains('instructor') || userRoles.contains('manager');

  if (isStaff) {
    return ApiService.getFixedAnthropometryForClient(clientId);
  } else {
    // A client can only view their own data.
    if (user.id == clientId) {
      return ApiService.getFixedAnthropometry();
    }
    // A client cannot view another client's data.
    return null; 
  }
});

class FixedValuesView extends ConsumerStatefulWidget {
  final String clientId;
  const FixedValuesView({super.key, required this.clientId});

  @override
  ConsumerState<FixedValuesView> createState() => _FixedValuesViewState();
}

class _FixedValuesViewState extends ConsumerState<FixedValuesView> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _wristController = TextEditingController();
  final _ankleController = TextEditingController();

  // Store initial values to compare for changes
  String _initialHeight = '';
  String _initialWrist = '';
  String _initialAnkle = '';

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_updateButtonState);
    _wristController.addListener(_updateButtonState);
    _ankleController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final bool isChanged = _heightController.text != _initialHeight ||
        _wristController.text != _initialWrist ||
        _ankleController.text != _initialAnkle;

    if (_isButtonEnabled != isChanged) {
      setState(() {
        _isButtonEnabled = isChanged;
      });
    }
  }

  @override
  void dispose() {
    _heightController.removeListener(_updateButtonState);
    _wristController.removeListener(_updateButtonState);
    _ankleController.removeListener(_updateButtonState);
    _heightController.dispose();
    _wristController.dispose();
    _ankleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isButtonEnabled || !mounted) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        final fixedData =
            ref.read(fixedAnthropometryProvider(widget.clientId)).asData?.value;

        final dataToSave = (fixedData ??
                AnthropometryFixed(
                  userId: widget.clientId,
                ))
            .copyWith(
          height: int.tryParse(_heightController.text),
          wristCirc: int.tryParse(_wristController.text),
          ankleCirc: int.tryParse(_ankleController.text),
        );

        await ApiService.saveFixedAnthropometryForClient(widget.clientId, dataToSave);

        ref.invalidate(fixedAnthropometryProvider(widget.clientId));
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Данные успешно сохранены'),
              backgroundColor: Colors.green),
        );
        if (mounted) {
           // Update initial values after successful save
          _initialHeight = _heightController.text;
          _initialWrist = _wristController.text;
          _initialAnkle = _ankleController.text;
          _updateButtonState(); // Recalculate button state
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value.user;
    final roles = user?.roles.map((r) => r.name).toSet() ?? {};
    final canEdit = roles.contains('admin') ||
        roles.contains('trainer') ||
        roles.contains('instructor') ||
        roles.contains('manager');
        
    final asyncData = ref.watch(fixedAnthropometryProvider(widget.clientId));

    return asyncData.when(
      data: (fixedData) {
        // Populate controllers and set initial values for comparison
        if (_heightController.text.isEmpty && fixedData?.height != null) {
          _heightController.text = fixedData!.height.toString();
          _initialHeight = _heightController.text;
        }
        if (_wristController.text.isEmpty && fixedData?.wristCirc != null) {
          _wristController.text = fixedData!.wristCirc.toString();
          _initialWrist = _wristController.text;
        }
        if (_ankleController.text.isEmpty && fixedData?.ankleCirc != null) {
          _ankleController.text = fixedData!.ankleCirc.toString();
          _initialAnkle = _ankleController.text;
        }
        
        if(canEdit) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtonState());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _heightController,
                  readOnly: !canEdit,
                  decoration: const InputDecoration(labelText: 'Рост (см)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _wristController,
                  readOnly: !canEdit,
                  decoration:
                      const InputDecoration(labelText: 'Обхват запястья (см)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ankleController,
                  readOnly: !canEdit,
                  decoration:
                      const InputDecoration(labelText: 'Обхват лодыжки (см)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                if (canEdit)
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _isButtonEnabled ? _submit : null,
                      child: const Text('Сохранить'),
                    ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Ошибка загрузки: $e')),
    );
  }
}
