import 'file_service_base.dart';

FileService createFileService() => _StubFileService();

class _StubFileService implements FileService {
  @override
  Future<FileOpenResult?> openFile() async => null;

  @override
  Future<FileOpenResult?> openFilePath(String path) async => null;

  @override
  Future<String?> saveFileAs(String content) async => null;

  @override
  Future<void> saveFile(String content, String path) async {}

  @override
  Future<String?> exportFile(
    String content,
    String fileName,
    List<String> allowedExtensions,
  ) async => null;

  @override
  Future<DateTime?> getLastModified(String path) async => null;
}
