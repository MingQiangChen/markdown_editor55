import 'package:flutter/material.dart';

class MarkdownTextEditor extends StatelessWidget {
  const MarkdownTextEditor({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(18),
        hintText: 'Write Markdown...',
      ),
      style: const TextStyle(
        fontFamily: 'Consolas',
        fontSize: 15,
        height: 1.45,
      ),
    );
  }
}
