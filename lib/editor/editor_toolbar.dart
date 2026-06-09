import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.onBold,
    required this.onItalic,
    required this.onCode,
    required this.onLink,
    required this.onHeading,
    required this.onQuote,
    required this.onList,
    required this.onCodeBlock,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCode;
  final VoidCallback onLink;
  final VoidCallback onHeading;
  final VoidCallback onQuote;
  final VoidCallback onList;
  final VoidCallback onCodeBlock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _ToolButton(
              icon: Icons.title,
              label: 'Heading',
              onPressed: onHeading,
            ),
            _ToolButton(
              icon: Icons.format_bold,
              label: 'Bold',
              onPressed: onBold,
            ),
            _ToolButton(
              icon: Icons.format_italic,
              label: 'Italic',
              onPressed: onItalic,
            ),
            _ToolButton(
              icon: Icons.code,
              label: 'Inline code',
              onPressed: onCode,
            ),
            _ToolButton(icon: Icons.link, label: 'Link', onPressed: onLink),
            _ToolButton(
              icon: Icons.format_quote,
              label: 'Quote',
              onPressed: onQuote,
            ),
            _ToolButton(
              icon: Icons.format_list_bulleted,
              label: 'List',
              onPressed: onList,
            ),
            _ToolButton(
              icon: Icons.data_object,
              label: 'Code block',
              onPressed: onCodeBlock,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: label,
        child: IconButton.filledTonal(icon: Icon(icon), onPressed: onPressed),
      ),
    );
  }
}
