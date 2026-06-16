import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  final katexHead = enableKatex
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

  final mermaidHead = enableMermaid
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

/// Converts Markdown to PDF using native PDF generation.
Future<Uint8List> markdownToPdf(
  String markdown, {
  String? title,
  CssTemplate? template,
  bool enableKatex = false,
  bool enableMermaid = false,
}) async {
  final doc = pw.Document();
  
  // Parse markdown to extract content
  final lines = markdown.split('\n');
  final widgets = <pw.Widget>[];
  
  // Add title if provided
  if (title != null && title.isNotEmpty) {
    widgets.add(
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
    widgets.add(pw.SizedBox(height: 16));
  }
  
  // Process markdown lines
  for (final line in lines) {
    final trimmed = line.trim();
    
    if (trimmed.isEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      continue;
    }
    
    // Headers
    if (trimmed.startsWith('### ')) {
      widgets.add(
        pw.Text(
          trimmed.substring(4),
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
    } else if (trimmed.startsWith('## ')) {
      widgets.add(
        pw.Text(
          trimmed.substring(3),
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
    } else if (trimmed.startsWith('# ')) {
      widgets.add(
        pw.Text(
          trimmed.substring(2),
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
    }
    // List items
    else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
            pw.Expanded(
              child: pw.Text(
                trimmed.substring(2),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
      widgets.add(pw.SizedBox(height: 2));
    }
    // Blockquotes
    else if (trimmed.startsWith('> ')) {
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(color: PdfColors.grey, width: 3),
            ),
          ),
          child: pw.Text(
            trimmed.substring(2),
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
    }
    // Code blocks
    else if (trimmed.startsWith('```')) {
      // Skip code fence markers
      continue;
    }
    // Regular paragraphs
    else {
      // Handle inline formatting
      var processedLine = trimmed
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('`', '');
      
      widgets.add(
        pw.Text(
          processedLine,
          style: const pw.TextStyle(fontSize: 12),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
    }
  }
  
  // Add content to PDF
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: widgets,
        );
      },
    ),
  );
  
  return doc.save();
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
  await Printing.sharePdf(bytes: bytes, filename: '$baseName.pdf');
}

String _escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}