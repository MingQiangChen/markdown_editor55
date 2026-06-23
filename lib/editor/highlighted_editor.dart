import 'dart:async';
import 'package:flutter/material.dart';

import 'markdown_editor_highlighter.dart';

/// A Markdown editor with inline syntax highlighting.
///
/// Uses an overlay technique: a transparent [TextField] sits on top of a
/// highlighted [Text.rich] widget. Both share the same scroll controller and
/// text metrics so the highlighting aligns with the editable text.
///
/// Performance tiers:
/// - < 3000 lines: full syntax highlighting with debounce
/// - 3000-15000 lines: line-level cached highlighting (only re-highlight changed lines)
/// - > 15000 lines: highlighting disabled for smooth typing
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
  List<String> _lines = const [];
  TextSpan? _cachedHighlight;
  Timer? _highlightTimer;

  /// Line-level cache for large-file mode.
  List<TextSpan?> _lineCache = const [];
  /// Tracks code-block state at each line boundary (true = inside code block).
  List<bool> _codeBlockState = const [];

  static const EdgeInsets _contentPadding = EdgeInsets.all(18);
  static const TextStyle _defaultTextStyle = TextStyle(
    fontFamily: 'Consolas',
    fontSize: 15,
    height: 1.45,
  );

  static const Duration _highlightDebounce = Duration(milliseconds: 150);
  static const Duration _largeFileHighlightDebounce = Duration(milliseconds: 400);
  static const int _lineCacheThreshold = 3000;
  static const int _noHighlightThreshold = 15000;

  /// Performance tier for the current document size.
  _PerformanceTier get _tier {
    final lineCount = _lines.length;
    if (lineCount >= _noHighlightThreshold) return _PerformanceTier.none;
    if (lineCount >= _lineCacheThreshold) return _PerformanceTier.lineCache;
    return _PerformanceTier.full;
  }

  TextStyle get _baseTextStyle {
    return widget.textStyle ?? _defaultTextStyle;
  }

  @override
  void initState() {
    super.initState();
    _text = widget.controller.text;
    _lines = _text.split('\n');
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final newText = widget.controller.text;
    final oldLines = _lines;

    setState(() {
      _text = newText;
      _lines = newText.split('\n');
    });

    final tier = _tier;

    if (tier == _PerformanceTier.none) {
      _highlightTimer?.cancel();
      _cachedHighlight = null;
      _lineCache = const [];
      _codeBlockState = const [];
      return;
    }

    if (tier == _PerformanceTier.lineCache) {
      _invalidateLineCache(oldLines);
    }

    _scheduleHighlight();
  }

  /// Determine which lines changed and invalidate them in the cache.
  void _invalidateLineCache(List<String> oldLines) {
    final newLines = _lines;

    // If the cache is empty or line count changed drastically, rebuild fully.
    if (_lineCache.isEmpty ||
        (newLines.length - oldLines.length).abs() > 50) {
      _lineCache = List<TextSpan?>.filled(newLines.length, null);
      _codeBlockState = List<bool>.filled(newLines.length + 1, false);
      return;
    }

    // Find the first and last changed lines using common prefix/suffix.
    var firstChanged = 0;
    final minLen = oldLines.length < newLines.length
        ? oldLines.length
        : newLines.length;
    while (firstChanged < minLen &&
        oldLines[firstChanged] == newLines[firstChanged]) {
      firstChanged++;
    }

    var oldLast = oldLines.length - 1;
    var newLast = newLines.length - 1;
    while (oldLast > firstChanged &&
        newLast > firstChanged &&
        oldLines[oldLast] == newLines[newLast]) {
      oldLast--;
      newLast--;
    }

    // Invalidate from firstChanged to end of new lines (code block state
    // changes can cascade).
    final invalidateFrom = firstChanged;
    if (_lineCache.length != newLines.length) {
      _lineCache = List<TextSpan?>.filled(newLines.length, null);
      _codeBlockState = List<bool>.filled(newLines.length + 1, false);
    } else {
      for (var i = invalidateFrom; i < newLines.length; i++) {
        _lineCache[i] = null;
      }
    }
  }

  void _scheduleHighlight() {
    _highlightTimer?.cancel();

    final tier = _tier;
    if (tier == _PerformanceTier.none) return;

    final debounce = tier == _PerformanceTier.lineCache
        ? _largeFileHighlightDebounce
        : _highlightDebounce;

    _highlightTimer = Timer(debounce, () {
      if (!mounted) return;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final baseStyle = _baseTextStyle.copyWith(color: colorScheme.onSurface);

      if (tier == _PerformanceTier.lineCache) {
        _highlightLinesIncremental(baseStyle, colorScheme);
      } else {
        final highlight = highlightMarkdown(_text, baseStyle, colorScheme);
        if (!mounted) return;
        setState(() {
          _cachedHighlight = highlight;
        });
      }
    });
  }

  /// Incrementally highlight only invalidated lines.
  void _highlightLinesIncremental(TextStyle baseStyle, ColorScheme colorScheme) {
    final lines = _lines;
    final metaColor = colorScheme.onSurface.withValues(alpha: 0.45);
    final codeColor = colorScheme.tertiary;
    final codeBackground = colorScheme.surfaceContainerHighest;

    // Rebuild code-block state from scratch up to the first null cache entry.
    var firstNull = 0;
    while (firstNull < _lineCache.length && _lineCache[firstNull] != null) {
      firstNull++;
    }

    // Recompute code block state from the first invalidated line.
    var inCodeBlock = firstNull > 0 ? _codeBlockState[firstNull] : false;

    for (var i = firstNull; i < lines.length; i++) {
      if (_lineCache[i] != null) continue;

      final line = lines[i];

      if (line.trimLeft().startsWith('`')) {
        inCodeBlock = !inCodeBlock;
        _lineCache[i] = TextSpan(
          text: line,
          style: baseStyle.copyWith(color: metaColor),
        );
      } else if (inCodeBlock) {
        _lineCache[i] = TextSpan(
          text: line,
          style: baseStyle.copyWith(
            color: codeColor,
            background: Paint()..color = codeBackground.withValues(alpha: 0.3),
          ),
        );
      } else {
        // Use the full line highlighter for non-code-block lines.
        _lineCache[i] = highlightSingleLine(line, baseStyle, colorScheme);
      }

      // Update code block state after this line.
      if (i + 1 < _codeBlockState.length) {
        _codeBlockState[i + 1] = inCodeBlock;
      }
    }

    // Build the combined TextSpan.
    final rootChildren = <TextSpan>[];
    for (var i = 0; i < lines.length; i++) {
      rootChildren.add(_lineCache[i] ?? TextSpan(text: lines[i], style: baseStyle));
      if (i < lines.length - 1) {
        rootChildren.add(TextSpan(text: '\n', style: baseStyle));
      }
    }

    setState(() {
      _cachedHighlight = TextSpan(style: baseStyle, children: rootChildren);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleHighlight();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = _baseTextStyle.copyWith(color: colorScheme.onSurface);
    final tier = _tier;
    final useHighlighting = tier != _PerformanceTier.none;

    final TextSpan highlighted;
    if (!useHighlighting) {
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
            if (useHighlighting)
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
              style: useHighlighting
                  ? _baseTextStyle.copyWith(color: Colors.transparent)
                  : baseStyle,
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
    } else {
      return SingleChildScrollView(
        controller: _scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 3000,
            child: Stack(
              children: [
                if (useHighlighting)
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
                  style: useHighlighting
                      ? _baseTextStyle.copyWith(color: Colors.transparent)
                      : baseStyle,
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

enum _PerformanceTier { full, lineCache, none }
