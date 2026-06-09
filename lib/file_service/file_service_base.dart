class FileOpenResult {
  const FileOpenResult({
    required this.content,
    required this.path,
    required this.name,
  });

  final String content;
  final String path;
  final String name;
}

abstract class FileService {
  Future<FileOpenResult?> openFile();
  Future<FileOpenResult?> openFilePath(String path);
  Future<String?> saveFileAs(String content);
  Future<String?> exportFile(
    String content,
    String fileName,
    List<String> allowedExtensions,
  );
  Future<void> saveFile(String content, String path);
}
