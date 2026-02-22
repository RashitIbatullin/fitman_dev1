import 'package:fitman_backend/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_type.repository.dart';

abstract class EquipmentService {
  Future<EquipmentType> getTypeById(String id);
  Future<List<EquipmentType>> getAllTypes();
  Future<EquipmentType> createType(EquipmentType equipmentType, String userId);
  Future<EquipmentType> updateType(String id, EquipmentType equipmentType, String userId);
  Future<void> deleteType(String id);

  Future<EquipmentItem> getItemById(String id);
  Future<List<EquipmentItem>> getAllItems();
  Future<List<EquipmentItem>> getItemsByRoomId(String roomId);
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
  Future<List<EquipmentType>> getAllTypes() {
    return _typeRepository.getAll();
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
  Future<List<EquipmentItem>> getAllItems() {
    return _itemRepository.getAll();
  }

  @override
  Future<List<EquipmentItem>> getItemsByRoomId(String roomId) {
    return _itemRepository.getByRoomId(roomId);
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
