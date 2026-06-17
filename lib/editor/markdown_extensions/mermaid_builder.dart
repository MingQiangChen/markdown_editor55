import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:webview_flutter/webview_flutter.dart';

/// Builder for mermaid diagram elements - renders using WebView with Mermaid.js
class MermaidBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final diagram = element.attributes['diagram'] ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Mermaid Diagram',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 400,
            child: _MermaidWebView(
              diagram: diagram,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MermaidWebView extends StatefulWidget {
  final String diagram;
  final bool isDark;

  const _MermaidWebView({
    required this.diagram,
    required this.isDark,
  });

  @override
  State<_MermaidWebView> createState() => _MermaidWebViewState();
}

class _MermaidWebViewState extends State<_MermaidWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        widget.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      )
      ..loadHtmlString(_buildHtml(widget.diagram, widget.isDark));
  }

  String _buildHtml(String diagram, bool isDark) {
    final backgroundColor = isDark ? '#1e1e1e' : '#ffffff';
    final textColor = isDark ? '#e0e0e0' : '#333333';
    
    // Escape the diagram content for JavaScript
    final escapedDiagram = diagram
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
    body {
      background-color: $backgroundColor;
      color: $textColor;
      margin: 0;
      padding: 16px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .mermaid {
      text-align: center;
    }
    .error {
      color: #ff6b6b;
      padding: 16px;
      background: rgba(255, 107, 107, 0.1);
      border-radius: 4px;
      font-family: monospace;
      white-space: pre-wrap;
    }
  </style>
</head>
<body>
  <div class="mermaid">$escapedDiagram</div>
  <div id="error" class="error" style="display: none;"></div>
  
  <script>
    mermaid.initialize({ 
      startOnLoad: true,
      theme: '${isDark ? 'dark' : 'default'}',
      securityLevel: 'loose'
    });
    
    window.addEventListener('error', function(event) {
      document.getElementById('diagram').style.display = 'none';
      const errorDiv = document.getElementById('error');
      errorDiv.style.display = 'block';
      errorDiv.textContent = 'Mermaid rendering error: ' + event.message;
    });
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}