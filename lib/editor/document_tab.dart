import 'package:flutter/material.dart';

/// Represents a single document tab in the editor.
class DocumentTab {
  DocumentTab({
    required this.id,
    required this.title,
    required this.controller,
    required this.focusNode,
    this.filePath,
    this.isDirty = false,
  });

  final String id;
  String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  String? filePath;
  bool isDirty;

  /// Creates a new untitled tab with empty content.
  factory DocumentTab.empty({required String id}) {
    return DocumentTab(
      id: id,
      title: 'Untitled',
      controller: TextEditingController(),
      focusNode: FocusNode(),
    );
  }

  /// Creates a tab from an opened file.
  factory DocumentTab.fromFile({
    required String id,
    required String filePath,
    required String fileName,
    required String content,
  }) {
    return DocumentTab(
      id: id,
      title: fileName,
      controller: TextEditingController(text: content),
      focusNode: FocusNode(),
      filePath: filePath,
    );
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
