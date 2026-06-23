import 'dart:async';
import 'package:flutter/material.dart';

class OutlineItem {
  final String title;
  final int level;
  final int lineIndex;

  const OutlineItem({
    required this.title,
    required this.level,
    required this.lineIndex,
  });
}

final _headingRegex = RegExp(r'^(#{1,6})\s+(.+)$');

/// A document outline panel that parses headings from the document text.
///
/// For large documents, outline parsing is debounced to avoid blocking the
/// UI during rapid typing.
class DocumentOutline extends StatefulWidget {
  const DocumentOutline({
    super.key,
    required this.text,
    required this.onItemTap,
  });

  final String text;
  final ValueChanged<OutlineItem> onItemTap;

  @override
  State<DocumentOutline> createState() => _DocumentOutlineState();
}

class _DocumentOutlineState extends State<DocumentOutline> {
  List<OutlineItem>? _cachedOutline;
  String? _cachedText;
  Timer? _debounceTimer;

  static const Duration _normalDebounce = Duration(milliseconds: 300);
  static const Duration _largeDocDebounce = Duration(milliseconds: 800);
  static const int _largeDocThreshold = 50000;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(DocumentOutline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _scheduleParse();
    }
  }

  void _scheduleParse() {
    _debounceTimer?.cancel();
    final isLargeDoc = widget.text.length > _largeDocThreshold;
    final delay = isLargeDoc ? _largeDocDebounce : _normalDebounce;
    _debounceTimer = Timer(delay, () {
      if (mounted) {
        setState(() {
          _cachedText = null; // Force re-parse
        });
      }
    });
  }

  List<OutlineItem> _parseOutline() {
    if (_cachedText == widget.text && _cachedOutline != null) {
      return _cachedOutline!;
    }
    final items = <OutlineItem>[];
    final lines = widget.text.split('\n');
    var inCodeBlock = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) continue;

      final match = _headingRegex.firstMatch(line);
      if (match != null) {
        final level = match.group(1)!.length;
        final title = match.group(2)!.trim();
        items.add(OutlineItem(title: title, level: level, lineIndex: i));
      }
    }

    _cachedOutline = items;
    _cachedText = widget.text;
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final outline = _parseOutline();
    final theme = Theme.of(context);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '文档大纲',
              style: theme.textTheme.titleSmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child:
                outline.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '暂无标题',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: outline.length,
                      itemBuilder: (context, index) {
                        final item = outline[index];
                        return InkWell(
                          onTap: () => widget.onItemTap(item),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 12.0 + (item.level - 1) * 12.0,
                              right: 12,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Text(
                              item.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight:
                                    item.level == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    item.level <= 2
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
