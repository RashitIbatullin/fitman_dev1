import 'package:postgres/postgres.dart';
import '../config/database.dart';
import '../modules/groups/models/group_condition.model.dart';

class GroupSyncService {
  final Database _db;

  GroupSyncService(this._db);

  Future<void> syncAnalyticGroups() async {
    print('Starting analytic group synchronization...');
    try {
      final autoGroups = await _db.groups.getAllAnalyticGroups();
      for (final group in autoGroups.where((g) => g.isAutoUpdate)) {
        print('Processing auto-update group: ${group.name} (ID: ${group.id})');
        
        final List<int> matchingClientIds = await _findMatchingClients(group.conditions);
        
        // Update the group with new client_ids_cache and last_updated_at
        final updatedGroup = group.copyWith(
          clientIds: matchingClientIds,
          lastUpdatedAt: DateTime.now(),
        );
        
        await _db.groups.updateAnalyticGroup(updatedGroup, 0); // Assuming system user (ID 0) for updates
        print('Group ${group.name} updated with ${matchingClientIds.length} members.');
      }
      print('Analytic group synchronization completed.');
    } catch (e) {
      print('Error during analytic group synchronization: $e');
    }
  }

  Future<List<int>> _findMatchingClients(List<GroupCondition> conditions) async {
    if (conditions.isEmpty) {
      return [];
    }

    final queryParts = <String>[];
    final parameters = <String, dynamic>{};
    int paramIndex = 0;

    for (final condition in conditions) {
      final paramName = 'val${paramIndex++}';
      String operator;
      
      // Basic type inference and operator mapping
      if (int.tryParse(condition.value) != null || double.tryParse(condition.value) != null) {
        // Numeric comparison
        switch (condition.operator) {
          case 'equals': operator = '='; break;
          case 'greater_than': operator = '>'; break;
          case 'less_than': operator = '<'; break;
          default: throw Exception('Unsupported numeric operator: ${condition.operator}');
        }
      } else {
        // String comparison
        switch (condition.operator) {
          case 'equals': operator = '='; break;
          case 'contains': operator = 'ILIKE'; // Case-insensitive LIKE
            parameters[paramName] = '%${condition.value}%';
            break;
          default: throw Exception('Unsupported string operator: ${condition.operator}');
        }
      }

      if (condition.operator != 'contains') {
        parameters[paramName] = condition.value;
      }
      
      // Map GroupCondition fields to actual database columns.
      // This is a simplified example and needs to be expanded based on actual user model/profile fields.
      // For now, let's assume conditions are on 'users' table fields or related profile tables.
      // In a real app, this mapping would be more robust, potentially involving a schema mapping.
      String dbField;
      switch (condition.field) {
        case 'age': dbField = 'EXTRACT(YEAR FROM AGE(NOW(), date_of_birth))'; break;
        case 'gender': dbField = 'gender'; break; // Assuming gender is int (0 for male, 1 for female)
        case 'subscription_type': dbField = 'client_profiles.subscription_type'; break; // Example: needs join
        case 'last_visit_date': dbField = 'client_profiles.last_visit_date'; break; // Example: needs join
        // Add more mappings as needed
        default: dbField = condition.field; // Fallback, but dangerous for direct use if not validated
      }
      
      queryParts.add('$dbField $operator @$paramName');
    }

    if (queryParts.isEmpty) {
      return [];
    }

    final String whereClause = queryParts.join(' AND ');
    
    // This query assumes all conditions can be met by joining with client_profiles and other tables if necessary.
    // A more robust solution might require a specific view or a more dynamic join builder.
    final String sql = '''
      SELECT u.id
      FROM users u
      LEFT JOIN client_profiles cp ON u.id = cp.user_id -- Example join if conditions reference client_profiles
      WHERE u.archived_at IS NULL AND EXISTS (SELECT 1 FROM user_roles ur JOIN roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND r.name = 'client') AND $whereClause
    ''';

    final conn = await _db.connection;
    final results = await conn.execute(Sql.named(sql), parameters: parameters);

    return results.map((row) => row[0] as int).toList();
  }
}