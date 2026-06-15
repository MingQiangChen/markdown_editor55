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
      ViewMode.editorOnly => '\u4ec5\u7f16\u8f91',
      ViewMode.split => '\u7f16\u8f91 + \u9884\u89c8',
      ViewMode.previewOnly => '\u4ec5\u9884\u89c8',
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
                Text('\u00b7'),
                const SizedBox(width: 12),
              ],
              Text('$_line \u884c, $_column \u5217'),
              const SizedBox(width: 16),
              Text('${widget.stats.words} \u8bcd'),
              const SizedBox(width: 16),
              Text('${widget.stats.characters} \u5b57\u7b26'),
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
                    const Text('\u00b7'),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.wordWrap ? '\u81ea\u52a8\u6362\u884c' : '\u4e0d\u6362\u884c',
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