import 'package:fitman_common/modules/equipment/equipment/equipment_item.model.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_type.model.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_type.repository.dart';

abstract class EquipmentService {
  Future<EquipmentType> getTypeById(String id);
  Future<List<EquipmentType>> getAllTypes({bool? includeArchived});
  Future<EquipmentType> createType(EquipmentType equipmentType, String userId);
  Future<EquipmentType> updateType(String id, EquipmentType equipmentType, String userId);
  Future<void> deleteType(String id);

  Future<EquipmentItem> getItemById(String id);
  Future<List<EquipmentItem>> getAllItems({bool? includeArchived});
  Future<List<EquipmentItem>> getItemsByRoomId(String roomId, {bool? includeArchived});
  Future<EquipmentItem> createItem(EquipmentItem equipmentItem, String userId);
  Future<EquipmentItem> updateItem(String id, EquipmentItem equipmentItem, String userId);
  Future<void> deleteItem(String id);

}

class EquipmentServiceImpl implements EquipmentService {
  EquipmentServiceImpl(this._typeRepository, this._itemRepository);

  final EquipmentTypeRepository _typeRepository;
  final EquipmentItemRepository _itemRepository;

  @override
  Future<EquipmentType> createType(EquipmentType equipmentType, String userId) {
    return _typeRepository.create(equipmentType, userId);
  }

  @override
  Future<void> deleteType(String id) {
    return _typeRepository.delete(id);
  }

  @override
  Future<List<EquipmentType>> getAllTypes({bool? includeArchived}) {
    return _typeRepository.getAll(includeArchived: includeArchived);
  }

  @override
  Future<EquipmentType> getTypeById(String id) {
    return _typeRepository.getById(id);
  }

  @override
  Future<EquipmentType> updateType(String id, EquipmentType equipmentType, String userId) {
    return _typeRepository.update(id, equipmentType, userId);
  }

  @override
  Future<EquipmentItem> createItem(EquipmentItem equipmentItem, String userId) {
    return _itemRepository.create(equipmentItem, userId);
  }

  @override
  Future<void> deleteItem(String id) {
    return _itemRepository.delete(id);
  }

  @override
  Future<List<EquipmentItem>> getAllItems({bool? includeArchived}) {
    return _itemRepository.getAll(includeArchived: includeArchived);
  }

  @override
  Future<List<EquipmentItem>> getItemsByRoomId(String roomId, {bool? includeArchived}) {
    return _itemRepository.getByRoomId(roomId, includeArchived: includeArchived);
  }

  @override
  Future<EquipmentItem> getItemById(String id) {
    return _itemRepository.getById(id);
  }

  @override
  Future<EquipmentItem> updateItem(String id, EquipmentItem equipmentItem, String userId) {
    return _itemRepository.update(id, equipmentItem, userId);
  }

}
