import 'dart:async';
import 'package:flutter/material.dart';

import 'markdown_editor_highlighter.dart';

/// A Markdown editor with inline syntax highlighting.
///
/// Uses an overlay technique: a transparent [TextField] sits on top of a
/// highlighted [Text.rich] widget. Both share the same scroll controller and
/// text metrics so the highlighting aligns with the editable text.
///
/// For large documents (> [_largeFileLineThreshold] lines), syntax highlighting
/// is automatically disabled to maintain smooth typing performance.
class HighlightedMarkdownEditor extends StatefulWidget {
  const HighlightedMarkdownEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    this.wordWrap = true,
    this.textStyle,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool wordWrap;
  final TextStyle? textStyle;

  @override
  State<HighlightedMarkdownEditor> createState() =>
      _HighlightedMarkdownEditorState();
}

class _HighlightedMarkdownEditorState extends State<HighlightedMarkdownEditor> {
  final ScrollController _scrollController = ScrollController();
  String _text = '';
  TextSpan? _cachedHighlight;
  Timer? _highlightTimer;
  bool _isLargeFile = false;

  static const EdgeInsets _contentPadding = EdgeInsets.all(18);
  static const TextStyle _defaultTextStyle = TextStyle(
    fontFamily: 'Consolas',
    fontSize: 15,
    height: 1.45,
  );

  static const Duration _highlightDebounce = Duration(milliseconds: 150);
  static const Duration _largeFileHighlightDebounce = Duration(milliseconds: 500);
  static const int _largeFileLineThreshold = 5000;

  TextStyle get _baseTextStyle {
    return widget.textStyle ?? _defaultTextStyle;
  }

  @override
  void initState() {
    super.initState();
    _text = widget.controller.text;
    _isLargeFile = _countLines(_text) >= _largeFileLineThreshold;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _scrollController.dispose();
    super.dispose();
  }

  static int _countLines(String text) {
    var count = 1;
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 0x0A) count++;
    }
    return count;
  }

  void _onTextChanged() {
    final newText = widget.controller.text;
    final wasLargeFile = _isLargeFile;
    _isLargeFile = _countLines(newText) >= _largeFileLineThreshold;

    setState(() {
      _text = newText;
    });

    if (_isLargeFile && !wasLargeFile) {
      setState(() {
        _cachedHighlight = null;
      });
    }

    _scheduleHighlight();
  }

  void _scheduleHighlight() {
    _highlightTimer?.cancel();

    if (_isLargeFile) {
      setState(() {
        _cachedHighlight = null;
      });
      return;
    }

    final debounce = _isLargeFile ? _largeFileHighlightDebounce : _highlightDebounce;
    _highlightTimer = Timer(debounce, () {
      if (!mounted) return;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final baseStyle = _baseTextStyle.copyWith(color: colorScheme.onSurface);
      final highlight = highlightMarkdown(_text, baseStyle, colorScheme);
      if (!mounted) return;
      setState(() {
        _cachedHighlight = highlight;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLargeFile) {
      _scheduleHighlight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = _baseTextStyle.copyWith(color: colorScheme.onSurface);

    final TextSpan highlighted;
    if (_isLargeFile) {
      highlighted = TextSpan(text: _text, style: baseStyle);
    } else {
      highlighted =
          _cachedHighlight ?? highlightMarkdown(_text, baseStyle, colorScheme);
    }

    if (widget.wordWrap) {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          children: [
            if (!_isLargeFile)
              IgnorePointer(
                child: Padding(
                  padding: _contentPadding,
                  child: Text.rich(highlighted),
                ),
              ),
            TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              scrollController: _scrollController,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              style: _isLargeFile
                  ? baseStyle
                  : _baseTextStyle.copyWith(color: Colors.transparent),
              cursorColor: colorScheme.onSurface,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: _isLargeFile ? _contentPadding : _contentPadding,
                hintText: 'Write Markdown...',
                hintStyle: _baseTextStyle.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        controller: _scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 3000,
            child: Stack(
              children: [
                if (!_isLargeFile)
                  IgnorePointer(
                    child: Padding(
                      padding: _contentPadding,
                      child: Text.rich(highlighted, softWrap: false),
                    ),
                  ),
                TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  scrollController: _scrollController,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: _isLargeFile
                      ? baseStyle
                      : _baseTextStyle.copyWith(color: Colors.transparent),
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
          ),
        ),
      );
    }
  }
}