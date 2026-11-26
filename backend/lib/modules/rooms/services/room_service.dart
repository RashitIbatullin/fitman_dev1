import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/rooms/repositories/room_repository.dart';
import 'package:fitman_common/modules/rooms/room_model.dart';

import 'package:fitman_backend/services/photo_service.dart';

class RoomService {
  RoomService(
    this._roomRepository,
    this._equipmentItemRepository,
    this._auditService,
    this._database,
  );

  final RoomRepository _roomRepository;
  final EquipmentItemRepository _equipmentItemRepository;
  final AuditService _auditService;
  final Database _database;
  final PhotoService _photoService = PhotoService();

  Future<List<Room>> getRooms({bool? isArchived, bool? isActive}) {
    return _roomRepository.getAll(isArchived: isArchived, isActive: isActive);
  }

  Future<Room?> getById(String id) {
    return _roomRepository.getById(id);
  }

  Future<Room> createRoom(Room room, {required AuditContext audit}) {
    return _database.runTx((session) async {
      final created = await _roomRepository.create(
        room,
        createdBy: audit.actorId,
        session: session,
      );

      await _auditService.record(
        session: session,
        tableName: 'rooms',
        rowPk: created.id,
        action: 'INSERT',
        context: audit,
        newValues: created.toJson(),
      );

      return created;
    });
  }

  Future<Room> updateRoom(
    String id,
    Room room, {
    required AuditContext audit,
  }) {
    return _database.runTx((session) async {
      final oldRoom = await _roomRepository.getById(id, session: session);
      if (oldRoom == null) {
        throw const NotFoundException('Помещение не найдено');
      }

      // При архивации проверяем, что в помещении нет активного оборудования.
      if (room.archivedAt != null) {
        final equipmentInRoom = await _equipmentItemRepository.getByRoomId(
          id,
          includeArchived: false,
          session: session,
        );
        if (equipmentInRoom.isNotEmpty) {
          throw const ConflictException(
            'Нельзя архивировать помещение, в котором есть активное оборудование.',
          );
        }
      }

      final updated = await _roomRepository.update(
        id,
        room,
        session: session,
      );

      final action = _updateAction(oldRoom, updated);
      await _auditService.record(
        session: session,
        tableName: 'rooms',
        rowPk: id,
        action: action,
        context: audit,
        oldValues: oldRoom.toJson(),
        newValues: updated.toJson(),
        reason: action == 'ARCHIVE' ? updated.archivedReason : null,
      );

      return updated;
    });
  }

  Future<void> archiveRoom(
    String id,
    String userId, {
    required AuditContext audit,
  }) {
    return _database.runTx((session) async {
      final oldRoom = await _roomRepository.getById(id, session: session);
      if (oldRoom == null) {
        throw const NotFoundException('Помещение не найдено');
      }

      await _roomRepository.archive(id, userId, session: session);
      final updated = await _roomRepository.getById(id, session: session);

      await _auditService.record(
        session: session,
        tableName: 'rooms',
        rowPk: id,
        action: 'ARCHIVE',
        context: audit,
        oldValues: oldRoom.toJson(),
        newValues: updated?.toJson(),
        reason: updated?.archivedReason,
      );
    });
  }

  Future<String> uploadPhoto({
    required String roomId,
    required String fileName,
    required List<int> fileBytes,
    required AuditContext audit,
  }) async {
    late String publicUrl;

    await _database.runTx((session) async {
      final oldRoom = await _roomRepository.getById(roomId, session: session);
      if (oldRoom == null) {
        throw const NotFoundException('Помещение не найдено');
      }

      publicUrl = await _photoService.savePhoto(
        subDirectory: 'room_photos',
        fileName: fileName,
        fileBytes: fileBytes,
      );
      await _roomRepository.addPhotoUrl(
        roomId,
        publicUrl,
        session: session,
      );

      final updated = await _roomRepository.getById(roomId, session: session);
      await _auditService.record(
        session: session,
        tableName: 'rooms',
        rowPk: roomId,
        action: 'UPDATE',
        context: audit,
        oldValues: oldRoom.toJson(),
        newValues: updated?.toJson(),
      );
    });

    return publicUrl;
  }

  Future<void> removeRoomPhoto(
    String roomId,
    String photoUrl, {
    required AuditContext audit,
  }) async {
    await _database.runTx((session) async {
      final oldRoom = await _roomRepository.getById(roomId, session: session);
      if (oldRoom == null) {
        throw const NotFoundException('Помещение не найдено');
      }

      await _roomRepository.removePhotoUrl(
        roomId,
        photoUrl,
        session: session,
      );

      final updated = await _roomRepository.getById(roomId, session: session);
      await _auditService.record(
        session: session,
        tableName: 'rooms',
        rowPk: roomId,
        action: 'UPDATE',
        context: audit,
        oldValues: oldRoom.toJson(),
        newValues: updated?.toJson(),
      );
    });

    await _photoService.deletePhotoFile(photoUrl);
  }

  String _updateAction(Room oldRoom, Room updated) {
    if (oldRoom.archivedAt == null && updated.archivedAt != null) {
      return 'ARCHIVE';
    }
    if (oldRoom.archivedAt != null && updated.archivedAt == null) {
      return 'RESTORE';
    }
    return 'UPDATE';
  }
}
