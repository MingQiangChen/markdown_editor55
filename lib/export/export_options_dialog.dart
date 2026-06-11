import 'package:flutter/material.dart';

import '../export/css_templates.dart';

/// Export options for HTML/PDF export.
class ExportOptions {
  final CssTemplate template;
  final bool enableKatex;
  final bool enableMermaid;

  const ExportOptions({
    required this.template,
    this.enableKatex = false,
    this.enableMermaid = false,
  });
}

/// Shows a dialog for export options.
Future<ExportOptions?> showExportOptionsDialog(
  BuildContext context, {
  ExportOptions initialOptions = const ExportOptions(
    template: CssTemplates.defaultTemplate,
  ),
}) async {
  return showDialog<ExportOptions>(
    context: context,
    builder: (context) => _ExportOptionsDialog(initialOptions: initialOptions),
  );
}

class _ExportOptionsDialog extends StatefulWidget {
  const _ExportOptionsDialog({required this.initialOptions});

  final ExportOptions initialOptions;

  @override
  State<_ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<_ExportOptionsDialog> {
  late CssTemplate _selectedTemplate;
  late bool _enableKatex;
  late bool _enableMermaid;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = widget.initialOptions.template;
    _enableKatex = widget.initialOptions.enableKatex;
    _enableMermaid = widget.initialOptions.enableMermaid;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Options'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CSS Theme',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...CssTemplates.all.map(
              (template) => RadioListTile<CssTemplate>(
                title: Text(template.name),
                value: template,
                groupValue: _selectedTemplate,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTemplate = value);
                  }
                },
              ),
            ),
            const Divider(height: 24),
            const Text(
              'Extensions',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Math formulas (KaTeX)'),
              subtitle: const Text('\$\$ and ( ) delimiters'),
              value: _enableKatex,
              onChanged: (value) {
                setState(() => _enableKatex = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Diagrams (Mermaid)'),
              subtitle: const Text('`mermaid code blocks'),
              value: _enableMermaid,
              onChanged: (value) {
                setState(() => _enableMermaid = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              ExportOptions(
                template: _selectedTemplate,
                enableKatex: _enableKatex,
                enableMermaid: _enableMermaid,
              ),
            );
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
