import 'package:flutter/material.dart';

enum ViewMode { editorOnly, split, previewOnly }

class DocumentStats {
  const DocumentStats({required this.words, required this.characters});

  final int words;
  final int characters;

  factory DocumentStats.fromText(String text) {
    final words =
        text.trim().isEmpty
            ? 0
            : text
                .trim()
                .split(RegExp(r'\s+'))
                .where((word) => word.isNotEmpty)
                .length;
    return DocumentStats(words: words, characters: text.length);
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({
    super.key,
    required this.stats,
    required this.viewMode,
    required this.wordWrap,
    required this.saveStatus,
    required this.controller,
    this.fileName,
  });

  final DocumentStats stats;
  final ViewMode viewMode;
  final bool wordWrap;
  final String saveStatus;
  final String? fileName;
  final TextEditingController controller;

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  int _line = 1;
  int _column = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateCursorPosition);
    _updateCursorPosition();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCursorPosition);
    super.dispose();
  }

  void _updateCursorPosition() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    if (!selection.isValid || selection.start < 0) {
      setState(() {
        _line = 1;
        _column = 1;
      });
      return;
    }

    final cursorPos = selection.start;
    final textBefore = text.substring(0, cursorPos);
    final lines = textBefore.split('\n');
    
    setState(() {
      _line = lines.length;
      _column = lines.last.length + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModeText = switch (widget.viewMode) {
      ViewMode.editorOnly => '仅编辑',
      ViewMode.split => '编辑 + 预览',
      ViewMode.previewOnly => '仅预览',
    };

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.fileName != null) ...[
                Text(
                  widget.fileName!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 12),
                Text('·'),
                const SizedBox(width: 12),
              ],
              Text('行 , 列 '),
              const SizedBox(width: 16),
              Text('\ 词'),
              const SizedBox(width: 16),
              Text('\ 字符'),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.saveStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        viewModeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('·'),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.wordWrap ? '自动换行' : '不换行',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
