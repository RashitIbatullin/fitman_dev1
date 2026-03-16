import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/competency_level.enum.dart';
import 'package:fitman_backend/modules/supportStaff/models/support_staff.model.dart';
import 'package:postgres/postgres.dart';

abstract class SupportStaffRepository {
  Future<SupportStaff> getById(String id);
  Future<List<SupportStaff>> getAll({bool includeArchived = false});
  Future<SupportStaff> create(SupportStaff supportStaff, String userId);
  Future<SupportStaff> update(String id, SupportStaff supportStaff, String userId);
  Future<void> archive(String id, String userId, String? archivedReason);
  Future<void> unarchive(String id);
  Future<List<Competency>> getCompetencies(String staffId);
  Future<Competency> addCompetency(Competency competency);
  Future<void> deleteCompetency(String competencyId);
}

class SupportStaffRepositoryImpl implements SupportStaffRepository {
  SupportStaffRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> archive(String id, String userId, String? archivedReason) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE support_staff SET archived_at = NOW(), archived_by = @userId, archived_reason = @archivedReason WHERE id = @id'),
      parameters: {
        'id': id,
        'userId': userId,
        'archivedReason': archivedReason,
      },
    );
  }

  @override
  Future<SupportStaff> create(SupportStaff supportStaff, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO support_staff (
          first_name, last_name, middle_name, phone, email, employment_type, category,
          can_maintain_equipment, accessible_equipment_types, company_name, contract_number,
          contract_expiry_date, notes, company_id, created_at, updated_at,
          created_by, updated_by
        ) VALUES (
          @firstName, @lastName, @middleName, @phone, @email, @employmentType, @category,
          @canMaintainEquipment, @accessibleEquipmentTypes, @companyName, @contractNumber,
          @contractExpiryDate, @notes, -1, NOW(), NOW(), @createdBy, @updatedBy
        ) RETURNING id;
      '''),
      parameters: {
        'firstName': supportStaff.firstName,
        'lastName': supportStaff.lastName,
        'middleName': supportStaff.middleName,
        'phone': supportStaff.phone,
        'email': supportStaff.email,
        'employmentType': supportStaff.employmentType.index,
        'category': supportStaff.category.index,
        'canMaintainEquipment': supportStaff.canMaintainEquipment,
        'accessibleEquipmentTypes': supportStaff.accessibleEquipmentTypes,
        'companyName': supportStaff.companyName,
        'contractNumber': supportStaff.contractNumber,
        'contractExpiryDate': supportStaff.contractExpiryDate,
        'notes': supportStaff.notes,
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as int;
    return await getById(newId.toString());
  }

  @override
  Future<List<SupportStaff>> getAll({bool includeArchived = false}) async {
    final conn = await _db.connection;
    final whereClause = includeArchived ? '' : 'WHERE archived_at IS NULL';
    final result = await conn.execute(
        Sql.named('SELECT * FROM support_staff $whereClause ORDER BY last_name, first_name ASC'));

    final staffList = <SupportStaff>[];
    for (final row in result) {
      final staff = SupportStaff.fromMap(row.toColumnMap());
      final competencies = await getCompetencies(staff.id);
      staffList.add(
        staff.copyWith(
          competencies: competencies,
        ),
      );
    }
    return staffList;
  }

  @override
  Future<SupportStaff> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM support_staff WHERE id = @id'),
      parameters: {'id': int.parse(id)},
    );

    if (result.isEmpty) {
      throw Exception('SupportStaff with id $id not found');
    }

    final staff = SupportStaff.fromMap(result.first.toColumnMap());
    final competencies = await getCompetencies(staff.id);

    return staff.copyWith(
      competencies: competencies,
    );
  }

  @override
  Future<void> unarchive(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE support_staff SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<SupportStaff> update(String id, SupportStaff supportStaff, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE support_staff SET
          first_name = @firstName,
          last_name = @lastName,
          middle_name = @middleName,
          phone = @phone,
          email = @email,
          employment_type = @employmentType,
          category = @category,
          can_maintain_equipment = @canMaintainEquipment,
          accessible_equipment_types = @accessibleEquipmentTypes,
          company_name = @companyName,
          contract_number = @contractNumber,
          contract_expiry_date = @contractExpiryDate,
          notes = @notes,
          updated_at = NOW(),
          updated_by = @updatedBy
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'firstName': supportStaff.firstName,
        'lastName': supportStaff.lastName,
        'middleName': supportStaff.middleName,
        'phone': supportStaff.phone,
        'email': supportStaff.email,
        'employmentType': supportStaff.employmentType.index,
        'category': supportStaff.category.index,
        'canMaintainEquipment': supportStaff.canMaintainEquipment,
        'accessibleEquipmentTypes': supportStaff.accessibleEquipmentTypes,
        'companyName': supportStaff.companyName,
        'contractNumber': supportStaff.contractNumber,
        'contractExpiryDate': supportStaff.contractExpiryDate,
        'notes': supportStaff.notes,
        'updatedBy': userId,
      },
    );
    return await getById(id);
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
        'competentId': int.parse(competency.competentId),
        'executorType': competency.executorType.index,
        'name': competency.name,
        'level': competency.level.index,
        'certificateUrl': competency.certificateUrl,
        'verifiedAt': competency.verifiedAt,
        'verifiedBy': competency.verifiedBy,
      },
    );
    final newId = result.first.first as int;
    return competency.copyWith(id: newId.toString());
  }

  @override
  Future<void> deleteCompetency(String competencyId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM competencies WHERE id = @id'),
      parameters: {'id': int.parse(competencyId)},
    );
  }

  @override
  Future<List<Competency>> getCompetencies(String staffId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named(
          'SELECT * FROM competencies WHERE competent_id = @staffId AND executor_type = @executorType'),
      parameters: {
        'staffId': int.parse(staffId),
        'executorType': 1, // ExecutorType.staff.index
      },
    );
    return result.map((row) {
      final map = row.toColumnMap();
      
      final executorTypeInt = map['executor_type'] as int;
      map['executor_type'] = ExecutorType.values[executorTypeInt].name;

      final levelInt = map['level'] as int;
      map['level'] = CompetencyLevel.values[levelInt].name;

      return Competency.fromMap(map);
    }).toList();
  }
}
