import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

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
      print('PhotoService: Invalid photoUrl format: $photoUrl');
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
        print('PhotoService: Physical file deleted: $absoluteFilePath');
      } catch (e) {
        print('PhotoService: Error deleting physical file $absoluteFilePath: $e');
        // We don't rethrow, as the primary goal is to remove the DB record anyway.
      }
    } else {
      print('PhotoService: Physical file not found at $absoluteFilePath');
    }
  }
}
