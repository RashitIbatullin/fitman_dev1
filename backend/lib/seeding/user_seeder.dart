import 'package:faker/faker.dart';
import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';

class UserSeeder {
  UserSeeder(this._connection, this._faker);
  final Connection _connection;
  final Faker _faker;

  Future<String> createUser({required String login, required String firstName, required String lastName, String? phone, int gender = 0, required String password}) async {
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    final result = await _connection.execute(Sql.named('''
      INSERT INTO users (login, password_hash, email, first_name, last_name, gender, date_of_birth, phone)
      VALUES (@login, @hash, @email, @first, @last, @gender, @dob, @phone)
      RETURNING id
      '''), parameters: {'login': phone ?? login, 'hash': passwordHash, 'email': login, 'first': firstName, 'last': lastName, 'gender': gender, 'dob': _faker.date.dateTime(minYear: 1970, maxYear: 2004), 'phone': phone});
    return result.first[0].toString();
  }

  Future<void> assignRole(String userId, String roleId) async {
    await _connection.execute(Sql.named('INSERT INTO user_roles (user_id, role_id) VALUES (@user_id, @role_id)'), parameters: {'user_id': userId, 'role_id': roleId});
  }

  Future<void> createEmployeeProfile(String userId, {required String specialization, required int workExperience, required String createdBy}) async {
    await _connection.execute(Sql.named('''
      INSERT INTO employee_profiles (user_id, specialization, work_experience, can_maintain_equipment, created_by)
      VALUES (@user_id, @spec, @exp, @can_maintain, @created_by)
      '''), parameters: {'user_id': userId, 'spec': specialization, 'exp': workExperience, 'can_maintain': _faker.randomGenerator.boolean(), 'created_by': createdBy});
  }

  Future<void> assign(String managerId, String tableName, String roleIdColumn, String subordinateId) async {
    final managerIdColumn = '${tableName.split('_').first}_id';
    await _connection.execute(Sql.named('INSERT INTO $tableName ($managerIdColumn, $roleIdColumn) VALUES (@manager_id, @subordinate_id)'), parameters: {'manager_id': managerId, 'subordinate_id': subordinateId});
  }

  Future<String> createSupportStaff({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    required int employmentType,
    required int category,
    required bool canMaintainEquipment,
    String? companyName,
    required String createdBy,
  }) async {
    final result = await _connection.execute(Sql.named('''
      INSERT INTO support_staff (first_name, last_name, phone, email, employment_type, category, can_maintain_equipment, company_name, created_by, updated_by)
      VALUES (@first_name, @last_name, @phone, @email, @employment_type, @category, @can_maintain, @company_name, @created_by, @created_by)
      RETURNING id;
    '''), parameters: {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'employment_type': employmentType,
      'category': category,
      'can_maintain': canMaintainEquipment,
      'company_name': companyName,
      'created_by': createdBy,
    });
    return result.first[0].toString();
  }

  Future<void> createCompetency({
    required String competentId,
    required int executorType,
    required String name,
    required int level,
    required String createdBy,
    String? verifiedBy,
  }) async {
    await _connection.execute(Sql.named('''
      INSERT INTO competencies (competent_id, executor_type, name, level, verified_at, verified_by, created_by, updated_by)
      VALUES (@competent_id, @executor_type, @name, @level, @verified_at, @verified_by, @created_by, @created_by)
      ON CONFLICT (competent_id, executor_type, name) DO NOTHING;
    '''), parameters: {
      'competent_id': competentId,
      'executor_type': executorType,
      'name': name,
      'level': level,
      'verified_at': DateTime.now(),
      'verified_by': verifiedBy ?? createdBy,
      'created_by': createdBy,
    });
  }
}
