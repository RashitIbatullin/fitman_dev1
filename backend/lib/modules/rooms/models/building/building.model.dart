class Building {
  const Building({
    this.id,
    required this.name,
    required this.address,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.archivedAt,
        this.archivedBy,
        this.archivedByName,
        this.archivedReason,
      });
    
      final String? id;
      final String name;
      final String address;
      final String? note;
      final DateTime? createdAt;
      final DateTime? updatedAt;
      final String? createdBy;
      final String? updatedBy;
      final DateTime? archivedAt;
      final String? archivedBy;
      final String? archivedByName;
      final String? archivedReason;
    
      factory Building.fromMap(Map<String, dynamic> map) {
        return Building(
          id: map['id']?.toString(),
          name: map['name'] as String,
          address: map['address'] as String,
          note: map['note'] as String?,
          createdAt: map['created_at'] is DateTime
              ? map['created_at'] as DateTime
              : (map['created_at'] == null
                  ? null
                  : DateTime.parse(map['created_at'] as String)),
          updatedAt: map['updated_at'] is DateTime
              ? map['updated_at'] as DateTime
              : (map['updated_at'] == null
                  ? null
                  : DateTime.parse(map['updated_at'] as String)),
          createdBy: map['created_by']?.toString(),
          updatedBy: map['updated_by']?.toString(),
          archivedAt: map['archived_at'] is DateTime
              ? map['archived_at'] as DateTime
              : (map['archived_at'] == null
                  ? null
                  : DateTime.parse(map['archived_at'] as String)),
          archivedBy: map['archived_by']?.toString(),
          archivedByName: map['archived_by_name'] as String?,
          archivedReason: map['archived_reason'] as String?,
        );
      }
    
      factory Building.fromJson(Map<String, dynamic> json) {
        return Building(
          id: json['id'] as String?,
          name: json['name'] as String,
          address: json['address'] as String,
          note: json['note'] as String?,
          createdAt: json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
          updatedAt: json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
          createdBy: json['created_by'] as String?,
          updatedBy: json['updated_by'] as String?,
          archivedAt: json['archived_at'] == null
              ? null
              : DateTime.parse(json['archived_at'] as String),
          archivedBy: json['archived_by'] as String?,
          archivedByName: json['archived_by_name'] as String?,
          archivedReason: json['archived_reason'] as String?,
        );
      }
    
      Map<String, dynamic> toJson() {
        return {
          'id': id,
          'name': name,
          'address': address,
          'note': note,
          'created_at': createdAt?.toIso8601String(),
          'updated_at': updatedAt?.toIso8601String(),
          'created_by': createdBy,
          'updated_by': updatedBy,
          'archived_at': archivedAt?.toIso8601String(),
          'archived_by': archivedBy,
          'archived_by_name': archivedByName,
          'archived_reason': archivedReason,
        };
      }
}