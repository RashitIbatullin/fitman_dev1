import 'package:equatable/equatable.dart';
import 'package:fitman_app/modules/clients/widgets/ai_prompt_view.dart';
import 'package:fitman_app/modules/clients/providers/training_catalogs_provider.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:intl/intl.dart';

import '../../users/providers/auth_provider.dart';
import '../providers/analysis_provider.dart';

// Provider for the initial system recommendation
class RecommendationParams extends Equatable {
  final String clientId;
  final String? measurementId;

  const RecommendationParams({required this.clientId, this.measurementId});

  @override
  List<Object?> get props => [clientId, measurementId];
}

final recommendationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, RecommendationParams>((ref, params) async {
  return ApiService.getRecommendation(params.clientId,
      measurementId: params.measurementId);
});

// Main Screen Widget
class SystemRecommendationScreen extends StatelessWidget {
  final AnthropometryMeasurement measurement;
  final String clientId;

  const SystemRecommendationScreen(
      {super.key, required this.measurement, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рекомендации системы')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _RecommendationView(
          measurement: measurement,
          clientId: clientId,
        ),
      ),
    );
  }
}

// Stateful View for handling on-demand prompt generation
class _RecommendationView extends ConsumerStatefulWidget {
  final AnthropometryMeasurement measurement;
  final String clientId;

  const _RecommendationView(
      {required this.measurement, required this.clientId});

  @override
  ConsumerState<_RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends ConsumerState<_RecommendationView> {
  bool _isLoadingPrompt = false;
  bool _isPromptVisible = false;
  String _simplePrompt = '';
  String _professionalPrompt = '';

  Future<void> _generateAndShowPrompts() async {
    setState(() {
      _isLoadingPrompt = true;
    });

    try {
      // 1. Fetch all data on-demand
      final client = await ref.read(userProvider(widget.clientId).future);
      final fixedInfo =
          await ref.read(fixedAnthropometryProvider(widget.clientId).future);
      final somatotype =
          await ref.read(somatotypeStringProvider(widget.clientId).future);
      final goals = await ref.read(trainingGoalsProvider.future);
      final levels = await ref.read(trainingLevelsProvider.future);

      // 2. Process data
      final goalId = client.clientProfile?.goalTrainingId;
      final goalName = goals
          .firstWhere((g) => g.id == goalId,
              orElse: () => const GoalTraining(id: '', name: 'не указана'))
          .name;

      final levelId = client.clientProfile?.levelTrainingId;
      final levelName = levels
          .firstWhere((l) => l.id == levelId,
              orElse: () => const LevelTraining(id: '', name: 'не указан'))
          .name;
      
      final age = client.age ?? 'не указан';
      final gender = client.gender ?? 'не указан';
      final height = fixedInfo?.height.toStringAsFixed(0) ?? 'не указан';
      final coeffActivity = client.clientProfile?.coeffActivity.toString() ?? 'не указан';

      // 3. Generate prompts
      setState(() {
        _simplePrompt = _generateSimplePrompt(
            age: age.toString(),
            gender: gender,
            height: height,
            goalName: goalName,
            levelName: levelName,
            somatotype: somatotype,
            coeffActivity: coeffActivity,
            measurement: widget.measurement);

        _professionalPrompt = _generateProfessionalPrompt(
            user: client,
            age: age.toString(),
            gender: gender,
            height: height,
            goalName: goalName,
            levelName: levelName,
            somatotype: somatotype,
            coeffActivity: coeffActivity,
            measurement: widget.measurement);
            
        _isPromptVisible = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка генерации промпта: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPrompt = false;
        });
      }
    }
  }

