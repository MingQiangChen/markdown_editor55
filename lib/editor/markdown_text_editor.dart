import 'package:flutter/material.dart';

import 'highlighted_editor.dart';

class MarkdownTextEditor extends StatelessWidget {
  const MarkdownTextEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    this.wordWrap = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool wordWrap;

  @override
  Widget build(BuildContext context) {
    return HighlightedMarkdownEditor(
      controller: controller,
      focusNode: focusNode,
      wordWrap: wordWrap,
    );
  }
}
