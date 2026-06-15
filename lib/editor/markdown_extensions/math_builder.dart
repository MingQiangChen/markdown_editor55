import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

/// Builder for math elements - renders LaTeX formulas using flutter_math_fork
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

    // Try to render with flutter_math_fork
    try {
      final mathWidget = Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: isDisplay ? 18 : 16,
          color: theme.colorScheme.onSurface,
        ),
        onError: (error) {
          // Fallback to displaying raw LaTeX if parsing fails
          return _buildFallback(latex, isDisplay, theme);
        },
      );

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: isDisplay ? 16.0 : 2.0,
          horizontal: isDisplay ? 8.0 : 0.0,
        ),
        padding: EdgeInsets.all(isDisplay ? 12.0 : 4.0),
        decoration: isDisplay
            ? BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              )
            : null,
        child: isDisplay
            ? Center(child: mathWidget)
            : mathWidget,
      );
    } catch (e) {
      // Fallback to displaying raw LaTeX
      return _buildFallback(latex, isDisplay, theme);
    }
  }

  Widget _buildFallback(String latex, bool isDisplay, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isDisplay ? 16.0 : 2.0,
        horizontal: isDisplay ? 8.0 : 0.0,
      ),
      padding: EdgeInsets.all(isDisplay ? 12.0 : 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: isDisplay
            ? Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDisplay)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.functions,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          Flexible(
            child: SelectableText(
              latex,
              style: TextStyle(
                fontFamily: 'Consolas',
                fontSize: isDisplay ? 14 : 13,
                height: 1.5,
                color: theme.colorScheme.onSurface,
                fontStyle: isDisplay ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}