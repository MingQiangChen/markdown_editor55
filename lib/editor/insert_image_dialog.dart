import 'package:flutter/material.dart';

/// Dialog for inserting an image into the markdown editor.
class InsertImageDialog extends StatelessWidget {
  const InsertImageDialog({
    super.key,
    required this.onPickFromFile,
    required this.onInsertFromUrl,
  });

  final VoidCallback onPickFromFile;
  final void Function(String url, String altText) onInsertFromUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('插入图片'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonalIcon(
              icon: const Icon(Icons.folder_open),
              label: const Text('从文件选择'),
              onPressed: () {
                Navigator.of(context).pop();
                onPickFromFile();
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('或输入图片链接', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            _UrlInsertField(
              onInsert: (url, alt) {
                Navigator.of(context).pop();
                onInsertFromUrl(url, alt);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UrlInsertField extends StatefulWidget {
  const _UrlInsertField({required this.onInsert});
  final void Function(String url, String altText) onInsert;

  @override
  State<_UrlInsertField> createState() => _UrlInsertFieldState();
}

class _UrlInsertFieldState extends State<_UrlInsertField> {
  final _urlController = TextEditingController();
  final _altController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _altController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: '图片 URL',
            hintText: 'https://example.com/image.png',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _altController,
          decoration: const InputDecoration(
            labelText: '替代文本（可选）',
            hintText: '图片描述',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty) {
                widget.onInsert(url, _altController.text.trim());
              }
            },
            child: const Text('插入'),
          ),
        ),
      ],
    );
  }
}