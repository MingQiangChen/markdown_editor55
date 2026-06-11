import 'package:flutter/material.dart';

import 'markdown_editor_highlighter.dart';

/// A Markdown editor with inline syntax highlighting.
///
/// Uses an overlay technique: a transparent [TextField] sits on top of a
/// highlighted [Text.rich] widget. Both share the same scroll controller and
/// text metrics so the highlighting aligns with the editable text.
class HighlightedMarkdownEditor extends StatefulWidget {
  const HighlightedMarkdownEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    this.wordWrap = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool wordWrap;

  @override
  State<HighlightedMarkdownEditor> createState() =>
      _HighlightedMarkdownEditorState();
}

class _HighlightedMarkdownEditorState extends State<HighlightedMarkdownEditor> {
  final ScrollController _scrollController = ScrollController();
  String _text = '';

  static const EdgeInsets _contentPadding = EdgeInsets.all(18);
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Consolas',
    fontSize: 15,
    height: 1.45,
  );

  @override
  void initState() {
    super.initState();
    _text = widget.controller.text;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _text = widget.controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = _baseTextStyle.copyWith(color: colorScheme.onSurface);

    final highlighted = highlightMarkdown(_text, baseStyle, colorScheme);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          // Background: syntax-highlighted text (not interactive).
          IgnorePointer(
            child: Padding(
              padding: _contentPadding,
              child: Text.rich(highlighted),
            ),
          ),
          // Foreground: transparent editable text field.
          // Note: no expands:true — inside SingleChildScrollView the vertical
          // constraint is unbounded, so expands would crash ("hasSize" assert).
          // maxLines:null lets the field grow naturally with content.
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            scrollController: _scrollController,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            style: _baseTextStyle.copyWith(color: Colors.transparent),
            cursorColor: colorScheme.onSurface,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: _contentPadding,
              hintText: 'Write Markdown...',
              hintStyle: _baseTextStyle.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}