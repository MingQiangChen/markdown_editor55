import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Converts Markdown text to a complete HTML page.
String markdownToHtmlPage(String markdown, {String? title}) {
  final body = md.markdownToHtml(
    markdown,
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_escapeHtml(title ?? 'Markdown Export')}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 820px;
      margin: 0 auto;
      padding: 2.2em;
      line-height: 1.7;
      color: #1a1a1a;
      font-size: 15px;
    }
    h1, h2, h3, h4 { margin-top: 1.4em; }
    h1 { font-size: 1.8em; }
    h2 { font-size: 1.4em; }
    h3 { font-size: 1.15em; }
    code {
      background: #eee;
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
      font-size: 0.9em;
    }
    pre {
      background: #f4f4f4;
      padding: 1em 1.2em;
      border-radius: 6px;
      overflow-x: auto;
      line-height: 1.45;
    }
    pre code { background: none; padding: 0; }
    blockquote {
      border-left: 4px solid #256f7f;
      padding: 0.5em 1em;
      margin: 1em 0;
      background: #f8f9fa;
      color: #555;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
    th { background: #f5f5f5; font-weight: 600; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #ddd; margin: 2em 0; }
    a { color: #256f7f; }
  </style>
</head>
<body>
$body
</body>
</html>''';
}

/// Converts Markdown text to PDF bytes via HTML rendering.
Future<Uint8List> markdownToPdf(String markdown, {String? title}) async {
  final html = markdownToHtmlPage(markdown, title: title);

  // ignore: deprecated_member_use
  return await Printing.convertHtml(format: PdfPageFormat.a4, html: html);
}

/// Converts Markdown to PDF and opens the platform share/save dialog.
Future<void> shareAsPdf(String markdown, {String? filename}) async {
  final bytes = await markdownToPdf(markdown);
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
