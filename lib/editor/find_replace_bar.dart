import 'package:flutter/material.dart';

/// A find and replace bar that overlays the editor.
class FindReplaceBar extends StatefulWidget {
  const FindReplaceBar({
    super.key,
    required this.controller,
    required this.onClose,
  });

  final TextEditingController controller;
  final VoidCallback onClose;

  @override
  State<FindReplaceBar> createState() => _FindReplaceBarState();
}

class _FindReplaceBarState extends State<FindReplaceBar> {
  final _findController = TextEditingController();
  final _replaceController = TextEditingController();
  final _findFocusNode = FocusNode();
  bool _showReplace = false;
  bool _caseSensitive = false;
  List<int> _matchIndices = [];
  int _currentMatchIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    _findFocusNode.dispose();
    super.dispose();
  }

  void _performFind() {
    final query = _findController.text;
    if (query.isEmpty) {
      setState(() {
        _matchIndices = [];
        _currentMatchIndex = -1;
      });
      return;
    }

    final text = widget.controller.text;
    final indices = <int>[];
    final searchText = _caseSensitive ? text : text.toLowerCase();
    final searchQuery = _caseSensitive ? query : query.toLowerCase();

    var startIndex = 0;
    while (true) {
      final index = searchText.indexOf(searchQuery, startIndex);
      if (index == -1) break;
      indices.add(index);
      startIndex = index + 1;
    }

    setState(() {
      _matchIndices = indices;
      _currentMatchIndex = indices.isEmpty ? -1 : 0;
    });

    _scrollToCurrentMatch();
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIndex < 0 || _matchIndices.isEmpty) return;

    final matchPos = _matchIndices[_currentMatchIndex];
    final text = widget.controller.text;

    // Count lines before the match to estimate scroll position.
    final textBefore = text.substring(0, matchPos);
    final lineNumber = '\n'.allMatches(textBefore).length;

    // Estimate the character height (approximate).
    const lineHeight = 21.8; // ~15px font * 1.45 line height
    final scrollOffset = lineNumber * lineHeight - 100;

    // We can't directly scroll the HighlightedMarkdownEditor from here,
    // so we'll just select the match in the text field.
    final query = _findController.text;
    widget.controller.selection = TextSelection(
      baseOffset: matchPos,
      extentOffset: matchPos + query.length,
    );
  }

  void _findNext() {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchIndices.length;
    });
    _scrollToCurrentMatch();
  }

  void _findPrevious() {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matchIndices.length) %
          _matchIndices.length;
    });
    _scrollToCurrentMatch();
  }

  void _replaceCurrent() {
    if (_currentMatchIndex < 0 || _matchIndices.isEmpty) return;

    final matchPos = _matchIndices[_currentMatchIndex];
    final query = _findController.text;
    final text = widget.controller.text;

    widget.controller.text =
        text.substring(0, matchPos) +
        _replaceController.text +
        text.substring(matchPos + query.length);

    _performFind();
  }

  void _replaceAll() {
    final query = _findController.text;
    if (query.isEmpty) return;

    final text = widget.controller.text;
    if (_caseSensitive) {
      widget.controller.text = text.replaceAll(query, _replaceController.text);
    } else {
      final regex = RegExp(RegExp.escape(query), caseSensitive: false);
      widget.controller.text =
          text.replaceAll(regex, _replaceController.text);
    }

    _performFind();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 2,
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Find row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _findController,
                    focusNode: _findFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Find...',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixText: _matchIndices.isEmpty &&
                              _findController.text.isNotEmpty
                          ? 'No results'
                          : _matchIndices.isNotEmpty
                              ? '/'
                              : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) => _performFind(),
                    onSubmitted: (_) => _findNext(),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Case sensitive',
                  child: IconButton(
                    icon: Icon(
                      Icons.text_fields,
                      size: 18,
                      color: _caseSensitive
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() => _caseSensitive = !_caseSensitive);
                      _performFind();
                    },
                  ),
                ),
                Tooltip(
                  message: 'Previous',
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                    onPressed: _findPrevious,
                  ),
                ),
                Tooltip(
                  message: 'Next',
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    onPressed: _findNext,
                  ),
                ),
                Tooltip(
                  message: _showReplace ? 'Hide replace' : 'Show replace',
                  child: IconButton(
                    icon: Icon(
                      _showReplace
                          ? Icons.unfold_less
                          : Icons.expand_more,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() => _showReplace = !_showReplace);
                    },
                  ),
                ),
                Tooltip(
                  message: 'Close',
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
            // Replace row
            if (_showReplace)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replaceController,
                        decoration: const InputDecoration(
                          hintText: 'Replace...',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Replace',
                      child: IconButton(
                        icon: const Icon(Icons.find_replace, size: 18),
                        onPressed: _replaceCurrent,
                      ),
                    ),
                    Tooltip(
                      message: 'Replace all',
                      child: IconButton(
                        icon:
                            const Icon(Icons.change_circle_outlined, size: 18),
                        onPressed: _replaceAll,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
