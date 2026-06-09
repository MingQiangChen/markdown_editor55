import 'package:flutter/material.dart';

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
        const SizedBox(width: 20, child: Text('-')),
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
