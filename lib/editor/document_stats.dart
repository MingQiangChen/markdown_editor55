import 'dart:async';
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
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCursorChange);
    _updateCursorPosition();
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    widget.controller.removeListener(_onCursorChange);
    super.dispose();
  }

  void _onCursorChange() {
    // Debounce cursor position updates to avoid expensive line counting
    // on every cursor movement during rapid typing or selection dragging.
    _cursorTimer?.cancel();
    _cursorTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        _updateCursorPosition();
      }
    });
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
    
    // Optimized line counting: find the last newline before cursor position
    // and count newlines in the prefix.
    var line = 1;
    var lastNewline = -1;
    
    // Use a chunked approach for better performance on large texts.
    // Scan backwards from cursor to find the start of the current line.
    var searchPos = cursorPos - 1;
    while (searchPos >= 0) {
      if (text.codeUnitAt(searchPos) == 0x0A) {
        lastNewline = searchPos;
        break;
      }
      searchPos--;
    }
    
    // Count lines from start to the last newline.
    for (var i = 0; i < lastNewline; i++) {
      if (text.codeUnitAt(i) == 0x0A) {
        line++;
      }
    }
    if (lastNewline >= 0) line++;
    
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
              Text('$_line 行, $_column 列'),
              const SizedBox(width: 16),
              Text('${widget.stats.words} 词'),
              const SizedBox(width: 16),
              Text('${widget.stats.characters} 字符'),
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
