import 'package:flutter/material.dart';

void main() {
  runApp(const MarkdownEditorApp());
}

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QLaw Markdown',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff256f7f),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff3d8f72),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  bool _showPreview = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialMarkdown);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _wrapSelection(String prefix, String suffix) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final selected = text.substring(start, end);
    final replacement = '$prefix$selected$suffix';

    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selected.length,
      ),
    );
    _editorFocusNode.requestFocus();
  }

  void _prefixCurrentLine(String prefix) {
    final selection = _controller.selection;
    final text = _controller.text;
    final cursor =
        selection.baseOffset < 0 ? text.length : selection.baseOffset;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;

    _controller.value = TextEditingValue(
      text: text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
    _editorFocusNode.requestFocus();
  }

  void _insertBlock(String value) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.start < 0 ? text.length : selection.start;
    final needsLeadingBreak = start > 0 && text[start - 1] != '\n';
    final insertion = needsLeadingBreak ? '\n$value' : value;

    _controller.value = TextEditingValue(
      text: text.replaceRange(
        start,
        selection.end < 0 ? start : selection.end,
        insertion,
      ),
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
    _editorFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final stats = DocumentStats.fromText(_controller.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QLaw Markdown'),
        actions: [
          Tooltip(
            message: _showPreview ? 'Hide preview' : 'Show preview',
            child: IconButton(
              icon: Icon(
                _showPreview ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _showPreview = !_showPreview),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          EditorToolbar(
            onBold: () => _wrapSelection('**', '**'),
            onItalic: () => _wrapSelection('*', '*'),
            onCode: () => _wrapSelection('`', '`'),
            onLink: () => _wrapSelection('[', '](https://example.com)'),
            onHeading: () => _prefixCurrentLine('## '),
            onQuote: () => _prefixCurrentLine('> '),
            onList: () => _prefixCurrentLine('- '),
            onCodeBlock: () => _insertBlock('```\ncode\n```\n'),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final editor = MarkdownTextEditor(
                  controller: _controller,
                  focusNode: _editorFocusNode,
                );
                final preview = MarkdownPreview(data: _controller.text);

                if (compact || !_showPreview) {
                  return _showPreview
                      ? PageView(children: [editor, preview])
                      : editor;
                }

                return Row(
                  children: [
                    Expanded(child: editor),
                    const VerticalDivider(width: 1),
                    Expanded(child: preview),
                  ],
                );
              },
            ),
          ),
          StatusBar(stats: stats, previewEnabled: _showPreview),
        ],
      ),
    );
  }
}

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.onBold,
    required this.onItalic,
    required this.onCode,
    required this.onLink,
    required this.onHeading,
    required this.onQuote,
    required this.onList,
    required this.onCodeBlock,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCode;
  final VoidCallback onLink;
  final VoidCallback onHeading;
  final VoidCallback onQuote;
  final VoidCallback onList;
  final VoidCallback onCodeBlock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _ToolButton(
              icon: Icons.title,
              label: 'Heading',
              onPressed: onHeading,
            ),
            _ToolButton(
              icon: Icons.format_bold,
              label: 'Bold',
              onPressed: onBold,
            ),
            _ToolButton(
              icon: Icons.format_italic,
              label: 'Italic',
              onPressed: onItalic,
            ),
            _ToolButton(
              icon: Icons.code,
              label: 'Inline code',
              onPressed: onCode,
            ),
            _ToolButton(icon: Icons.link, label: 'Link', onPressed: onLink),
            _ToolButton(
              icon: Icons.format_quote,
              label: 'Quote',
              onPressed: onQuote,
            ),
            _ToolButton(
              icon: Icons.format_list_bulleted,
              label: 'List',
              onPressed: onList,
            ),
            _ToolButton(
              icon: Icons.data_object,
              label: 'Code block',
              onPressed: onCodeBlock,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: label,
        child: IconButton.filledTonal(icon: Icon(icon), onPressed: onPressed),
      ),
    );
  }
}

