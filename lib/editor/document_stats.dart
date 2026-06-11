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

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.stats,
    required this.viewMode,
    required this.wordWrap,
    required this.saveStatus,
    this.fileName,
  });

  final DocumentStats stats;
  final ViewMode viewMode;
  final bool wordWrap;
  final String saveStatus;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final viewModeText = switch (viewMode) {
      ViewMode.editorOnly => 'Edit only',
      ViewMode.split => 'Edit + preview',
      ViewMode.previewOnly => 'Preview only',
    };

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (fileName != null) ...[
                Text(
                  fileName!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 12),
                Text('·'),
                const SizedBox(width: 12),
              ],
              Text('${stats.words} words'),
              const SizedBox(width: 16),
              Text('${stats.characters} characters'),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        saveStatus,
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
                        wordWrap ? 'Wrap' : 'No wrap',
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
