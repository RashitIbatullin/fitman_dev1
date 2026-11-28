import 'package:fitman_common/fitman_common.dart';

/// Основные вкладки каталога услуг.
enum ServiceCategory {
  training('Тренировки'),
  medical('Медицина'),
  cosmetology('Косметология'),
  other('Прочие услуги');

  const ServiceCategory(this.label);

  final String label;
}

const Set<String> _trainingTypes = {
  'club_membership',
  'zone_membership',
  'limited_membership',
  'group_membership',
  'day_membership',
  'single_visit',
  'guest_pass',
  'trial',
  'single_training',
  'training_package',
  'group_course',
  'program_design',
};

const Set<String> _cosmetologySpecializations = {
  'cosmetology',
  'spa',
  'solarium',
};

const Set<String> _medicalSpecializations = {'lfk', 'physician', 'nurse'};

/// Относит услугу к вкладке по типу и специализации исполнителя.
ServiceCategory classifyService(Service service) {
  final specialization = service.executorSpecializationCode;
  if (specialization != null &&
      _cosmetologySpecializations.contains(specialization)) {
    return ServiceCategory.cosmetology;
  }
  if (service.serviceTypeCode == 'medical_test' ||
      (specialization != null &&
          _medicalSpecializations.contains(specialization))) {
    return ServiceCategory.medical;
  }
  if (_trainingTypes.contains(service.serviceTypeCode) ||
      specialization == 'personal_trainer' ||
      specialization == 'group_instructor') {
    return ServiceCategory.training;
  }
  return ServiceCategory.other;
}

/// Короткая подпись ограничения услуги для списка.
String serviceLimitLabel(Service service) {
  switch (service.usageLimitMode) {
    case ServiceUsageLimitMode.unlimited:
      return 'Безлимит';
    case ServiceUsageLimitMode.quota:
      final limit = service.quotaLimit ?? 0;
      return '$limit в ${quotaPeriodPrepositional(service.quotaPeriod)}';
    default:
      final maxUses = service.maxUses ?? 0;
      return '$maxUses использований';
  }
}

/// Подпись периода квоты в предложном падеже.
String quotaPeriodPrepositional(int? period) {
  switch (period) {
    case ServiceQuotaPeriod.day:
      return 'день';
    case ServiceQuotaPeriod.week:
      return 'неделю';
    case ServiceQuotaPeriod.month:
      return 'месяц';
    default:
      return 'период';
  }
}
