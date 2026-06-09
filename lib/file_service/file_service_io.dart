import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'file_service_base.dart';

FileService createFileService() => _IoFileService();

class _IoFileService implements FileService {
  @override
  Future<FileOpenResult?> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md'],
    );
    if (result == null || result.files.isEmpty) return null;

    final platformFile = result.files.single;
    final path = platformFile.path;
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    return FileOpenResult(
      content: content,
      path: path,
      name: platformFile.name,
    );
  }

  @override
  Future<String?> saveFileAs(String content) async {
    final path = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['md'],
      fileName: 'untitled.md',
    );
    if (path == null) return null;

    final file = File(path);
    await file.writeAsString(content);
    return path;
  }

  @override
  Future<void> saveFile(String content, String path) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
