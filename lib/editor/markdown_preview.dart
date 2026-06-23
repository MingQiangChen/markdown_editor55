import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'markdown_extensions/markdown_extensions.dart';
import 'markdown_syntax_highlighter.dart';

/// A Markdown preview widget with debounced rendering.
///
/// Rendering delay scales with document size to keep the UI responsive:
/// - < 10 KB: 200 ms
/// - 10-100 KB: 500 ms
/// - > 100 KB: 1000 ms
class MarkdownPreview extends StatefulWidget {
  const MarkdownPreview({super.key, required this.data});

  final String data;

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}

class _MarkdownPreviewState extends State<MarkdownPreview> {
  String _renderedData = '';
  Timer? _debounceTimer;

  static const Duration _smallDocDebounce = Duration(milliseconds: 200);
  static const Duration _mediumDocDebounce = Duration(milliseconds: 500);
  static const Duration _largeDocDebounce = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _renderedData = widget.data;
  }

  @override
  void didUpdateWidget(MarkdownPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _scheduleRender();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Duration _debounceForSize() {
    final len = widget.data.length;
    if (len > 100000) return _largeDocDebounce;
    if (len > 10000) return _mediumDocDebounce;
    return _smallDocDebounce;
  }

  void _scheduleRender() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceForSize(), () {
      if (mounted) {
        setState(() {
          _renderedData = widget.data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final styleSheet = MarkdownStyleSheet(
      h1: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      h4: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
      code: const TextStyle(fontFamily: 'Consolas', fontSize: 14, height: 1.4),
      codeblockDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
        color: colorScheme.surfaceContainerHighest,
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
    );

    return ColoredBox(
      color: colorScheme.surface,
      child: Markdown(
        data: _renderedData.isEmpty ? 'Preview will appear here.' : _renderedData,
        selectable: true,
        styleSheet: styleSheet,
        syntaxHighlighter: MarkdownSyntaxHighlighter(colorScheme: colorScheme),
        padding: const EdgeInsets.all(22),
        inlineSyntaxes: [MathInlineSyntax()],
        blockSyntaxes: [MathBlockSyntax(), MermaidBlockSyntax()],
        builders: {'math': MathBuilder(), 'mermaid': MermaidBuilder()},
      ),
    );
  }
}
