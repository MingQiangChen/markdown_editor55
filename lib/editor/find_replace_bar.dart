import 'dart:async';
import 'package:flutter/material.dart';

/// A find and replace bar that overlays the editor.
///
/// For large documents, search is debounced and results are capped to avoid
/// blocking the UI during rapid typing.
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
  Timer? _searchTimer;

  /// Maximum number of match positions to track for large documents.
  static const int _maxMatchResults = 1000;
  /// Debounce delay for search input.
  static const Duration _searchDebounce = Duration(milliseconds: 200);
  /// Text length above which we use longer debounce.
  static const int _largeTextThreshold = 100000;
  static const Duration _largeTextDebounce = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _findController.dispose();
    _replaceController.dispose();
    _findFocusNode.dispose();
    super.dispose();
  }

  void _performFind() {
    _searchTimer?.cancel();

    final query = _findController.text;
    if (query.isEmpty) {
      setState(() {
        _matchIndices = [];
        _currentMatchIndex = -1;
      });
      return;
    }

    final isLargeText = widget.controller.text.length > _largeTextThreshold;
    final delay = isLargeText ? _largeTextDebounce : _searchDebounce;

    _searchTimer = Timer(delay, () {
      _executeSearch();
    });
  }

  void _executeSearch() {
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
    while (startIndex < searchText.length) {
      final index = searchText.indexOf(searchQuery, startIndex);
      if (index == -1) break;
      indices.add(index);
      if (indices.length >= _maxMatchResults) break;
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
      _currentMatchIndex =
          (_currentMatchIndex - 1 + _matchIndices.length) %
          _matchIndices.length;
    });
    _scrollToCurrentMatch();
  }

  void _replaceCurrent() {
    if (_currentMatchIndex < 0 || _matchIndices.isEmpty) return;

    final matchPos = _matchIndices[_currentMatchIndex];
    final query = _findController.text;
    final replacement = _replaceController.text;
    final text = widget.controller.text;

    widget.controller.text =
        text.substring(0, matchPos) +
        replacement +
        text.substring(matchPos + query.length);

    final previousIndex = _currentMatchIndex;
    _executeSearch();

    if (_matchIndices.isNotEmpty) {
      setState(() {
        _currentMatchIndex =
            previousIndex < _matchIndices.length ? previousIndex : 0;
      });
      _scrollToCurrentMatch();
    }
  }

  void _replaceAll() {
    final query = _findController.text;
    if (query.isEmpty) return;

    final text = widget.controller.text;
    if (_caseSensitive) {
      widget.controller.text = text.replaceAll(query, _replaceController.text);
    } else {
      final regex = RegExp(RegExp.escape(query), caseSensitive: false);
      widget.controller.text = text.replaceAll(regex, _replaceController.text);
    }

    _executeSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final matchLabel = _matchIndices.length >= _maxMatchResults
        ? '$_maxMatchResults+'
        : '$_matchIndices.length';

    return Material(
      elevation: 2,
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _findController,
                    focusNode: _findFocusNode,
                    decoration: InputDecoration(
                      hintText: '查找...',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixText:
                          _matchIndices.isEmpty &&
                                  _findController.text.isNotEmpty
                              ? '无结果'
                              : _matchIndices.isNotEmpty
                              ? '$matchLabel 个匹配'
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
                  message: '区分大小写',
                  child: IconButton(
                    icon: Icon(
                      Icons.text_fields,
                      size: 18,
                      color:
                          _caseSensitive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() => _caseSensitive = !_caseSensitive);
                      _executeSearch();
                    },
                  ),
                ),
                Tooltip(
                  message: '上一个',
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                    onPressed: _findPrevious,
                  ),
                ),
                Tooltip(
                  message: '下一个',
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    onPressed: _findNext,
                  ),
                ),
                Tooltip(
                  message: _showReplace ? '隐藏替换' : '显示替换',
                  child: IconButton(
                    icon: Icon(
                      _showReplace ? Icons.unfold_less : Icons.expand_more,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() => _showReplace = !_showReplace);
                    },
                  ),
                ),
                Tooltip(
                  message: '关闭',
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
            if (_showReplace)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replaceController,
                        decoration: const InputDecoration(
                          hintText: '替换为...',
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
                      message: '替换',
                      child: IconButton(
                        icon: const Icon(Icons.find_replace, size: 18),
                        onPressed: _replaceCurrent,
                      ),
                    ),
                    Tooltip(
                      message: '全部替换',
                      child: IconButton(
                        icon: const Icon(
                          Icons.change_circle_outlined,
                          size: 18,
                        ),
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
