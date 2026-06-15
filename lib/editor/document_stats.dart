import 'package:flutter/material.dart';

enum ViewMode { editorOnly, split, previewOnly }

class DocumentStats {
  const DocumentStats({required this.words, required this.characters});

  final int words;
  final int characters;

  factory DocumentStats.fromText(String text) {
    if (text.trim().isEmpty) {
      return DocumentStats(words: 0, characters: text.length);
    }
    var wordCount = 0;
    var inWord = false;
    for (var i = 0; i < text.length; i++) {
      final isWhitespace = _isWhitespace(text.codeUnitAt(i));
      if (isWhitespace) {
        if (inWord) {
          wordCount++;
          inWord = false;
        }
      } else {
        inWord = true;
      }
    }
    if (inWord) wordCount++;
    return DocumentStats(words: wordCount, characters: text.length);
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 0x20 || codeUnit == 0x09 ||
           codeUnit == 0x0A || codeUnit == 0x0D;
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
      if (_line != 1 || _column != 1) {
        setState(() {
          _line = 1;
          _column = 1;
        });
      }
      return;
    }

    final cursorPos = selection.start;
    var line = 1;
    var lastNewline = -1;
    for (var i = 0; i < cursorPos; i++) {
      if (text.codeUnitAt(i) == 0x0A) {
        line++;
        lastNewline = i;
      }
    }
    final column = cursorPos - lastNewline;

    if (_line != line || _column != column) {
      setState(() {
        _line = line;
        _column = column;
      });
    }
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
              Text(' \u884c,  \u5217'),
              const SizedBox(width: 16),
              Text(' \u8bcd'),
              const SizedBox(width: 16),
              Text(' \u5b57\u7b26'),
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