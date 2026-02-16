class Competency {
  Competency({
    required this.id,
    required this.staffId,
    required this.name,
    required this.level,
    this.certificateUrl,
    this.verifiedAt,
    this.verifiedBy,
  });

  final String id;
  final String staffId;
  final String name;
  final int level;
  final String? certificateUrl;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  factory Competency.fromMap(Map<String, dynamic> map) {
    return Competency(
      id: map['id'].toString(),
      staffId: map['staff_id'].toString(),
      name: map['name'] as String,
      level: map['level'] as int,
      certificateUrl: map['certificate_url'] as String?,
      verifiedAt: map['verified_at'] as DateTime?,
      verifiedBy: map['verified_by']?.toString(),
    );
  }

  Competency copyWith({
    String? id,
    String? staffId,
    String? name,
    int? level,
    String? certificateUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return Competency(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
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
      'staff_id': staffId,
      'name': name,
      'level': level,
      'certificate_url': certificateUrl,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
    };
  }
}
