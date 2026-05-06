import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/competencies/repositories/competency_repository.dart';
import 'package:fitman_common/enums/executor_type.dart';
import 'package:fitman_common/modules/support_staff/employment_type.enum.dart';
import 'package:fitman_common/modules/support_staff/staff_category.enum.dart';
import 'package:fitman_common/modules/support_staff/support_staff.model.dart';
import 'package:postgres/postgres.dart';

abstract class SupportStaffRepository {
  Future<SupportStaff> getById(String id);
  Future<List<SupportStaff>> getAll({bool includeArchived = false});
  Future<SupportStaff> create(SupportStaff supportStaff, String userId);
  Future<SupportStaff> update(String id, SupportStaff supportStaff, String userId);
  Future<void> archive(String id, String userId, String? archivedReason);
  Future<void> unarchive(String id);
}

class SupportStaffRepositoryImpl implements SupportStaffRepository {
  SupportStaffRepositoryImpl(this._db, this._competencyRepository);

  final Database _db;
  final CompetencyRepository _competencyRepository;

  Map<String, dynamic> _fixRowMap(Map<String, dynamic> rowMap) {
    final fixedMap = Map<String, dynamic>.from(rowMap);

    final employmentType = fixedMap['employment_type'];
    if (employmentType != null && employmentType is int) {
      if (employmentType >= 0 && employmentType < EmploymentType.values.length) {
        fixedMap['employment_type'] = EmploymentType.values[employmentType].name;
      }
    }

    final category = fixedMap['category'];
    if (category != null && category is int) {
      if (category >= 0 && category < StaffCategory.values.length) {
        fixedMap['category'] = StaffCategory.values[category].name;
      }
    }

    // Convert DateTime fields to ISO 8601 strings for json_serializable
    const dateFields = ['created_at', 'updated_at', 'archived_at', 'contract_expiry_date'];
    for (final field in dateFields) {
      if (fixedMap.containsKey(field) && fixedMap[field] is DateTime) {
        fixedMap[field] = (fixedMap[field] as DateTime).toIso8601String();
      }
    }
    
    return fixedMap;
  }

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
          contract_expiry_date, notes, created_by, updated_by
        ) VALUES (
          @firstName, @lastName, @middleName, @phone, @email, @employmentType, @category,
          @canMaintainEquipment, @accessibleEquipmentTypes, @companyName, @contractNumber,
          @contractExpiryDate, @notes, @createdBy, @updatedBy
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

    final newId = result.first.first as String;
    return await getById(newId);
  }

  @override
  Future<List<SupportStaff>> getAll({bool includeArchived = false}) async {
    final conn = await _db.connection;
    
    String whereClause;
    if (includeArchived) {
      whereClause = 'WHERE archived_at IS NOT NULL';
    } else {
      whereClause = 'WHERE archived_at IS NULL';
    }

    final result = await conn.execute(
        Sql.named('SELECT * FROM support_staff $whereClause ORDER BY last_name, first_name ASC'));

    final staffList = <SupportStaff>[];
    for (final row in result) {
      final staff = SupportStaff.fromJson(_fixRowMap(row.toColumnMap()));
      final competencies = await _competencyRepository.getCompetencies(staff.id, ExecutorType.staff);
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
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('SupportStaff with id $id not found');
    }

    final staff = SupportStaff.fromJson(_fixRowMap(result.first.toColumnMap()));
    final competencies = await _competencyRepository.getCompetencies(staff.id, ExecutorType.staff);

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
}
