import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'group_condition.model.dart'; // Corrected import path

part 'analytic_group.model.g.dart';

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

@JsonSerializable(converters: [AnalyticGroupTypeConverter()])
class AnalyticGroup extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final AnalyticGroupType type;
  
  // АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ
  @JsonKey(name: 'is_auto_update')
  final bool isAutoUpdate;           // true - группа автоматически обновляется по условиям
  final List<GroupCondition> conditions; // Условия для автоматических групп
  
  // ДИНАМИЧЕСКИЙ СОСТАВ
  @JsonKey(name: 'client_ids_cache', defaultValue: [])
  final List<int> clientIds;      // Кэшированный список клиентов в группе
  
  @JsonKey(name: 'last_updated_at')
  final DateTime? lastUpdatedAt;      // Время последнего обновления
  
  // ДОПОЛНИТЕЛЬНЫЕ ДАННЫЕ
  final Map<String, dynamic>? metadata; // Дополнительные данные по типам
  @JsonKey(name: 'archived_at')
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
        archivedAt,
        archivedBy,
      ];
}