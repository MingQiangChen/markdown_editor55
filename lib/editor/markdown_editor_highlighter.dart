import 'package:flutter/material.dart';

final _hrDashRegex = RegExp(r'^-{3,}$');
final _hrStarRegex = RegExp(r'^\*{3,}$');
final _hrUnderRegex = RegExp(r'^_{3,}$');
final _listItemRegex = RegExp(r'^(\s*)([-*+]|\d+\.)\s');
final _headingRegex = RegExp(r'^(#{1,6})\s(.*)');
final _blockquoteRegex = RegExp(r'^(>\s?)(.*)');
final _listDetailRegex = RegExp(r'^(\s*)([-*+]|\d+\.)(\s)(.*)');

TextSpan highlightMarkdown(
  String text,
  TextStyle baseStyle,
  ColorScheme colorScheme,
) {
  if (text.isEmpty) return TextSpan(text: '', style: baseStyle);

  final lines = text.split('\n');
  final rootChildren = <TextSpan>[];
  var inCodeBlock = false;

  final headingColor = colorScheme.primary;
  final metaColor = colorScheme.onSurface.withValues(alpha: 0.45);
  final codeColor = colorScheme.tertiary;
  final codeBackground = colorScheme.surfaceContainerHighest;
  final quoteColor = colorScheme.secondary;
  final listMarkerColor = colorScheme.primary;
  final hrColor = colorScheme.onSurface.withValues(alpha: 0.35);

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line.trimLeft().startsWith('`')) {
      inCodeBlock = !inCodeBlock;
      rootChildren.add(
        TextSpan(text: line, style: baseStyle.copyWith(color: metaColor)),
      );
    } else if (inCodeBlock) {
      rootChildren.add(
        TextSpan(
          text: line,
          style: baseStyle.copyWith(
            color: codeColor,
            background: Paint()..color = codeBackground.withValues(alpha: 0.3),
          ),
        ),
      );
    } else if (_isHorizontalRule(line)) {
      rootChildren.add(
        TextSpan(text: line, style: baseStyle.copyWith(color: hrColor)),
      );
    } else if (line.startsWith('#')) {
      rootChildren.add(
        _highlightHeading(
          line,
          baseStyle,
          headingColor,
          metaColor,
          colorScheme,
        ),
      );
    } else if (line.startsWith('>')) {
      rootChildren.add(
        _highlightBlockquote(line, baseStyle, quoteColor, colorScheme),
      );
    } else if (_isListItem(line)) {
      rootChildren.add(
        _highlightListItem(line, baseStyle, listMarkerColor, colorScheme),
      );
    } else {
      rootChildren.add(_highlightInline(line, baseStyle, colorScheme));
    }

    if (i < lines.length - 1) {
      rootChildren.add(TextSpan(text: '\n', style: baseStyle));
    }
  }

  return TextSpan(style: baseStyle, children: rootChildren);
}

bool _isHorizontalRule(String line) {
  final trimmed = line.trim();
  if (trimmed.length < 3) return false;
  final noSpaces = trimmed.replaceAll(' ', '');
  return _hrDashRegex.hasMatch(noSpaces) ||
      _hrStarRegex.hasMatch(noSpaces) ||
      _hrUnderRegex.hasMatch(noSpaces);
}

bool _isListItem(String line) {
  return _listItemRegex.hasMatch(line);
}

TextSpan _highlightHeading(
  String line,
  TextStyle baseStyle,
  Color headingColor,
  Color metaColor,
  ColorScheme colorScheme,
) {
  final match = _headingRegex.firstMatch(line);
  if (match == null) {
    return TextSpan(text: line, style: baseStyle.copyWith(color: headingColor));
  }
  final markers = match.group(1)!;
  final rest = match.group(2)!;
  return TextSpan(
    style: baseStyle,
    children: [
      TextSpan(text: markers, style: baseStyle.copyWith(color: metaColor)),
      TextSpan(text: ' ', style: baseStyle),
      _highlightInline(
        rest,
        baseStyle,
        _headingScheme(headingColor, colorScheme),
      ),
    ],
  );
}

