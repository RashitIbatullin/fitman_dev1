
import 'package:fitman_common/modules/equipment/repair_time_standard.model.dart';
import '../repositories/repair_time_standard_repository.dart';

class RepairTimeStandardService {
  RepairTimeStandardService(this._repository);

  final RepairTimeStandardRepository _repository;

  Future<List<RepairTimeStandard>> getAll() => _repository.getAll();

  Future<RepairTimeStandard> getById(String id) => _repository.getById(id);

  Future<RepairTimeStandard> create(RepairTimeStandard standard, String userId) =>
      _repository.create(standard, userId);

  Future<RepairTimeStandard> update(String id, RepairTimeStandard standard, String userId) =>
      _repository.update(id, standard, userId);

  Future<void> archive(String id, String userId, String reason) => _repository.archive(id, userId, reason);

  Future<void> unarchive(String id, String userId) => _repository.unarchive(id, userId);
}