  String _generateSimplePrompt({
    required String age,
    required String gender,
    required String height,
    required String goalName,
    required String levelName,
    required String somatotype,
    required String coeffActivity,
    required AnthropometryMeasurement measurement,
  }) {
    final details = [
      'вес: ${measurement.weight.toStringAsFixed(1)} кг',
      'обхват плеч: ${measurement.shouldersCirc} см',
      'обхват груди: ${measurement.breastCirc} см',
      'обхват талии: ${measurement.waistCirc} см',
      'обхват бедер: ${measurement.hipsCirc} см',
      if (measurement.fatPercentage != null) 'процент жира: ${measurement.fatPercentage!.toStringAsFixed(1)}%',
      if (measurement.muscleMass != null) 'мышечная масса: ${measurement.muscleMass!.toStringAsFixed(1)} кг',
    ];
    final measurementDetails = details.join(', ');

    return 'Сформируй персональные рекомендации по тренировкам и питанию для клиента. '
        'Отвечай в стиле дружелюбного и поддерживающего фитнес-тренера. '
        'Данные клиента: пол $gender, возраст $age лет, рост $height см, коэффициент активности $coeffActivity. '
        'Его(ее) цель: "$goalName", уровень подготовки: "$levelName". '
        'Тип телосложения (соматотип): $somatotype. '
        'Данные последнего замера от ${DateFormat('dd.MM.yyyy').format(measurement.dateTime)}: $measurementDetails.';
  }

  String _generateProfessionalPrompt({
    required User user,
    required String age,
    required String gender,
    required String height,
    required String goalName,
    required String levelName,
    required String somatotype,
    required String coeffActivity,
    required AnthropometryMeasurement measurement,
  }) {
    final measurementDetailsMap = {
      'Вес, кг': measurement.weight.toStringAsFixed(1),
      'Обхват плеч, см': measurement.shouldersCirc.toString(),
      'Обхват груди, см': measurement.breastCirc.toString(),
      'Обхват талии, см': measurement.waistCirc.toString(),
      'Обхват бедер, см': measurement.hipsCirc.toString(),
      if (measurement.fatPercentage != null)
        'Процент жира, %': measurement.fatPercentage!.toStringAsFixed(1),
      if (measurement.muscleMass != null)
        'Мышечная масса, кг': measurement.muscleMass!.toStringAsFixed(1),
    };
    final measurementDetails = measurementDetailsMap.entries
        .map((e) => '- ${e.key}: ${e.value}')
        .join('\n');

    return 'Задание: Проанализируй данные клиента и подготовь развернутые рекомендации для фитнес-тренера.\n'
        'Цель: Помочь тренеру составить или скорректировать программу тренировок и питания.\n'
        'Формат ответа: Структурированный текст с использованием профессиональной терминологии. Включи анализ текущих показателей, рисков (если есть) и предложи конкретные направления для работы.\n\n'
        '# Входные данные\n\n'
        '## Профиль клиента\n'
        '- **Пол:** $gender\n'
        '- **Возраст:** $age\n'
        '- **Цель тренировок:** $goalName\n'
        '- **Уровень подготовки:** $levelName\n'
        '- **Коэффициент активности:** $coeffActivity\n\n'
        '## Антропометрические данные\n'
        '- **Рост (см):** $height\n'
        '- **Соматотип:** $somatotype\n'
        '- **Замер от ${DateFormat('yyyy-MM-dd').format(measurement.dateTime)}:**\n'
        '$measurementDetails';
  }

  @override
  Widget build(BuildContext context) {
    final params = RecommendationParams(
        clientId: widget.clientId, measurementId: widget.measurement.id);
    final recAsync = ref.watch(recommendationProvider(params));
    final currentUser = ref.watch(authProvider).value?.user;
    final bool isStaff = currentUser?.roles.any((r) => r.name != 'client') ?? false;

    return ListView(
      children: [
        recAsync.when(
          data: (rec) {
            const defaultMessage =
                'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.';
            final recText = rec['client_recommendation']?.toString();
            final displayText = (recText == null ||
                    recText.contains(defaultMessage) ||
                    recText.isEmpty)
                ? defaultMessage
                : recText;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Замер от ${DateFormat('dd.MM.yyyy HH:mm', 'ru').format(widget.measurement.dateTime.toLocal())}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    Text(displayText),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Ошибка загрузки рекомендации: $e'),
        ),
        const SizedBox(height: 16),
        if (_isLoadingPrompt)
          const Center(child: CircularProgressIndicator())
        else if (_isPromptVisible)
          AiPromptView(
            simplePrompt: _simplePrompt,
            professionalPrompt: _professionalPrompt,
            isStaff: isStaff,
          )
        else
          Center(
            child: ElevatedButton(
              onPressed: _generateAndShowPrompts,
              child: const Text('Сгенерировать промпт для ИИ'),
            ),
          ),
      ],
    );
  }
}