ColorScheme _headingScheme(Color headingColor, ColorScheme originalScheme) =>
    ColorScheme(
      brightness: originalScheme.brightness,
      primary: headingColor,
      onPrimary: originalScheme.onPrimary,
      secondary: headingColor,
      onSecondary: originalScheme.onSecondary,
      tertiary: headingColor,
      onTertiary: originalScheme.onTertiary,
      error: headingColor,
      onError: originalScheme.onError,
      surface: originalScheme.surface,
      onSurface: headingColor,
    );

TextSpan _highlightBlockquote(
  String line,
  TextStyle baseStyle,
  Color quoteColor,
  ColorScheme colorScheme,
) {
  final match = _blockquoteRegex.firstMatch(line);
  if (match == null) {
    return TextSpan(text: line, style: baseStyle.copyWith(color: quoteColor));
  }
  return TextSpan(
    style: baseStyle,
    children: [
      TextSpan(
        text: match.group(1)!,
        style: baseStyle.copyWith(color: quoteColor),
      ),
      _highlightInline(match.group(2)!, baseStyle, colorScheme),
    ],
  );
}

TextSpan _highlightListItem(
  String line,
  TextStyle baseStyle,
  Color markerColor,
  ColorScheme colorScheme,
) {
  final match = _listDetailRegex.firstMatch(line);
  if (match == null) {
    return _highlightInline(line, baseStyle, colorScheme);
  }
  final indent = match.group(1)!;
  final marker = match.group(2)!;
  final space = match.group(3)!;
  final rest = match.group(4)!;
  return TextSpan(
    style: baseStyle,
    children: [
      TextSpan(text: indent, style: baseStyle),
      TextSpan(text: marker, style: baseStyle.copyWith(color: markerColor)),
      TextSpan(text: space, style: baseStyle),
      _highlightInline(rest, baseStyle, colorScheme),
    ],
  );
}

TextSpan _highlightInline(
  String text,
  TextStyle baseStyle,
  ColorScheme colorScheme,
) {
  if (text.isEmpty) return TextSpan(text: text, style: baseStyle);

  final spans = <TextSpan>[];
  final buffer = StringBuffer();
  var i = 0;

  final codeColor = colorScheme.tertiary;
  final codeBackground = colorScheme.surfaceContainerHighest;
  final linkColor = colorScheme.primary;
  final emphasisColor = colorScheme.secondary;
  final metaColor = colorScheme.onSurface.withValues(alpha: 0.45);

  void flush() {
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
      buffer.clear();
    }
  }

  while (i < text.length) {
    if (text[i] == '') {
      final end = text.indexOf('`', i + 1);
      if (end != -1) {
        flush();
        spans.add(
          TextSpan(text: '', style: baseStyle.copyWith(color: metaColor)),
        );
        spans.add(
          TextSpan(
            text: text.substring(i + 1, end),
            style: baseStyle.copyWith(
              color: codeColor,
              background:
                  Paint()..color = codeBackground.withValues(alpha: 0.5),
            ),
          ),
        );
        spans.add(
          TextSpan(text: '', style: baseStyle.copyWith(color: metaColor)),
        );
        i = end + 1;
        continue;
      }
    }

    if (text[i] == '!' && i + 1 < text.length && text[i + 1] == '[') {
      final closeBracket = text.indexOf(']', i + 2);
      if (closeBracket != -1 &&
          closeBracket + 1 < text.length &&
          text[closeBracket + 1] == '(') {
        final closeParen = text.indexOf(')', closeBracket + 2);
        if (closeParen != -1) {
          flush();
          spans.add(
            TextSpan(text: '![', style: baseStyle.copyWith(color: metaColor)),
          );
          spans.add(
            TextSpan(
              text: text.substring(i + 2, closeBracket),
              style: baseStyle.copyWith(color: linkColor),
            ),
          );
          spans.add(
            TextSpan(text: '](', style: baseStyle.copyWith(color: metaColor)),
          );
          spans.add(
            TextSpan(
              text: text.substring(closeBracket + 2, closeParen),
              style: baseStyle.copyWith(color: metaColor),
            ),
          );
          spans.add(
            TextSpan(text: ')', style: baseStyle.copyWith(color: metaColor)),
          );
          i = closeParen + 1;
          continue;
        }
      }
    }

    if (text[i] == '[') {
      final closeBracket = text.indexOf(']', i + 1);
      if (closeBracket != -1 &&
          closeBracket + 1 < text.length &&
          text[closeBracket + 1] == '(') {
        final closeParen = text.indexOf(')', closeBracket + 2);
        if (closeParen != -1) {
          flush();
          spans.add(
            TextSpan(text: '[', style: baseStyle.copyWith(color: metaColor)),
          );
          spans.add(
            TextSpan(
              text: text.substring(i + 1, closeBracket),
              style: baseStyle.copyWith(color: linkColor),
            ),
          );
          spans.add(
            TextSpan(text: '](', style: baseStyle.copyWith(color: metaColor)),
          );
          spans.add(
            TextSpan(
              text: text.substring(closeBracket + 2, closeParen),
              style: baseStyle.copyWith(color: metaColor),
            ),
          );
          spans.add(
            TextSpan(text: ')', style: baseStyle.copyWith(color: metaColor)),
          );
          i = closeParen + 1;
          continue;
        }
      }
    }

    if (text[i] == '*' && i + 1 < text.length && text[i + 1] == '*') {
      final end = text.indexOf('**', i + 2);
      if (end != -1) {
        flush();
        spans.add(
          TextSpan(text: '**', style: baseStyle.copyWith(color: metaColor)),
        );
        spans.add(
          TextSpan(
            text: text.substring(i + 2, end),
            style: baseStyle.copyWith(color: emphasisColor),
          ),
        );
        spans.add(
          TextSpan(text: '**', style: baseStyle.copyWith(color: metaColor)),
        );
        i = end + 2;
        continue;
      }
    }

    if (text[i] == '*') {
      final end = text.indexOf('*', i + 1);
      if (end != -1 && end > i + 1) {
        flush();
        spans.add(
          TextSpan(text: '*', style: baseStyle.copyWith(color: metaColor)),
        );
        spans.add(
          TextSpan(
            text: text.substring(i + 1, end),
            style: baseStyle.copyWith(color: emphasisColor),
          ),
        );
        spans.add(
          TextSpan(text: '*', style: baseStyle.copyWith(color: metaColor)),
        );
        i = end + 1;
        continue;
      }
    }

    buffer.write(text[i]);
    i++;
  }

  flush();
  return TextSpan(style: baseStyle, children: spans);
}

