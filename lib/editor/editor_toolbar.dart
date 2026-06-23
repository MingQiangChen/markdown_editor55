import '../utils/responsive_layout.dart';
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
    required this.onInlineMath,
    required this.onBlockMath,
    required this.onMermaid,
    required this.onInsertImage,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCode;
  final VoidCallback onLink;
  final VoidCallback onHeading;
  final VoidCallback onQuote;
  final VoidCallback onList;
  final VoidCallback onCodeBlock;
  final VoidCallback onInlineMath;
  final VoidCallback onBlockMath;
  final VoidCallback onMermaid;
  final VoidCallback onInsertImage;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.fromContext(context);
    final iconSize = layout.isMobile ? 24.0 : 20.0;
    final buttonSize = layout.isMobile ? 48.0 : 40.0;
    
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _ToolButton(icon: Icons.title, label: '标题', onPressed: onHeading, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.format_bold, label: '粗体', onPressed: onBold, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.format_italic, label: '斜体', onPressed: onItalic, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.code, label: '行内代码', onPressed: onCode, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.link, label: '链接', onPressed: onLink, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.format_quote, label: '引用', onPressed: onQuote, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.format_list_bulleted, label: '列表', onPressed: onList, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.data_object, label: '代码块', onPressed: onCodeBlock, iconSize: iconSize, buttonSize: buttonSize),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: VerticalDivider(width: 1),
            ),
            _ToolButton(icon: Icons.functions, label: '行内公式', onPressed: onInlineMath, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.calculate, label: '公式块', onPressed: onBlockMath, iconSize: iconSize, buttonSize: buttonSize),
            _ToolButton(icon: Icons.account_tree, label: 'Mermaid 图表', onPressed: onMermaid, iconSize: iconSize, buttonSize: buttonSize),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: VerticalDivider(width: 1),
            ),
            _ToolButton(icon: Icons.image, label: '插入图片', onPressed: onInsertImage, iconSize: iconSize, buttonSize: buttonSize),
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
    this.iconSize = 20.0,
    this.buttonSize = 40.0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double iconSize;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: IconButton.filledTonal(
            icon: Icon(icon, size: iconSize),
            onPressed: onPressed,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
