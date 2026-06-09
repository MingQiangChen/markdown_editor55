import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownSyntaxHighlighter extends SyntaxHighlighter {
  MarkdownSyntaxHighlighter({required this.colorScheme});

  final ColorScheme colorScheme;

  // Common keywords across languages.
  static final _keywordPattern = RegExp(
    r'\b(abstract|as|async|await|break|case|catch|class|const|continue|'
    r'def|do|else|enum|extends|final|finally|for|fun|function|'
    r'if|implements|import|in|interface|is|late|let|mixin|new|'
    r'of|on|override|package|private|protected|public|return|'
    r'static|super|switch|this|throw|try|type|typedef|var|void|'
    r'while|with|yield|true|false|null|print|console|log|require|'
    r'module|export|from|int|double|String|bool|List|Map|Set|Future|'
    r'Stream|int\b|double\b|string\b|boolean\b|number\b)\b',
  );

  static final _stringPattern = RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'");
  static final _doubleStringPattern = RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"');
  static final _backtickPattern = RegExp(r'`[^`\\]*(?:\\.[^`\\]*)*`');
  static final _commentPattern = RegExp(r'//.*$|#.*$', multiLine: true);
  static final _blockCommentPattern = RegExp(r'/\*[\s\S]*?\*/');
  static final _numberPattern = RegExp(r'\b\d+\.?\d*\b');
  static final _annotationPattern = RegExp(r'@\w+');

  @override
  TextSpan format(String source) {
    final spans = <TextSpan>[];
    var pos = 0;

    // Collect all matches across patterns.
    final matches = <_HighlightMatch>[];

    void addMatches(RegExp pattern, _TokenType type) {
      for (final match in pattern.allMatches(source)) {
        matches.add(_HighlightMatch(match.start, match.end, type));
      }
    }

    // Order matters: block comments before single-line (they may overlap).
    addMatches(_blockCommentPattern, _TokenType.comment);
    addMatches(_commentPattern, _TokenType.comment);
    // Remove string patterns from inside comments by only adding if not
    // overlapping with existing comment matches.
    addMatches(_stringPattern, _TokenType.string);
    addMatches(_doubleStringPattern, _TokenType.string);
    addMatches(_backtickPattern, _TokenType.string);
    addMatches(_keywordPattern, _TokenType.keyword);
    addMatches(_annotationPattern, _TokenType.annotation);
    addMatches(_numberPattern, _TokenType.number);

    // Sort by start position, longer matches first for ties.
    matches.sort((a, b) {
      final cmp = a.start.compareTo(b.start);
      if (cmp != 0) return cmp;
      return b.end.compareTo(a.end);
    });

    // Remove overlapping matches (prefer earlier ones due to priority order).
    final filtered = <_HighlightMatch>[];
    for (final m in matches) {
      // Skip if this range is already covered by a higher-priority match.
      final overlaps = filtered.any(
        (f) => m.start >= f.start && m.start < f.end,
      );
      if (!overlaps) {
        filtered.add(m);
      }
    }

    // Also remove filtered items that overlap each other in the wrong order.
    filtered.sort((a, b) {
      final cmp = a.start.compareTo(b.start);
      if (cmp != 0) return cmp;
      return b.end.compareTo(a.end);
    });

    // Build spans from filtered matches.
    pos = 0;
    for (final m in filtered) {
      if (m.start > pos) {
        spans.add(TextSpan(text: source.substring(pos, m.start)));
      }
      spans.add(
        TextSpan(
          text: source.substring(m.start, m.end),
          style: _styleForType(m.type),
        ),
      );
      pos = m.end;
    }

    if (pos < source.length) {
      spans.add(TextSpan(text: source.substring(pos)));
    }

    return TextSpan(style: _baseStyle, children: spans);
  }

  TextStyle get _baseStyle => TextStyle(
    fontFamily: 'Consolas',
    fontSize: 14,
    height: 1.4,
    color: colorScheme.onSurface,
  );

  TextStyle _styleForType(_TokenType type) {
    return switch (type) {
      _TokenType.keyword => TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        height: 1.4,
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
      _TokenType.string => TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        height: 1.4,
        color: colorScheme.tertiary,
      ),
      _TokenType.comment => TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        height: 1.4,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
      _TokenType.number => TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        height: 1.4,
        color: colorScheme.error,
      ),
      _TokenType.annotation => TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        height: 1.4,
        color: colorScheme.secondary,
      ),
    };
  }
}

enum _TokenType { keyword, string, comment, number, annotation }

class _HighlightMatch {
  final int start;
  final int end;
  final _TokenType type;

  const _HighlightMatch(this.start, this.end, this.type);
}
