// ignore_for_file: use_build_context_synchronously, require_trailing_commas

import 'dart:async';

import 'package:fitman_app/models/anthropometry_data.dart';
import 'package:fitman_app/models/whtr_profiles.dart';
import 'package:fitman_app/providers/recommendation_provider.dart';
import 'package:fitman_app/screens/client/photo_comparison_screen.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/utils/body_shape_calculator.dart';
import 'package:fitman_app/utils/body_shape_helper.dart';

final anthropometryProvider =
FutureProvider.family<AnthropometryData, int?>((ref, clientId) {
  final authState = ref.watch(authProvider);

  return authState.when(
    data: (authData) async {
      final user = authData.user;
      if (user == null) throw Exception('User not authenticated');

      final bool isAdmin = user.roles.any((r) => r.name == 'admin');
      Map<String, dynamic> data;
      if (isAdmin && clientId != null) {
        data = await ApiService.getAnthropometryDataForClient(clientId);
      } else {
        data = await ApiService.getOwnAnthropometryData();
      }
      return AnthropometryData.fromJson(data);
    },
    loading: () => Completer<AnthropometryData>().future,
    error: (e, s) => throw e,
  );
});

// A single provider to get both WHtR profiles at once
final whtrProfilesProvider =
FutureProvider.family<WhtrProfiles, int?>((ref, clientId) {
  final authState = ref.watch(authProvider);

  return authState.when(
    data: (authData) async {
      final user = authData.user;
      if (user == null) throw Exception('User not authenticated');

      final bool isAdmin = user.roles.any((r) => r.name == 'admin');
      if (isAdmin && clientId != null) {
        return ApiService.getWhtrProfilesForClient(clientId);
      } else {
        return ApiService.getWhtrProfiles();
      }
    },
    loading: () => Completer<WhtrProfiles>().future,
    error: (e, s) => throw e,
  );
});

class AnthropometryScreen extends ConsumerStatefulWidget {
  final int? clientId;
  const AnthropometryScreen({super.key, this.clientId});

  @override
  ConsumerState<AnthropometryScreen> createState() =>
      _AnthropometryScreenState();
}

