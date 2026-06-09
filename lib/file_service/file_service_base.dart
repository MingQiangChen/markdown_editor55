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
  Future<String?> saveFileAs(String content);
  Future<void> saveFile(String content, String path);
}
