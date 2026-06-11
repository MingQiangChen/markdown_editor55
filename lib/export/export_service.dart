import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'css_templates.dart';

/// Converts Markdowntext to a complete HTML page.
String markdownToHtmlPage(
  String markdown, {
  String? title,
  CssTemplate? template,
  bool enableKatex = false,
  bool enableMermaid = false,
}) {
  final css = template ?? CssTemplates.defaultTemplate;
  final body = md.markdownToHtml(
    markdown,
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );

  final katexHead =
      enableKatex
          ? '''
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"
    onload="renderMathInElement(document.body, {
      delimiters: [
        {left: '\$\$', right: '\$\$', display: true},
        {left: '\\(', right: '\\)', display: false},
        {left: '\\[', right: '\\]', display: true}
      ]
    });"></script>'''
          : '';

  final mermaidHead =
      enableMermaid
          ? '''
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      mermaid.initialize({ startOnLoad: true, theme: 'default' });
      document.querySelectorAll('pre code.language-mermaid').forEach(function(el) {
        var container = document.createElement('div');
        container.className = 'mermaid';
        container.textContent = el.textContent;
        el.parentElement.replaceWith(container);
      });
    });
  </script>'''
          : '';

  final escapedTitle = _escapeHtml(title ?? 'Markdown Export');

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$escapedTitle</title>
  <style>
${css.css}  </style>
$katexHead
$mermaidHead
</head>
<body>
$body
</body>
</html>''';
}

/// Converts Markdowntext to PDF bytes via HTML rendering.
Future<Uint8List> markdownToPdf(
  String markdown, {
  String? title,
  CssTemplate? template,
  bool enableKatex = false,
  bool enableMermaid = false,
}) async {
  final html = markdownToHtmlPage(
    markdown,
    title: title,
    template: template,
    enableKatex: enableKatex,
    enableMermaid: enableMermaid,
  );

  // ignore: deprecated_member_use
  return await Printing.convertHtml(format: PdfPageFormat.a4, html: html);
}

/// Converts Markdown to PDF and opens the platform share/save dialog.
Future<void> shareAsPdf(
  String markdown, {
  String? filename,
  CssTemplate? template,
  bool enableKatex = false,
  bool enableMermaid = false,
}) async {
  final bytes = await markdownToPdf(
    markdown,
    template: template,
    enableKatex: enableKatex,
    enableMermaid: enableMermaid,
  );
  final name = filename ?? 'document';
  final baseName =
      name.endsWith('.md') ? name.substring(0, name.length - 3) : name;
  await Printing.sharePdf(bytes: bytes, filename: baseName);
}

String _escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
