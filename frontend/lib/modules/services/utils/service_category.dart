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
  return _classify(
    serviceTypeCode: service.serviceTypeCode,
    specializationCode: service.executorSpecializationCode,
  );
}

/// Относит тип услуги к разделу — для иконок в справочниках.
ServiceCategory classifyServiceTypeCode(
  String? serviceTypeCode, {
  String? specializationCode,
}) {
  return _classify(
    serviceTypeCode: serviceTypeCode,
    specializationCode: specializationCode,
  );
}

/// Относит оформленную услугу к вкладке по тем же правилам.
ServiceCategory classifyPurchase(ServicePurchase purchase) {
  return _classify(
    serviceTypeCode: purchase.serviceTypeCode,
    specializationCode: purchase.executorSpecializationCode,
  );
}

ServiceCategory _classify({
  required String? serviceTypeCode,
  required String? specializationCode,
}) {
  if (specializationCode != null &&
      _cosmetologySpecializations.contains(specializationCode)) {
    return ServiceCategory.cosmetology;
  }
  if (serviceTypeCode == 'medical_test' ||
      (specializationCode != null &&
          _medicalSpecializations.contains(specializationCode))) {
    return ServiceCategory.medical;
  }
  if (_trainingTypes.contains(serviceTypeCode) ||
      specializationCode == 'personal_trainer' ||
      specializationCode == 'group_instructor') {
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
