// core/services/local_image_handler.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class LocalImageHandler {
  static Future<String> saveImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/administration_images');

      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final extension = p.extension(imageFile.path); // Gets original file extension
      final filename = '${const Uuid().v4()}$extension';
      final localPath = p.join(imagesDir.path, filename);

      // Copy image to app directory
      await imageFile.copy(localPath);

      return localPath;
    } catch (e) {
      throw Exception('Failed to save image locally: $e');
    }
  }

  static Future<void> deleteImage(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete local image: $e');
    }
  }

  static Future<void> cleanupUnusedImages(List<String> usedPaths) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/administration_images');

      if (await imagesDir.exists()) {
        final allFiles = await imagesDir.list().toList();
        for (var file in allFiles) {
          if (file is File && !usedPaths.contains(file.path)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to cleanup unused images: $e');
    }
  }

  static Future<String> saveImageFromFirebase(String url) async {
    try {
      // Get the reference to the image in Firebase Storage
      final Reference ref = FirebaseStorage.instance.refFromURL(url);

      // Get the local application directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create a unique local file name
      final String fileName = p.basename(ref.fullPath);
      final String localPath = p.join(appDir.path, fileName);

      // Ensure the directory exists
      final File localFile = File(localPath);
      if (!await localFile.exists()) {
        await localFile.create(recursive: true);
      }

      // Download the file
      await ref.writeToFile(localFile);

      return localPath;
    } catch (e) {
      // print('Error saving image: $e');
      throw Exception('Failed to save image locally: $e');
    }
  }

  static File getFileFromLocalPath(String localPath) {
    try {
      final File file = File(localPath);
      if (file.existsSync()) {
        return file;
      } else {
        throw Exception('File does not exist at the given path: $localPath');
      }
    } catch (e) {
      throw Exception('Error retrieving file: $e');
    }
  }

}