class _AnthropometryScreenState extends ConsumerState<AnthropometryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _startPhotoUrl;
  String? _finishPhotoUrl;
  DateTime? _startPhotoDateTime;
  DateTime? _finishPhotoDateTime;
  String? _startProfilePhotoUrl;
  String? _finishProfilePhotoUrl;
  DateTime? _startProfilePhotoDateTime;
  DateTime? _finishProfilePhotoDateTime;
  bool _isFixedEditing = false;
  bool _isStartEditing = false;
  bool _isFinishEditing = false;
  final _formKey = GlobalKey<FormState>();
  String? _startBodyShape;
  String? _finishBodyShape;

  Future<String>? _somatotypeProfileFuture;

  // Controllers
  late TextEditingController _heightController;
  late TextEditingController _wristCircController;
  late TextEditingController _ankleCircController;
  late TextEditingController _startWeightController;
  late TextEditingController _startShouldersCircController;
  late TextEditingController _startBreastCircController;
  late TextEditingController _startWaistCircController;
  late TextEditingController _startHipsCircController;
  late TextEditingController _finishWeightController;
  late TextEditingController _finishShouldersCircController;
  late TextEditingController _finishBreastCircController;
  late TextEditingController _finishWaistCircController;
  late TextEditingController _finishHipsCircController;

  bool _controllersInitialized = false;

  void _fetchSomatotypeProfile() {
    final user = ref.read(authProvider).value?.user;
    if (user == null) return;

    final bool isAdmin = user.roles.any((r) => r.name == 'admin');

    setState(() {
      if (isAdmin && widget.clientId != null) {
        _somatotypeProfileFuture =
            ApiService.getSomatotypeProfileForClient(widget.clientId!);
      } else {
        _somatotypeProfileFuture = ApiService.getSomatotypeProfile();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Refresh recommendations when the "Рекомендации" tab (index 3) is selected.
      if (!_tabController.indexIsChanging && _tabController.index == 3) {
        if (widget.clientId != null) {
          ref.invalidate(recommendationProvider(widget.clientId!));
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeControllers(
      AnthropometryFixed fixed,
      AnthropometryMeasurements start,
      AnthropometryMeasurements finish,
      ) {
    _heightController =
        TextEditingController(text: fixed.height?.toString() ?? '');
    _wristCircController =
        TextEditingController(text: fixed.wristCirc?.toString() ?? '');
    _ankleCircController =
        TextEditingController(text: fixed.ankleCirc?.toString() ?? '');

    _startWeightController =
        TextEditingController(text: start.weight?.toString() ?? '');
    _startShouldersCircController =
        TextEditingController(text: start.shouldersCirc?.toString() ?? '');
    _startBreastCircController =
        TextEditingController(text: start.breastCirc?.toString() ?? '');
    _startWaistCircController =
        TextEditingController(text: start.waistCirc?.toString() ?? '');
    _startHipsCircController =
        TextEditingController(text: start.hipsCirc?.toString() ?? '');

    _finishWeightController =
        TextEditingController(text: finish.weight?.toString() ?? '');
    _finishShouldersCircController =
        TextEditingController(text: finish.shouldersCirc?.toString() ?? '');
    _finishBreastCircController =
        TextEditingController(text: finish.breastCirc?.toString() ?? '');
    _finishWaistCircController =
        TextEditingController(text: finish.waistCirc?.toString() ?? '');
    _finishHipsCircController =
        TextEditingController(text: finish.hipsCirc?.toString() ?? '');

    _startBodyShape = calculateBodyShape(
      shouldersCirc: start.shouldersCirc,
      waistCirc: start.waistCirc,
      hipsCirc: start.hipsCirc,
    );
    _finishBodyShape = calculateBodyShape(
      shouldersCirc: finish.shouldersCirc,
      waistCirc: finish.waistCirc,
      hipsCirc: finish.hipsCirc,
    );
  }

  @override
  Widget build(BuildContext context) {
    final anthropometryDataAsync =
    ref.watch(anthropometryProvider(widget.clientId));
    final authState = ref.watch(authProvider);
    final loggedInUser = authState.value?.user;

    return anthropometryDataAsync.when(
      data: (anthropometryData) {
        if (!_controllersInitialized) {
          _initializeControllers(anthropometryData.fixed,
              anthropometryData.start, anthropometryData.finish);
          _startPhotoUrl = anthropometryData.start.photo;
          _finishPhotoUrl = anthropometryData.finish.photo;
          _startPhotoDateTime = anthropometryData.start.photoDateTime;
          _finishPhotoDateTime = anthropometryData.finish.photoDateTime;
          _startProfilePhotoUrl = anthropometryData.start.profilePhoto;
          _finishProfilePhotoUrl = anthropometryData.finish.profilePhoto;
          _startProfilePhotoDateTime =
              anthropometryData.start.profilePhotoDateTime;
          _finishProfilePhotoDateTime =
              anthropometryData.finish.profilePhotoDateTime;
          _controllersInitialized = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchSomatotypeProfile();
          });
        }

        final canEdit = loggedInUser != null &&
            (!loggedInUser.roles.any((r) => r.name == 'client') ||
                loggedInUser.roles.length > 1);

        return _buildMainContent(
          context,
          anthropometryData,
          canEdit,
        );
      },
      loading: () => _buildLoading(),
      error: (e, s) => _buildError(e),
    );
  }

  Widget _buildMainContent(
      BuildContext context,
      AnthropometryData anthropometryData,
      bool canEdit,
      ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTabBar(),
          _buildTabView(anthropometryData, canEdit),
          _buildPhotoComparisonButton(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).colorScheme.primary,
      indicatorColor: Theme.of(context).colorScheme.primary,
      tabs: const [
        Tab(text: 'Фиксированные'),
        Tab(text: 'Начальные'),
        Tab(text: 'Конечные'),
        Tab(text: 'Рекомендации'),
      ],
    );
  }

  Widget _buildTabView(AnthropometryData anthropometryData, bool canEdit) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildFixedTab(anthropometryData, canEdit),
          _buildStartTab(anthropometryData, canEdit),
          _buildFinishTab(anthropometryData, canEdit),
          _buildRecommendationsTab(),
        ],
      ),
    );
  }

  Widget _buildFixedTab(AnthropometryData anthropometryData, bool canEdit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _FixedMeasurementsCard(
        heightController: _heightController,
        wristCircController: _wristCircController,
        ankleCircController: _ankleCircController,
        canEdit: canEdit,
        isEditing: _isFixedEditing,
        onEdit: () => setState(() => _isFixedEditing = true),
        onSave: () => _saveFixedData(anthropometryData),
        onCancel: () => _cancelFixedEdit(anthropometryData),
        somatotypeProfileFuture: _somatotypeProfileFuture,
        onShowSomatotypeHelp: _showSomatotypeHelp,
      ),
    );
  }

  Widget _buildStartTab(AnthropometryData anthropometryData, bool canEdit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _MeasurementsCard(
        title: 'Начальные значения',
        type: 'start',
        weightController: _startWeightController,
        shouldersCircController: _startShouldersCircController,
        breastCircController: _startBreastCircController,
        waistCircController: _startWaistCircController,
        hipsCircController: _startHipsCircController,
        isEditing: _isStartEditing,
        canEdit: canEdit,
        bodyShape: _startBodyShape,
        onEdit: () => setState(() => _isStartEditing = true),
        onSave: () => _saveStartData(),
        onCancel: () => _cancelStartEdit(anthropometryData),
        onShowBodyShapeHelp: _showBodyShapeHelp,
        startWeightController: _startWeightController,
        startShouldersCircController: _startShouldersCircController,
        startBreastCircController: _startBreastCircController,
        startWaistCircController: _startWaistCircController,
        startHipsCircController: _startHipsCircController,
        clientId: widget.clientId,
      ),
    );
  }

  Widget _buildFinishTab(AnthropometryData anthropometryData, bool canEdit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _MeasurementsCard(
        title: 'Конечные значения',
        type: 'finish',
        weightController: _finishWeightController,
        shouldersCircController: _finishShouldersCircController,
        breastCircController: _finishBreastCircController,
        waistCircController: _finishWaistCircController,
        hipsCircController: _finishHipsCircController,
        isEditing: _isFinishEditing,
        canEdit: canEdit,
        bodyShape: _finishBodyShape,
        onEdit: () => setState(() => _isFinishEditing = true),
        onSave: () => _saveFinishData(),
        onCancel: () => _cancelFinishEdit(anthropometryData),
        onShowBodyShapeHelp: _showBodyShapeHelp,
        startWeightController: _startWeightController,
        startShouldersCircController: _startShouldersCircController,
        startBreastCircController: _startBreastCircController,
        startWaistCircController: _startWaistCircController,
        startHipsCircController: _startHipsCircController,
        clientId: widget.clientId,
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _RecommendationCard(clientId: widget.clientId),
    );
  }

  Widget _buildPhotoComparisonButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _navigateToPhotoComparison(),
          child: const Text('Сравнение по фото'),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(Object error) {
    return Center(child: Text('Ошибка загрузки антропометрии: $error'));
  }

  Future<void> _saveFixedData(AnthropometryData anthropometryData) async {
    if (_formKey.currentState!.validate()) {
      final currentHeight = int.tryParse(_heightController.text);
      final currentWristCirc = int.tryParse(_wristCircController.text);
      final currentAnkleCirc = int.tryParse(_ankleCircController.text);

      try {
        if (widget.clientId != null) {
          await ApiService.updateAnthropometryFixedForClient(
            clientId: widget.clientId!,
            height: currentHeight ?? 0,
            wristCirc: currentWristCirc ?? 0,
            ankleCirc: currentAnkleCirc ?? 0,
          );
        } else {
          await ApiService.updateAnthropometryFixed(
            height: currentHeight ?? 0,
            wristCirc: currentWristCirc ?? 0,
            ankleCirc: currentAnkleCirc ?? 0,
          );
        }
        ref.invalidate(anthropometryProvider(widget.clientId));
        ref.invalidate(whtrProfilesProvider(widget.clientId));
        setState(() {
          _isFixedEditing = false;
          _fetchSomatotypeProfile();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Фиксированные данные успешно обновлены!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Ошибка при сохранении фиксированных данных: $e')),
        );
      }
    }
  }

  void _cancelFixedEdit(AnthropometryData anthropometryData) {
    _heightController.text =
        anthropometryData.fixed.height?.toString() ?? '';
    _wristCircController.text =
        anthropometryData.fixed.wristCirc?.toString() ?? '';
    _ankleCircController.text =
        anthropometryData.fixed.ankleCirc?.toString() ?? '';
    setState(() => _isFixedEditing = false);
  }

  Future<void> _saveStartData() async {
    if (_formKey.currentState!.validate()) {
      final currentWeight = double.tryParse(_startWeightController.text);
      final currentShouldersCirc =
      int.tryParse(_startShouldersCircController.text);
      final currentBreastCirc = int.tryParse(_startBreastCircController.text);
      final currentWaistCirc = int.tryParse(_startWaistCircController.text);
      final currentHipsCirc = int.tryParse(_startHipsCircController.text);

      try {
        if (widget.clientId != null) {
          await ApiService.updateAnthropometryMeasurementsForClient(
            clientId: widget.clientId!,
            type: 'start',
            weight: currentWeight ?? 0.0,
            shouldersCirc: currentShouldersCirc ?? 0,
            breastCirc: currentBreastCirc ?? 0,
            waistCirc: currentWaistCirc ?? 0,
            hipsCirc: currentHipsCirc ?? 0,
          );
        } else {
          await ApiService.updateAnthropometryMeasurements(
            type: 'start',
            weight: currentWeight ?? 0.0,
            shouldersCirc: currentShouldersCirc ?? 0,
            breastCirc: currentBreastCirc ?? 0,
            waistCirc: currentWaistCirc ?? 0,
            hipsCirc: currentHipsCirc ?? 0,
          );
        }
        ref.invalidate(anthropometryProvider(widget.clientId));
        ref.invalidate(whtrProfilesProvider(widget.clientId));
        setState(() {
          _isStartEditing = false;
          _startBodyShape = calculateBodyShape(
            shouldersCirc: currentShouldersCirc,
            waistCirc: currentWaistCirc,
            hipsCirc: currentHipsCirc,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные Начало успешно обновлены!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении данных Начало: $e')),
        );
      }
    }
  }

  void _cancelStartEdit(AnthropometryData anthropometryData) {
    _startWeightController.text =
        anthropometryData.start.weight?.toString() ?? '';
    _startShouldersCircController.text =
        anthropometryData.start.shouldersCirc?.toString() ?? '';
    _startBreastCircController.text =
        anthropometryData.start.breastCirc?.toString() ?? '';
    _startWaistCircController.text =
        anthropometryData.start.waistCirc?.toString() ?? '';
    _startHipsCircController.text =
        anthropometryData.start.hipsCirc?.toString() ?? '';
    setState(() => _isStartEditing = false);
  }

  Future<void> _saveFinishData() async {
    if (_formKey.currentState!.validate()) {
      final currentWeight = double.tryParse(_finishWeightController.text);
      final currentShouldersCirc =
      int.tryParse(_finishShouldersCircController.text);
      final currentBreastCirc = int.tryParse(_finishBreastCircController.text);
      final currentWaistCirc = int.tryParse(_finishWaistCircController.text);
      final currentHipsCirc = int.tryParse(_finishHipsCircController.text);

      try {
        if (widget.clientId != null) {
          await ApiService.updateAnthropometryMeasurementsForClient(
            clientId: widget.clientId!,
            type: 'finish',
            weight: currentWeight ?? 0.0,
            shouldersCirc: currentShouldersCirc ?? 0,
            breastCirc: currentBreastCirc ?? 0,
            waistCirc: currentWaistCirc ?? 0,
            hipsCirc: currentHipsCirc ?? 0,
          );
        } else {
          await ApiService.updateAnthropometryMeasurements(
            type: 'finish',
            weight: currentWeight ?? 0.0,
            shouldersCirc: currentShouldersCirc ?? 0,
            breastCirc: currentBreastCirc ?? 0,
            waistCirc: currentWaistCirc ?? 0,
            hipsCirc: currentHipsCirc ?? 0,
          );
        }
        ref.invalidate(anthropometryProvider(widget.clientId));
        ref.invalidate(whtrProfilesProvider(widget.clientId));
        setState(() {
          _isFinishEditing = false;
          _finishBodyShape = calculateBodyShape(
            shouldersCirc: currentShouldersCirc,
            waistCirc: currentWaistCirc,
            hipsCirc: currentHipsCirc,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные Окончание успешно обновлены!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении данных Окончание: $e')),
        );
      }
    }
  }

  void _cancelFinishEdit(AnthropometryData anthropometryData) {
    _finishWeightController.text =
        anthropometryData.finish.weight?.toString() ?? '';
    _finishShouldersCircController.text =
        anthropometryData.finish.shouldersCirc?.toString() ?? '';
    _finishBreastCircController.text =
        anthropometryData.finish.breastCirc?.toString() ?? '';
    _finishWaistCircController.text =
        anthropometryData.finish.waistCirc?.toString() ?? '';
    _finishHipsCircController.text =
        anthropometryData.finish.hipsCirc?.toString() ?? '';
    setState(() => _isFinishEditing = false);
  }

  Future<void> _navigateToPhotoComparison() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoComparisonScreen(
          clientId: widget.clientId,
          initialStartPhotoUrl: _startPhotoUrl,
          initialFinishPhotoUrl: _finishPhotoUrl,
          initialStartPhotoDateTime: _startPhotoDateTime,
          initialFinishPhotoDateTime: _finishPhotoDateTime,
          initialStartProfilePhotoUrl: _startProfilePhotoUrl,
          initialFinishProfilePhotoUrl: _finishProfilePhotoUrl,
          initialStartProfilePhotoDateTime: _startProfilePhotoDateTime,
          initialFinishProfilePhotoDateTime: _finishProfilePhotoDateTime,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _startPhotoUrl = result['startPhotoUrl'];
        _finishPhotoUrl = result['finishPhotoUrl'];
        _startPhotoDateTime = result['startPhotoDateTime'];
        _finishPhotoDateTime = result['finishPhotoDateTime'];
        _startProfilePhotoUrl = result['startProfilePhotoUrl'];
        _finishProfilePhotoUrl = result['finishProfilePhotoUrl'];
        _startProfilePhotoDateTime = result['startProfilePhotoDateTime'];
        _finishProfilePhotoDateTime = result['finishProfilePhotoDateTime'];
      });
    }
  }

  void _showBodyShapeHelp(String? bodyShape) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Справка по типу фигуры'),
        content:
        SingleChildScrollView(child: Text(getBodyShapeHelpText(bodyShape))),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'))
        ],
      ),
    );
  }

  void _showSomatotypeHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Справка по соматотипу'),
          content: const SingleChildScrollView(
            child: Text(
              'Это экспериментальное определение генетического строения тела по методу ученого Соловьева. В расчет рекомендаций включается, только если одно из значений будет больше 70%.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}

class _FixedMeasurementsCard extends StatelessWidget {
  const _FixedMeasurementsCard({
    required this.heightController,
    required this.wristCircController,
    required this.ankleCircController,
    required this.canEdit,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.somatotypeProfileFuture,
    required this.onShowSomatotypeHelp,
  });

  final TextEditingController heightController;
  final TextEditingController wristCircController;
  final TextEditingController ankleCircController;
  final bool canEdit;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Future<String>? somatotypeProfileFuture;
  final VoidCallback onShowSomatotypeHelp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildHeightField(context),
            const SizedBox(height: 8),
            _buildSomatotypeSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Фиксированные значения',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.blue)),
        if (canEdit)
          _buildEditControls(isEditing, onEdit, onSave, onCancel),
      ],
    );
  }

  Widget _buildHeightField(BuildContext context) {
    return _buildEditableField(
      context,
      'Рост',
      heightController,
      isInt: true,
      isEditing: isEditing,
    );
  }

  Widget _buildSomatotypeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Определение соматотипа',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          _buildWristField(context),
          _buildAnkleField(context),
          if (!isEditing) _buildSomatotypeResult(context),
        ],
      ),
    );
  }

  Widget _buildWristField(BuildContext context) {
    return _buildEditableField(
      context,
      'Обхват запястья',
      wristCircController,
      isInt: true,
      isEditing: isEditing,
    );
  }

  Widget _buildAnkleField(BuildContext context) {
    return _buildEditableField(
      context,
      'Обхват лодыжки',
      ankleCircController,
      isInt: true,
      isEditing: isEditing,
    );
  }

  Widget _buildSomatotypeResult(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildSomatotypeHeader(context),
        const SizedBox(height: 8),
        _buildSomatotypeFutureBuilder(),
      ],
    );
  }

  Widget _buildSomatotypeHeader(BuildContext context) {
    return Row(
      children: [
        Text('Соматотип:',
            style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.help_outline, size: 20),
          onPressed: onShowSomatotypeHelp,
        ),
      ],
    );
  }

  Widget _buildSomatotypeFutureBuilder() {
    return FutureBuilder<String>(
      future: somatotypeProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Расчет...');
        } else if (snapshot.hasError) {
          return const Text('Недостаточно данных',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
        } else if (snapshot.hasData) {
          return Text(
            snapshot.data ?? 'Недостаточно данных',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          );
        } else {
          return const Text('Недостаточно данных для расчета.');
        }
      },
    );
  }
}

