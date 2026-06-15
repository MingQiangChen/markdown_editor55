import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'markdown_extensions/markdown_extensions.dart';
import 'markdown_syntax_highlighter.dart';

/// A Markdown preview widget with debounced rendering.
///
/// For large documents, rendering is debounced to avoid blocking the UI
/// during rapid typing. The debounce delay scales with document size.
class MarkdownPreview extends StatefulWidget {
  const MarkdownPreview({super.key, required this.data});

  final String data;

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}

class _MarkdownPreviewState extends State<MarkdownPreview> {
  String _renderedData = '';
  Timer? _debounceTimer;

  static const int _largeDocThreshold = 10000;
  static const Duration _normalDebounce = Duration(milliseconds: 200);
  static const Duration _largeDocDebounce = Duration(milliseconds: 500);

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

  void _scheduleRender() {
    _debounceTimer?.cancel();
    final isLargeDoc = widget.data.length > _largeDocThreshold;
    final delay = isLargeDoc ? _largeDocDebounce : _normalDebounce;
    _debounceTimer = Timer(delay, () {
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