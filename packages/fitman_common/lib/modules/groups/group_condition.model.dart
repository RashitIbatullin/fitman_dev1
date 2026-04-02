import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'group_condition.model.g.dart';

@JsonSerializable()
class GroupCondition extends Equatable {
  final String field;        // Поле для условия (например, 'age', 'subscription_type')
  final String operator;     // Оператор ('equals', 'greater_than', 'less_than', 'contains')
  final String value;        // Значение для сравнения

  const GroupCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory GroupCondition.fromJson(Map<String, dynamic> json) => _$GroupConditionFromJson(json);
  Map<String, dynamic> toJson() => _$GroupConditionToJson(this);

  @override
  List<Object?> get props => [field, operator, value];

  GroupCondition copyWith({
    String? field,
    String? operator,
    String? value,
  }) {
    return GroupCondition(
      field: field ?? this.field,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }
}