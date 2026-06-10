import 'package:flutter/material.dart';

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
    required this.previewEnabled,
    required this.saveStatus,
    this.fileName,
  });

  final DocumentStats stats;
  final bool previewEnabled;
  final String saveStatus;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  saveStatus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 16),
              Text(previewEnabled ? 'Edit + preview' : 'Edit only'),
            ],
          ),
        ),
      ),
    );
  }
}
