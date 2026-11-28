import 'package:fitman_backend/modules/services/repositories/service_repository.dart';
import 'package:fitman_common/fitman_common.dart';

/// Каталог услуг: только чтение.
class ServiceCatalogService {
  ServiceCatalogService(this._repository);

  final ServiceRepository _repository;

  Future<List<Service>> getAll({String? type, bool? active}) {
    return _repository.getAll(type: type, active: active);
  }

  Future<List<Map<String, dynamic>>> getTypes() {
    return _repository.getTypes();
  }
}
