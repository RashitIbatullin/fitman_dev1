import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:fitman_backend/logging/app_logger.dart';

class PhotoService {
  // Saves the file and returns the public URL.
  Future<String> savePhoto({
    required String subDirectory,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final extension = path.extension(fileName);
    final uniqueFileName = '${const Uuid().v4()}$extension';

    final scriptPath = Platform.script.toFilePath(windows: Platform.isWindows);
    final projectRoot = path.normalize(path.join(path.dirname(scriptPath), '..', '..'));
    final uploadDir = path.join(projectRoot, 'uploads', subDirectory);
    
    final filePath = path.join(uploadDir, uniqueFileName);

    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(fileBytes);

    return '/uploads/$subDirectory/$uniqueFileName';
  }

  // Deletes a photo file given its public URL.
  Future<void> deletePhotoFile(String photoUrl) async {
    if (!photoUrl.startsWith('/uploads/')) {
      appLog.info('PhotoService: Invalid photoUrl format: $photoUrl');
      return;
    }

    final scriptPath = Platform.script.toFilePath(windows: Platform.isWindows);
    final projectRoot = path.normalize(path.join(path.dirname(scriptPath), '..', '..'));
    
    final relativeFilePath = photoUrl.replaceFirst('/', ''); // remove leading slash
    final absoluteFilePath = path.join(projectRoot, relativeFilePath);

    final file = File(absoluteFilePath);
    if (await file.exists()) {
      try {
        await file.delete();
        appLog.info('PhotoService: Physical file deleted: $absoluteFilePath');
      } catch (e) {
        appLog.error('PhotoService: Error deleting physical file $absoluteFilePath: $e');
        // We don't rethrow, as the primary goal is to remove the DB record anyway.
      }
    } else {
      appLog.info('PhotoService: Physical file not found at $absoluteFilePath');
    }
  }
}
