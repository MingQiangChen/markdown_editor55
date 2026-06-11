import 'package:flutter/material.dart';

/// Highlights Markdown syntax using color-only styling.
///
/// All returned spans share the same [baseStyle] metrics (font family, size,
/// height, weight) so the highlighted text aligns perfectly with a transparent
/// [TextField] overlay.
TextSpan highlightMarkdown(
  String text,
  TextStyle baseStyle,
  ColorScheme colorScheme,
) {
  if (text.isEmpty) {
    return TextSpan(text: '', style: baseStyle);
  }

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

    // Fenced code block delimiters.
    if (line.trimLeft().startsWith('```')) {
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
        _highlightHeading(line, baseStyle, headingColor, metaColor),
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
  return RegExp(r'^-{3,}$').hasMatch(noSpaces) ||
      RegExp(r'^\*{3,}$').hasMatch(noSpaces) ||
      RegExp(r'^_{3,}$').hasMatch(noSpaces);
}

bool _isListItem(String line) {
  return RegExp(r'^(\s*)([-*+]|\d+\.)\s').hasMatch(line);
}

TextSpan _highlightHeading(
  String line,
  TextStyle baseStyle,
  Color headingColor,
  Color metaColor,
) {
  final match = RegExp(r'^(#{1,6})\s(.*)').firstMatch(line);
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
      _highlightInline(rest, baseStyle, _headingScheme(headingColor)),
    ],
  );
}

/// Returns a [ColorScheme] clone where [ColorScheme.primary] is replaced so
/// inline elements inside headings pick up the heading color.
ColorScheme _headingScheme(Color headingColor) => ColorScheme(
  brightness: Brightness.light,
  primary: headingColor,
  onPrimary: Colors.white,
  secondary: headingColor,
  onSecondary: Colors.white,
  tertiary: headingColor,
  onTertiary: Colors.white,
  error: headingColor,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: headingColor,
);

TextSpan _highlightBlockquote(
  String line,
  TextStyle baseStyle,
  Color quoteColor,
  ColorScheme colorScheme,
) {
  final match = RegExp(r'^(>\s?)(.*)').firstMatch(line);
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
  final match = RegExp(r'^(\s*)([-*+]|\d+\.)(\s)(.*)').firstMatch(line);
  if (match == null) {
    return _highlightInline(line, baseStyle, colorScheme);
  }
  final indent = match.group(1)!;
  final marker = match.group(2)!;
  final space = match.group(3)!;
  final rest = match.group(4)!;

  final children = <TextSpan>[
    TextSpan(text: indent, style: baseStyle),
    TextSpan(text: marker, style: baseStyle.copyWith(color: markerColor)),
    TextSpan(text: space, style: baseStyle),
  ];

  // Task list checkbox.
  final taskMatch = RegExp(r'^\[([ xX])\]\s(.*)').firstMatch(rest);
  if (taskMatch != null) {
    final checkbox = '[${taskMatch.group(1)!}]';
    final isDone = taskMatch.group(1)!.toLowerCase() == 'x';
    children.add(
      TextSpan(
        text: checkbox,
        style: baseStyle.copyWith(
          color:
              isDone
                  ? markerColor
                  : colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
    children.add(TextSpan(text: ' ', style: baseStyle));
    children.add(_highlightInline(taskMatch.group(2)!, baseStyle, colorScheme));
  } else {
    children.add(_highlightInline(rest, baseStyle, colorScheme));
  }

  return TextSpan(style: baseStyle, children: children);
}

/// Highlights inline Markdown: bold, italic, inline code, links, images.
TextSpan _highlightInline(
  String text,
  TextStyle baseStyle,
  ColorScheme colorScheme,
) {
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
    // Inline code: `...`
    if (text[i] == '`') {
      final end = text.indexOf('`', i + 1);
      if (end != -1) {
        flush();
        spans.add(
          TextSpan(text: '`', style: baseStyle.copyWith(color: metaColor)),
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
          TextSpan(text: '`', style: baseStyle.copyWith(color: metaColor)),
        );
        i = end + 1;
        continue;
      }
    }

    // Image: ![alt](url)
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

    // Link: [text](url)
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

    // Bold: **...**
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

    // Italic: *...*
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
