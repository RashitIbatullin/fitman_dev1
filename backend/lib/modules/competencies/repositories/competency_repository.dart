import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/enums/executor_type.dart';
import 'package:fitman_common/modules/support_staff/competency.model.dart';
import 'package:fitman_common/modules/support_staff/competency_level.enum.dart';
import 'package:postgres/postgres.dart';

abstract class CompetencyRepository {
  Future<List<Competency>> getCompetencies(String competentId, ExecutorType executorType);
  Future<Competency> addCompetency(Competency competency);
  Future<void> deleteCompetency(String competencyId);
}

class CompetencyRepositoryImpl implements CompetencyRepository {
  CompetencyRepositoryImpl(this._db);

  final Database _db;

  Map<String, dynamic> _fixCompetencyRowMap(Map<String, dynamic> rowMap) {
    final map = Map<String, dynamic>.from(rowMap);

    // Fix enums
    final executorType = map['executor_type'];
    if (executorType != null && executorType is int) {
      if (executorType >= 0 && executorType < ExecutorType.values.length) {
        map['executor_type'] = ExecutorType.values[executorType].name;
      }
    }

    final level = map['level'];
    if (level != null && level is int) {
      if (level >= 0 && level < CompetencyLevel.values.length) {
        map['level'] = CompetencyLevel.values[level].name;
      }
    }

    // Fix DateTime
    const dateFields = ['verified_at'];
    for (final field in dateFields) {
      if (map.containsKey(field) && map[field] is DateTime) {
        map[field] = (map[field] as DateTime).toIso8601String();
      }
    }

    return map;
  }

  @override
  Future<List<Competency>> getCompetencies(
      String competentId, ExecutorType executorType) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named(
          'SELECT * FROM competencies WHERE competent_id = @competentId AND executor_type = @executorType'),
      parameters: {
        'competentId': competentId,
        'executorType': executorType.index,
      },
    );
    return result
        .map((row) => Competency.fromJson(_fixCompetencyRowMap(row.toColumnMap())))
        .toList();
  }

  @override
  Future<Competency> addCompetency(Competency competency) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO competencies (
          competent_id, executor_type, name, level, certificate_url, verified_at, verified_by
        ) VALUES (
          @competentId, @executorType, @name, @level, @certificateUrl, @verifiedAt, @verifiedBy
        ) RETURNING id;
      '''),
      parameters: {
        'competentId': competency.competentId,
        'executorType': competency.executorType.index,
        'name': competency.name,
        'level': competency.level.index,
        'certificateUrl': competency.certificateUrl,
        'verifiedAt': competency.verifiedAt,
        'verifiedBy': competency.verifiedBy,
      },
    );
    final newId = result.first.first as String;
    return competency.copyWith(id: newId);
  }

  @override
  Future<void> deleteCompetency(String competencyId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM competencies WHERE id = @id'),
      parameters: {'id': competencyId},
    );
  }
}
