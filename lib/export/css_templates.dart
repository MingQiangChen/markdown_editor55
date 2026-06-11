/// CSS templates for HTML export.
class CssTemplate {
  final String name;
  final String css;

  const CssTemplate({required this.name, required this.css});
}

/// Built-in CSS templates.
class CssTemplates {
  static const CssTemplate defaultTemplate = CssTemplate(
    name: 'Default',
    css: '''
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
''',
  );

  static const CssTemplate darkTemplate = CssTemplate(
    name: 'Dark',
    css: '''
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 820px;
      margin: 0 auto;
      padding: 2.2em;
      line-height: 1.7;
      color: #e0e0e0;
      background: #1e1e1e;
      font-size: 15px;
    }
    h1, h2, h3, h4 { margin-top: 1.4em; color: #fff; }
    h1 { font-size: 1.8em; }
    h2 { font-size: 1.4em; }
    h3 { font-size: 1.15em; }
    code {
      background: #2d2d2d;
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
      font-size: 0.9em;
      color: #f0f0f0;
    }
    pre {
      background: #2d2d2d;
      padding: 1em 1.2em;
      border-radius: 6px;
      overflow-x: auto;
      line-height: 1.45;
    }
    pre code { background: none; padding: 0; }
    blockquote {
      border-left: 4px solid #4a9eff;
      padding: 0.5em 1em;
      margin: 1em 0;
      background: #252525;
      color: #b0b0b0;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #444; padding: 8px 12px; text-align: left; }
    th { background: #2d2d2d; font-weight: 600; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #444; margin: 2em 0; }
    a { color: #4a9eff; }
''',
  );

  static const CssTemplate minimalTemplate = CssTemplate(
    name: 'Minimal',
    css: '''
    body {
      font-family: Georgia, 'Times New Roman', serif;
      max-width: 700px;
      margin: 0 auto;
      padding: 3em;
      line-height: 1.8;
      color: #333;
      font-size: 16px;
    }
    h1, h2, h3, h4 {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin-top: 2em;
      font-weight: 600;
    }
    h1 { font-size: 2em; }
    h2 { font-size: 1.5em; }
    h3 { font-size: 1.2em; }
    code {
      font-family: 'Courier New', monospace;
      font-size: 0.9em;
    }
    pre {
      padding: 1em;
      overflow-x: auto;
      line-height: 1.5;
      border-left: 3px solid #ccc;
    }
    blockquote {
      margin: 1.5em 0;
      padding-left: 1.5em;
      color: #666;
      font-style: italic;
    }
    table { border-collapse: collapse; width: 100%; margin: 1.5em 0; }
    th, td { padding: 10px 15px; text-align: left; border-bottom: 1px solid #ddd; }
    th { font-weight: 600; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #ddd; margin: 3em 0; }
    a { color: #0066cc; text-decoration: none; }
    a:hover { text-decoration: underline; }
''',
  );

  static const CssTemplate githubTemplate = CssTemplate(
    name: 'GitHub',
    css: '''
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
      max-width: 980px;
      margin: 0 auto;
      padding: 45px;
      line-height: 1.6;
      color: #24292e;
      font-size: 16px;
    }
    h1, h2, h3, h4 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; }
    h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid #eaecef; }
    h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid #eaecef; }
    h3 { font-size: 1.25em; }
    code {
      background: rgba(27,31,35,0.05);
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
      font-size: 85%;
    }
    pre {
      background: #f6f8fa;
      padding: 16px;
      border-radius: 6px;
      overflow-x: auto;
      line-height: 1.45;
    }
    pre code { background: none; padding: 0; font-size: 100%; }
    blockquote {
      border-left: 0.25em solid #dfe2e5;
      padding: 0 1em;
      margin: 0 0 16px 0;
      color: #6a737d;
    }
    table { border-collapse: collapse; width: 100%; margin: 16px 0; }
    th, td { border: 1px solid #dfe2e5; padding: 6px 13px; }
    th { background: #f6f8fa; font-weight: 600; }
    tr:nth-child(even) { background: #f6f8fa; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #dfe2e5; margin: 24px 0; }
    a { color: #0366d6; text-decoration: none; }
    a:hover { text-decoration: underline; }
''',
  );

  static const List<CssTemplate> all = [
    defaultTemplate,
    darkTemplate,
    minimalTemplate,
    githubTemplate,
  ];
}
