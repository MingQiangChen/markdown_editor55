import 'dart:io';
import 'dart:typed_data';

/// Handles saving images to disk alongside markdown files.
class ImageService {
  /// Saves image data to an `images/` folder next to the markdown file.
  ///
  /// Returns the relative path suitable for a Markdown image tag,
  /// e.g. `images/screenshot_20260616_143022.png`.
  ///
  /// If [markdownFilePath] is null (unsaved document), the image is saved
  /// in a temp directory and an absolute path is returned.
  static Future<String?> saveImage({
    required Uint8List bytes,
    required String extension,
    String? markdownFilePath,
  }) async {
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:\-T]'), '')
        .substring(0, 14);
    final fileName = 'img_$timestamp.$extension';

    Directory imageDir;
    if (markdownFilePath != null) {
      final docDir = File(markdownFilePath).parent;
      imageDir = Directory(
          '${docDir.path}${Platform.pathSeparator}images');
    } else {
      imageDir = Directory(
          '${Directory.systemTemp.path}${Platform.pathSeparator}markdown_editor_images');
    }

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // Avoid overwriting existing files
    var filePath = '${imageDir.path}${Platform.pathSeparator}$fileName';
    var counter = 1;
    while (await File(filePath).exists()) {
      final newName = 'img_${timestamp}_$counter.$extension';
      filePath = '${imageDir.path}${Platform.pathSeparator}$newName';
      counter++;
    }

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (markdownFilePath != null) {
      final savedName = filePath.split(Platform.pathSeparator).last;
      return 'images/$savedName';
    }
    return file.path;
  }

  /// Returns the file extension from a MIME type, defaulting to 'png'.
  static String extensionFromMime(String? mime) {
    if (mime == null) return 'png';
    return switch (mime) {
      'image/png' => 'png',
      'image/jpeg' => 'jpg',
      'image/gif' => 'gif',
      'image/webp' => 'webp',
      'image/bmp' => 'bmp',
      _ => 'png',
    };
  }
}
