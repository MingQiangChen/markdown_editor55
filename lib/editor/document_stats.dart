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
  });

  final DocumentStats stats;
  final bool previewEnabled;
  final String saveStatus;

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
              Text('${stats.words} words'),
              const SizedBox(width: 16),
              Text('${stats.characters} characters'),
              const Spacer(),
              Text(saveStatus),
              const SizedBox(width: 16),
              Text(previewEnabled ? 'Edit + preview' : 'Edit only'),
            ],
          ),
        ),
      ),
    );
  }
}
