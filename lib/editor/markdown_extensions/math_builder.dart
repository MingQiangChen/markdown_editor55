import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Builder for math elements - displays as formatted text
class MathBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final latex = element.attributes['latex'] ?? '';
    final isDisplay = element.attributes['display'] == 'true';
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isDisplay ? 16.0 : 2.0,
        horizontal: isDisplay ? 8.0 : 0.0,
      ),
      padding: EdgeInsets.all(isDisplay ? 12.0 : 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border:
            isDisplay
                ? Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                )
                : null,
      ),
      child: SelectableText(
        latex,
        style: TextStyle(
          fontFamily: 'Consolas',
          fontSize: isDisplay ? 14 : 13,
          height: 1.5,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