class _MeasurementsCard extends ConsumerWidget {
  const _MeasurementsCard({
    required this.title,
    required this.type,
    required this.weightController,
    required this.shouldersCircController,
    required this.breastCircController,
    required this.waistCircController,
    required this.hipsCircController,
    required this.isEditing,
    required this.canEdit,
    required this.bodyShape,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onShowBodyShapeHelp,
    required this.startWeightController,
    required this.startShouldersCircController,
    required this.startBreastCircController,
    required this.startWaistCircController,
    required this.startHipsCircController,
    required this.clientId,
  });

  final String title;
  final String type;
  final TextEditingController weightController;
  final TextEditingController shouldersCircController;
  final TextEditingController breastCircController;
  final TextEditingController waistCircController;
  final TextEditingController hipsCircController;
  final bool isEditing;
  final bool canEdit;
  final String? bodyShape;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final void Function(String?) onShowBodyShapeHelp;
  final int? clientId;
  final TextEditingController startWeightController;
  final TextEditingController startShouldersCircController;
  final TextEditingController startBreastCircController;
  final TextEditingController startWaistCircController;
  final TextEditingController startHipsCircController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildMeasurementFields(context),
            const SizedBox(height: 8),
            _buildBodyShapeSection(context),
            const SizedBox(height: 8),
            _buildWhtrSection(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.blue)),
        if (canEdit)
          _buildEditControls(isEditing, onEdit, onSave, onCancel),
      ],
    );
  }

  Widget _buildMeasurementFields(BuildContext context) {
    return Column(
      children: [
        _buildEditableField(
          context,
          'Вес',
          weightController,
          isDouble: true,
          isEditing: isEditing,
          startValue: type == 'finish' ? startWeightController.text : null,
        ),
        _buildEditableField(
          context,
          'Обхват плеч',
          shouldersCircController,
          isInt: true,
          isEditing: isEditing,
          startValue:
          type == 'finish' ? startShouldersCircController.text : null,
        ),
        _buildEditableField(
          context,
          'Обхват груди',
          breastCircController,
          isInt: true,
          isEditing: isEditing,
          startValue: type == 'finish' ? startBreastCircController.text : null,
        ),
        _buildEditableField(
          context,
          'Обхват талии',
          waistCircController,
          isInt: true,
          isEditing: isEditing,
          startValue: type == 'finish' ? startWaistCircController.text : null,
        ),
        _buildEditableField(
          context,
          'Обхват бедер',
          hipsCircController,
          isInt: true,
          isEditing: isEditing,
          startValue: type == 'finish' ? startHipsCircController.text : null,
        ),
      ],
    );
  }

  Widget _buildBodyShapeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBodyShapeHeader(context),
        const SizedBox(height: 8),
        _buildBodyShapeValue(),
      ],
    );
  }

  Widget _buildBodyShapeHeader(BuildContext context) {
    return Row(
      children: [
        Text('Тип фигуры', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.help_outline, size: 20),
          onPressed: () => onShowBodyShapeHelp(bodyShape),
        ),
      ],
    );
  }

  Widget _buildBodyShapeValue() {
    return Text(
      bodyShape ?? 'Недостаточно данных',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWhtrSection(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Индекс здоровья WHtR:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _buildWhtrIndicator(ref),
      ],
    );
  }

  Widget _buildWhtrIndicator(WidgetRef ref) {
    final whtrAsync = ref.watch(whtrProfilesProvider(clientId));

    return whtrAsync.when(
      data: (profiles) => _buildWhtrData(profiles),
      loading: () => _buildWhtrLoading(),
      error: (e, s) => _buildWhtrError(e),
    );
  }

  Widget _buildWhtrData(WhtrProfiles profiles) {
    final profile = type == 'start' ? profiles.start : profiles.finish;

    final colors = {
      'Риск истощения': Colors.red,
      'Норма': Colors.green,
      'Избыточный вес': Colors.orange,
      'Ожирение': Colors.red,
    };
    final color = colors[profile.gradation] ?? Colors.grey;
    final progress = (profile.ratio - 0.3).clamp(0.0, 1.0) / (0.7 - 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${profile.gradation} (коэф: ${profile.ratio.toStringAsFixed(2)})',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWhtrLoading() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Text('Расчет...'),
    );
  }

  Widget _buildWhtrError(Object error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text('Ошибка: $error', style: const TextStyle(color: Colors.red)),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  final int? clientId;

  const _RecommendationCard({this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (clientId == null) {
      return _buildNoClientIdCard();
    }

    final recommendationAsync = ref.watch(recommendationProvider(clientId!));
    return _buildRecommendationCard(context, recommendationAsync);
  }

  Widget _buildNoClientIdCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
              'ID клиента не указан, рекомендации не могут быть загружены.'),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, AsyncValue<Map<String, dynamic>> recommendationAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(context),
            const SizedBox(height: 16),
            _buildRecommendationContent(recommendationAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Персональные рекомендации',
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  Widget _buildRecommendationContent(
      AsyncValue<Map<String, dynamic>> recommendationAsync) {
    return recommendationAsync.when(
      data: (recommendation) => _buildRecommendationText(recommendation),
      loading: () => _buildLoadingIndicator(),
      error: (e, s) => _buildErrorText(e),
    );
  }

  Widget _buildRecommendationText(Map<String, dynamic> recommendation) {
    return Text(
      recommendation['client_recommendation'] ?? 'Рекомендация не найдена.',
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorText(Object error) {
    return Text(
      'Ошибка загрузки: $error',
      style: const TextStyle(color: Colors.red),
    );
  }
}

Widget _buildEditableField(
    BuildContext context,
    String label,
    TextEditingController controller, {
      bool isInt = false,
      bool isDouble = false,
      required bool isEditing,
      String? startValue,
    }) {
  Widget valueWidget;
  if (isEditing) {
    valueWidget = _buildTextField(label, controller, isInt, isDouble);
  } else {
    valueWidget = _buildDisplayText(context, label, controller, startValue,
        isInt: isInt, isDouble: isDouble);
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: valueWidget,
  );
}

Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isInt,
    bool isDouble,
    ) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    ),
    keyboardType: isInt || isDouble ? TextInputType.number : TextInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Поле не может быть пустым';
      }
      if (isInt && int.tryParse(value) == null) {
        return 'Введите целое число';
      }
      if (isDouble && double.tryParse(value) == null) {
        return 'Введите число';
      }
      return null;
    },
  );
}

