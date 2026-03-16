import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/competency_level.enum.dart';

class Competency {
  Competency({
    required this.id,
    required this.competentId,
    required this.executorType,
    required this.name,
    required this.level,
    this.certificateUrl,
    this.verifiedAt,
    this.verifiedBy,
  });

  final String id;
  final String competentId;
  final ExecutorType executorType;
  final String name;
  final CompetencyLevel level;
  final String? certificateUrl;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  factory Competency.fromMap(Map<String, dynamic> map) {
    return Competency(
      id: map['id'].toString(),
      competentId: map['competent_id'].toString(),
      executorType: ExecutorType.values.byName(map['executor_type'] as String),
      name: map['name'] as String,
      level: CompetencyLevel.values.byName(map['level'] as String),
      certificateUrl: map['certificate_url'] as String?,
      verifiedAt: map['verified_at'] as DateTime?,
      verifiedBy: map['verified_by']?.toString(),
    );
  }

  Competency copyWith({
    String? id,
    String? competentId,
    ExecutorType? executorType,
    String? name,
    CompetencyLevel? level,
    String? certificateUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return Competency(
      id: id ?? this.id,
      competentId: competentId ?? this.competentId,
      executorType: executorType ?? this.executorType,
      name: name ?? this.name,
      level: level ?? this.level,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competent_id': competentId,
      'executor_type': executorType.name,
      'name': name,
      'level': level.name,
      'certificate_url': certificateUrl,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
    };
  }
}
