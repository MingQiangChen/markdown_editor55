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
      lastModified: await file.lastModified(),
    );
  }

  @override
  Future<FileOpenResult?> openFilePath(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    return FileOpenResult(
      content: content,
      path: path,
      name: path.split(Platform.pathSeparator).last,
      lastModified: await file.lastModified(),
    );
  }

  @override
  Future<String?> saveFileAs(String content) async {
    // Windows 上禁用 lockParentWindow，避免无法输入文件名的问题
    final bool lockParent = !Platform.isWindows;
    
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Markdown File',
      type: FileType.custom,
      allowedExtensions: ['md'],
      fileName: 'untitled.md',
      lockParentWindow: lockParent,
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

  @override
  Future<String?> exportFile(
    String content,
    String fileName,
    List<String> allowedExtensions,
  ) async {
    // Windows 上禁用 lockParentWindow，避免无法输入文件名的问题
    final bool lockParent = !Platform.isWindows;
    
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export File',
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      fileName: fileName,
      lockParentWindow: lockParent,
    );
    if (path == null) return null;

    final file = File(path);
    await file.writeAsString(content);
    return path;
  }

  @override
  Future<DateTime?> getLastModified(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.lastModified();
  }
}