Widget _buildDisplayText(
    BuildContext context,
    String label,
    TextEditingController controller,
    String? startValue, {
      bool isInt = false,
      bool isDouble = false,
    }) {
  String differenceText = _calculateDifferenceText(
    controller.text,
    startValue,
    isInt: isInt,
    isDouble: isDouble,
  );

  return RichText(
    text: TextSpan(
      style: Theme.of(context).textTheme.bodyMedium,
      children: [
        TextSpan(
          text: '$label: ${controller.text.isEmpty ? 'не указано' : controller.text}',
        ),
        if (differenceText.isNotEmpty)
          TextSpan(
            text: differenceText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
      ],
    ),
  );
}

String _calculateDifferenceText(
    String currentValue,
    String? startValue, {
      bool isInt = false,
      bool isDouble = false,
    }) {
  if (startValue == null) return '';

  if (isDouble) {
    final double? start = double.tryParse(startValue);
    final double? end = double.tryParse(currentValue);
    if (start != null && end != null) {
      final double diff = end - start;
      if (diff != 0) {
        return ' (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)})';
      }
    }
  } else {
    final int? start = int.tryParse(startValue);
    final int? end = int.tryParse(currentValue);
    if (start != null && end != null) {
      final int diff = end - start;
      if (diff != 0) return ' (${diff > 0 ? '+' : ''}$diff)';
    }
  }

  return '';
}

Widget _buildEditControls(
    bool isEditing,
    VoidCallback onEdit,
    VoidCallback onSave,
    VoidCallback onCancel,
    ) {
  return isEditing
      ? Row(
    children: [
      IconButton(icon: const Icon(Icons.save), onPressed: onSave),
      IconButton(icon: const Icon(Icons.cancel), onPressed: onCancel),
    ],
  )
      : IconButton(icon: const Icon(Icons.edit), onPressed: onEdit);
}