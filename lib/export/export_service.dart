import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'css_templates.dart';

/// 加载中文字体
Future<pw.Font> _loadChineseFont() async {
  // 尝试从 assets 加载
  try {
    final data = await rootBundle.load('fonts/SimHei.ttf');
    return pw.Font.ttf(data);
  } catch (_) {}
  
  // 回退：从系统字体加载
  try {
    final file = File('C:\\Windows\\Fonts\\simhei.ttf');
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      return pw.Font.ttf(ByteData.sublistView(bytes));
    }
  } catch (_) {}
  
  // 最终回退使用默认字体
  return pw.Font.helvetica();
}

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

/// Converts Markdown to PDF using native PDF generation with Chinese font support.
Future<Uint8List> markdownToPdf(
  String markdown, {
  String? title,
  CssTemplate? template,
  bool enableKatex = false,
  bool enableMermaid = false,
}) async {
  final doc = pw.Document();

  // 加载中文字体
  final chineseFont = await _loadChineseFont();

  // 定义字体样式
  final normalStyle = pw.TextStyle(font: chineseFont, fontSize: 12);
  final boldStyle = pw.TextStyle(font: chineseFont, fontSize: 12, fontWeight: pw.FontWeight.bold);
  final codeStyle = pw.TextStyle(font: pw.Font.courier(), fontSize: 10);
  final h1Style = pw.TextStyle(font: chineseFont, fontSize: 20, fontWeight: pw.FontWeight.bold);
  final h2Style = pw.TextStyle(font: chineseFont, fontSize: 18, fontWeight: pw.FontWeight.bold);
  final h3Style = pw.TextStyle(font: chineseFont, fontSize: 16, fontWeight: pw.FontWeight.bold);
  final italicStyle = pw.TextStyle(font: chineseFont, fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700);
  final titleStyle = pw.TextStyle(font: chineseFont, fontSize: 24, fontWeight: pw.FontWeight.bold);

  // Parse markdown to extract content
  final lines = markdown.split('\n');
  final widgets = <pw.Widget>[];

  // Add title if provided
  if (title != null && title.isNotEmpty) {
    widgets.add(pw.Text(title, style: titleStyle));
    widgets.add(pw.SizedBox(height: 16));
  }

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      i++;
      continue;
    }

    // Headers
    if (trimmed.startsWith('### ')) {
      widgets.add(pw.Text(trimmed.substring(4), style: h3Style));
      widgets.add(pw.SizedBox(height: 4));
      i++;
    } else if (trimmed.startsWith('## ')) {
      widgets.add(pw.Text(trimmed.substring(3), style: h2Style));
      widgets.add(pw.SizedBox(height: 4));
      i++;
    } else if (trimmed.startsWith('# ')) {
      widgets.add(pw.Text(trimmed.substring(2), style: h1Style));
      widgets.add(pw.SizedBox(height: 4));
      i++;
    }
    // Code blocks
    else if (trimmed.startsWith('```')) {
      final codeLines = <String>[];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith('```')) {
        codeLines.add(lines[i]);
        i++;
      }
      i++; // skip closing ```
      if (codeLines.isNotEmpty) {
        widgets.add(
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            width: double.infinity,
            child: pw.Text(codeLines.join('\n'), style: codeStyle),
          ),
        );
        widgets.add(pw.SizedBox(height: 8));
      }
    }
    // Tables
    else if (trimmed.contains('|')) {
      final tableLines = <String>[];
      while (i < lines.length && lines[i].trim().contains('|')) {
        tableLines.add(lines[i].trim());
        i++;
      }
      final tableWidgets = _buildPdfTable(tableLines, normalStyle, boldStyle);
      widgets.addAll(tableWidgets);
      widgets.add(pw.SizedBox(height: 8));
    }
    // List items
    else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      final text = trimmed.substring(2);
      if (text.startsWith('[ ]') || text.startsWith('[x]')) {
        final checked = text.startsWith('[x]');
        final taskText = text.substring(4);
        widgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(checked ? '[x] ' : '[ ] ', style: normalStyle),
              pw.Expanded(child: pw.Text(taskText, style: normalStyle)),
            ],
          ),
        );
      } else {
        widgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('- ', style: normalStyle),
              pw.Expanded(child: pw.Text(text, style: normalStyle)),
            ],
          ),
        );
      }
      widgets.add(pw.SizedBox(height: 2));
      i++;
    }
    // Numbered list
    else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
      final match = RegExp(r'^(\d+\.)\s(.*)$').firstMatch(trimmed);
      if (match != null) {
        widgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${match.group(1)} ', style: normalStyle),
              pw.Expanded(child: pw.Text(match.group(2)!, style: normalStyle)),
            ],
          ),
        );
        widgets.add(pw.SizedBox(height: 2));
      }
      i++;
    }
    // Blockquotes
    else if (trimmed.startsWith('> ')) {
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: PdfColors.grey, width: 3)),
          ),
          child: pw.Text(trimmed.substring(2), style: italicStyle),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));
      i++;
    }
    // Horizontal rule
    else if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
      widgets.add(pw.Divider());
      widgets.add(pw.SizedBox(height: 8));
      i++;
    }
    // Regular paragraphs
    else {
      var processedLine = trimmed
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('`', '');

      widgets.add(pw.Text(processedLine, style: normalStyle));
      widgets.add(pw.SizedBox(height: 4));
      i++;
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

List<pw.Widget> _buildPdfTable(List<String> tableLines, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
  final widgets = <pw.Widget>[];
  if (tableLines.isEmpty) return widgets;

  final rows = <List<String>>[];
  for (final line in tableLines) {
    final cells = line
        .split('|')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    if (cells.isNotEmpty) {
      rows.add(cells);
    }
  }
  if (rows.isEmpty) return widgets;

  final colCount = rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);

  // Normalize all rows to the same column count
  for (final row in rows) {
    while (row.length < colCount) {
      row.add('');
    }
  }

  // Detect separator row (e.g. --- | ---)
  final dataRows = rows.where((r) {
    return !r.every((c) => RegExp(r'^:?-{3,}:?$').hasMatch(c));
  }).toList();

  if (dataRows.isEmpty) return widgets;

  final headerRow = dataRows.first;
  final bodyRows = dataRows.length > 1 ? dataRows.sublist(1) : <List<String>>[];

  widgets.add(
    pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: headerRow.map((c) =>
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(c, style: boldStyle),
            ),
          ).toList(),
        ),
        ...bodyRows.map((row) =>
          pw.TableRow(
            children: row.map((c) =>
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(c, style: normalStyle),
              ),
            ).toList(),
          ),
        ),
      ],
    ),
  );

  return widgets;
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