/// Highlight a single line of Markdown (used by the line-cached highlighter).
///
/// This does NOT handle code-block state; the caller is responsible for
/// detecting code fences and passing pre-styled spans for code-block lines.
TextSpan highlightSingleLine(
  String line,
  TextStyle baseStyle,
  ColorScheme colorScheme,
) {
  final headingColor = colorScheme.primary;
  final metaColor = colorScheme.onSurface.withValues(alpha: 0.45);
  final quoteColor = colorScheme.secondary;
  final listMarkerColor = colorScheme.primary;
  final hrColor = colorScheme.onSurface.withValues(alpha: 0.35);

  if (line.trimLeft().startsWith('`')) {
    return TextSpan(text: line, style: baseStyle.copyWith(color: metaColor));
  }

  // Horizontal rule
  if (_isSingleLineHR(line)) {
    return TextSpan(text: line, style: baseStyle.copyWith(color: hrColor));
  }

  // Heading
  if (line.startsWith('#')) {
    return _highlightHeading(line, baseStyle, headingColor, metaColor, colorScheme);
  }

  // Blockquote
  if (line.startsWith('>')) {
    return _highlightBlockquote(line, baseStyle, quoteColor, colorScheme);
  }

  // List item
  if (_listItemRegex.hasMatch(line)) {
    return _highlightListItem(line, baseStyle, listMarkerColor, colorScheme);
  }

  // Plain line with inline formatting
  return _highlightInline(line, baseStyle, colorScheme);
}

bool _isSingleLineHR(String line) {
  final trimmed = line.trim();
  if (trimmed.length < 3) return false;
  final noSpaces = trimmed.replaceAll(' ', '');
  return _hrDashRegex.hasMatch(noSpaces) ||
      _hrStarRegex.hasMatch(noSpaces) ||
      _hrUnderRegex.hasMatch(noSpaces);
}
