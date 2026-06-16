import 'package:flutter/material.dart';
import 'spell_checker.dart';

/// Widget that displays text with spell check highlighting
class SpellCheckOverlay extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final bool enabled;
  final void Function(int start, int end, String replacement)? onReplace;

  const SpellCheckOverlay({
    super.key,
    required this.text,
    this.textStyle,
    this.enabled = true,
    this.onReplace,
  });

  @override
  State<SpellCheckOverlay> createState() => _SpellCheckOverlayState();
}

class _SpellCheckOverlayState extends State<SpellCheckOverlay> {
  List<_MisspelledWord> _misspelledWords = [];

  @override
  void initState() {
    super.initState();
    _checkSpelling();
  }

  @override
  void didUpdateWidget(SpellCheckOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.enabled != widget.enabled) {
      _checkSpelling();
    }
  }

  void _checkSpelling() {
    if (!widget.enabled) {
      setState(() => _misspelledWords = []);
      return;
    }

    final words = <_MisspelledWord>[];
    final wordPattern = RegExp(r'\b[a-zA-Z]+\b');
    
    for (final match in wordPattern.allMatches(widget.text)) {
      final word = match.group(0)!;
      if (!SpellChecker.isCorrect(word)) {
        words.add(_MisspelledWord(
          word: word,
          start: match.start,
          end: match.end,
        ));
      }
    }

    setState(() => _misspelledWords = words);
  }

  void _replaceWord(_MisspelledWord misspelled, String replacement) {
    widget.onReplace?.call(misspelled.start, misspelled.end, replacement);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _misspelledWords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '拼写检查: ${_misspelledWords.length} 个问题',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _misspelledWords.length > 10 ? 10 : _misspelledWords.length,
              itemBuilder: (context, index) {
                final misspelled = _misspelledWords[index];
                final suggestions = SpellChecker.getSuggestions(misspelled.word);
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      misspelled.word,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                      ),
                    ),
                    subtitle: suggestions.isEmpty
                        ? null
                        : Wrap(
                            spacing: 4,
                            children: suggestions.map((s) {
                              return ActionChip(
                                label: Text(s),
                                onPressed: () => _replaceWord(misspelled, s),
                              );
                            }).toList(),
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

class _MisspelledWord {
  final String word;
  final int start;
  final int end;

  _MisspelledWord({
    required this.word,
    required this.start,
    required this.end,
  });
}