class MarkdownTextEditor extends StatelessWidget {
  const MarkdownTextEditor({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(18),
        hintText: 'Write Markdown...',
      ),
      style: const TextStyle(
        fontFamily: 'Consolas',
        fontSize: 15,
        height: 1.45,
      ),
    );
  }
}

class MarkdownPreview extends StatelessWidget {
  const MarkdownPreview({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(data);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(22),
        itemCount: blocks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => blocks[index].build(context),
      ),
    );
  }

  List<_MarkdownBlock> _parseBlocks(String text) {
    final lines = text.split('\n');
    final blocks = <_MarkdownBlock>[];
    final paragraph = <String>[];
    final code = <String>[];
    var inCode = false;

    void flushParagraph() {
      if (paragraph.isNotEmpty) {
        blocks.add(_ParagraphBlock(paragraph.join(' ')));
        paragraph.clear();
      }
    }

    for (final line in lines) {
      final trimmed = line.trimRight();
      if (trimmed.startsWith('```')) {
        if (inCode) {
          blocks.add(_CodeBlock(code.join('\n')));
          code.clear();
        } else {
          flushParagraph();
        }
        inCode = !inCode;
        continue;
      }

      if (inCode) {
        code.add(line);
        continue;
      }

      if (trimmed.trim().isEmpty) {
        flushParagraph();
      } else if (trimmed.startsWith('#')) {
        flushParagraph();
        final level = trimmed.indexOf(RegExp(r'[^#]'));
        blocks.add(
          _HeadingBlock(trimmed.substring(level).trim(), level.clamp(1, 6)),
        );
      } else if (trimmed == '---' || trimmed == '***') {
        flushParagraph();
        blocks.add(const _DividerBlock());
      } else if (trimmed.startsWith('> ')) {
        flushParagraph();
        blocks.add(_QuoteBlock(trimmed.substring(2)));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushParagraph();
        blocks.add(_ListItemBlock(trimmed.substring(2)));
      } else {
        paragraph.add(trimmed);
      }
    }

    flushParagraph();
    if (code.isNotEmpty) {
      blocks.add(_CodeBlock(code.join('\n')));
    }
    return blocks.isEmpty
        ? [const _ParagraphBlock('Preview will appear here.')]
        : blocks;
  }
}

abstract class _MarkdownBlock {
  const _MarkdownBlock();

  Widget build(BuildContext context);
}

class _HeadingBlock extends _MarkdownBlock {
  const _HeadingBlock(this.text, this.level);

  final String text;
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final style = switch (level) {
      1 => theme.headlineMedium,
      2 => theme.titleLarge,
      3 => theme.titleMedium,
      _ => theme.titleSmall,
    };
    return Text(text, style: style?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _ParagraphBlock extends _MarkdownBlock {
  const _ParagraphBlock(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
    );
  }
}

class _QuoteBlock extends _MarkdownBlock {
  const _QuoteBlock(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _ListItemBlock extends _MarkdownBlock {
  const _ListItemBlock(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 20, child: Text('•')),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _CodeBlock extends _MarkdownBlock {
  const _CodeBlock(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}

class _DividerBlock extends _MarkdownBlock {
  const _DividerBlock();

  @override
  Widget build(BuildContext context) => const Divider(height: 20);
}

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.stats,
    required this.previewEnabled,
  });

  final DocumentStats stats;
  final bool previewEnabled;

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
              Text(previewEnabled ? 'Edit + preview' : 'Edit only'),
            ],
          ),
        ),
      ),
    );
  }
}

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

const _initialMarkdown = '''# QLaw Markdown

Start writing on the left. The preview updates as you type.

## MVP checklist

- Markdown editing
- Live preview
- Formatting toolbar
- Responsive desktop and web layout

> Next milestone: add file open/save and persistent local documents.

```
final status = 'prototype ready';
```
''';
