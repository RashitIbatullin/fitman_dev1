import 'package:fitman_app/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_app/modules/supportStaff/models/employment_type.enum.dart';
import 'package:fitman_app/modules/supportStaff/models/staff_category.enum.dart';
import 'package:fitman_app/modules/supportStaff/models/work_schedule.model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_staff.model.freezed.dart';
part 'support_staff.model.g.dart';

@freezed
class SupportStaff with _$SupportStaff {
  const factory SupportStaff({
    required String id,
    required String firstName,
    required String lastName,
    String? middleName,
    String? phone,
    String? email,
    required EmploymentType employmentType,
    required StaffCategory category,
    List<Competency>? competencies,
    List<String>? accessibleEquipmentTypes,
    required bool canMaintainEquipment,
    WorkSchedule? schedule,
    String? companyName,
    String? contractNumber,
    DateTime? contractExpiryDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  }) = _SupportStaff;

  factory SupportStaff.fromJson(Map<String, dynamic> json) =>
      _$SupportStaffFromJson(json);
}
