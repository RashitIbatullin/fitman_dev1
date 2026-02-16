import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'group_condition.model.dart';

part 'analytic_group.model.g.dart';

// Helper functions for robust DateTime parsing
DateTime? _nullableDateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is DateTime) return json;
  if (json is String) return DateTime.parse(json);
  throw ArgumentError('Invalid type for nullable DateTime: ${json.runtimeType}');
}


@JsonEnum(valueField: 'index')
enum AnalyticGroupType {
  corporate,      // value: 0
  demographic,    // value: 1
  financial,      // value: 2
  behavioral,     // value: 3
  custom;         // value: 4
}

class AnalyticGroupTypeConverter implements JsonConverter<AnalyticGroupType, int> {
  const AnalyticGroupTypeConverter();

  @override
  AnalyticGroupType fromJson(int json) => AnalyticGroupType.values[json];

  @override
  int toJson(AnalyticGroupType object) => object.index;
}

List<GroupCondition> _conditionsFromJson(dynamic json) {
  if (json is List) {
    return json.map((e) => GroupCondition.fromJson(e as Map<String, dynamic>)).toList();
  }
  return []; // Return empty list if it's not a list (e.g., a map or null)
}

List<int> _clientIdsFromJson(dynamic json) {
  if (json is List) {
    // Ensure all items are integers, handling potential parsing errors
    return json.map<int>((e) => e is int ? e : int.parse(e.toString())).toList();
  }
  return []; // Return empty list if it's not a list (e.g., a map or null)
}

@JsonSerializable(converters: [AnalyticGroupTypeConverter()])
class AnalyticGroup extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final AnalyticGroupType type;
  
  @JsonKey(name: 'is_auto_update')
  final bool isAutoUpdate;
  @JsonKey(fromJson: _conditionsFromJson)
  final List<GroupCondition> conditions;
  
  @JsonKey(name: 'client_ids_cache', fromJson: _clientIdsFromJson)
  final List<int> clientIds;
  
  @JsonKey(name: 'last_updated_at', fromJson: _nullableDateTimeFromJson)
  final DateTime? lastUpdatedAt;
  
  final Map<String, dynamic>? metadata;

  // System fields
  @JsonKey(name: 'company_id')
  final int? companyId;
  @JsonKey(name: 'created_at', fromJson: _nullableDateTimeFromJson)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _nullableDateTimeFromJson)
  final DateTime? updatedAt;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'updated_by')
  final int? updatedBy;
  @JsonKey(name: 'archived_at', fromJson: _nullableDateTimeFromJson)
  final DateTime? archivedAt;
  @JsonKey(name: 'archived_by')
  final int? archivedBy;

  const AnalyticGroup({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.isAutoUpdate = false,
    this.conditions = const [],
    this.clientIds = const [],
    this.lastUpdatedAt,
    this.metadata,
    this.companyId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.archivedAt,
    this.archivedBy,
  });

  factory AnalyticGroup.fromJson(Map<String, dynamic> json) => _$AnalyticGroupFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticGroupToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        isAutoUpdate,
        conditions,
        clientIds,
        lastUpdatedAt,
        metadata,
        companyId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        archivedAt,
        archivedBy,
      ];

  AnalyticGroup copyWith({
    int? id,
    String? name,
    String? description,
    AnalyticGroupType? type,
    bool? isAutoUpdate,
    List<GroupCondition>? conditions,
    List<int>? clientIds,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? metadata,
    int? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
    int? updatedBy,
    DateTime? archivedAt,
    int? archivedBy,
  }) {
    return AnalyticGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isAutoUpdate: isAutoUpdate ?? this.isAutoUpdate,
      conditions: conditions ?? this.conditions,
      clientIds: clientIds ?? this.clientIds,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      metadata: metadata ?? this.metadata,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedBy: archivedBy ?? this.archivedBy,
    );
  }
}