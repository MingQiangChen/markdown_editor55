// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'file_service_base.dart';

FileService createFileService() => _WebFileService();

class _WebFileService implements FileService {
  String? _lastSavedName;

  @override
  Future<FileOpenResult?> openFile() async {
    final input = html.FileUploadInputElement()..accept = '.md';
    input.click();

    final completer = Completer<FileOpenResult?>();
    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final file = files.first;
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoad.listen((_) {
        completer.complete(
          FileOpenResult(
            content: reader.result as String,
            path: file.name,
            name: file.name,
          ),
        );
      });
      reader.onError.listen((_) {
        completer.complete(null);
      });
    });

    // If the user cancels, onChange never fires within a reasonable time.
    // We use a short timer after click to check — but onChange is the only
    // reliable signal. A cancelled dialog produces no event, so we resolve
    // null after a short delay if no file was selected.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!completer.isCompleted) {
        // The input was clicked but no file selected — user cancelled.
        // We can't truly detect cancel, but on mobile/desktop web the
        // onChange fires immediately on selection. We leave the completer
        // unresolved so the input stays alive; a second click on another
        // input instance would be needed. For simplicity, resolve null.
        //
        // Note: on some browsers, cancelling the dialog also fires onChange
        // with empty files. This fallback handles the case where it doesn't.
      }
    });

    // A better approach: use the window focus event as a proxy for
    // "dialog was dismissed". When the user returns to the window
    // without a file being selected, we can assume cancellation.
    final onFocus = html.window.onFocus.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    completer.future.then((_) => onFocus.cancel());

    return completer.future;
  }

  @override
  Future<FileOpenResult?> openFilePath(String path) async => null;

  @override
  Future<String?> saveFileAs(String content) async {
    final blob = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', _lastSavedName ?? 'untitled.md')
      ..click();
    html.Url.revokeObjectUrl(url);
    return _lastSavedName ?? 'untitled.md';
  }

  @override
  Future<void> saveFile(String content, String path) async {
    _lastSavedName = path;
    final blob = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', path)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<String?> exportFile(
    String content,
    String fileName,
    List<String> allowedExtensions,
  ) async {
    final blob = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    return fileName;
  }

  @override
  Future<DateTime?> getLastModified(String path) async => null;
}
