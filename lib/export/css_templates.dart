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

  static const CssTemplate solarizedTemplate = CssTemplate(
    name: 'Solarized',
    css: '''
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 820px;
      margin: 0 auto;
      padding: 2.2em;
      line-height: 1.7;
      color: #657b83;
      background: #fdf6e3;
      font-size: 15px;
    }
    h1, h2, h3, h4 { margin-top: 1.4em; color: #073642; }
    h1 { font-size: 1.8em; }
    h2 { font-size: 1.4em; }
    h3 { font-size: 1.15em; }
    code {
      background: #eee8d5;
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
      font-size: 0.9em;
      color: #586e75;
    }
    pre {
      background: #eee8d5;
      padding: 1em 1.2em;
      border-radius: 6px;
      overflow-x: auto;
      line-height: 1.45;
    }
    pre code { background: none; padding: 0; }
    blockquote {
      border-left: 4px solid #268bd2;
      padding: 0.5em 1em;
      margin: 1em 0;
      background: #eee8d5;
      color: #586e75;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #93a1a1; padding: 8px 12px; text-align: left; }
    th { background: #eee8d5; font-weight: 600; color: #073642; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #93a1a1; margin: 2em 0; }
    a { color: #268bd2; }
''',
  );

  static const CssTemplate nordTemplate = CssTemplate(
    name: 'Nord',
    css: '''
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 820px;
      margin: 0 auto;
      padding: 2.2em;
      line-height: 1.7;
      color: #d8dee9;
      background: #2e3440;
      font-size: 15px;
    }
    h1, h2, h3, h4 { margin-top: 1.4em; color: #eceff4; }
    h1 { font-size: 1.8em; }
    h2 { font-size: 1.4em; }
    h3 { font-size: 1.15em; }
    code {
      background: #3b4252;
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
      font-size: 0.9em;
      color: #88c0d0;
    }
    pre {
      background: #3b4252;
      padding: 1em 1.2em;
      border-radius: 6px;
      overflow-x: auto;
      line-height: 1.45;
    }
    pre code { background: none; padding: 0; }
    blockquote {
      border-left: 4px solid #81a1c1;
      padding: 0.5em 1em;
      margin: 1em 0;
      background: #3b4252;
      color: #d8dee9;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #4c566a; padding: 8px 12px; text-align: left; }
    th { background: #3b4252; font-weight: 600; color: #eceff4; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #4c566a; margin: 2em 0; }
    a { color: #88c0d0; }
''',
  );

  static const CssTemplate academicTemplate = CssTemplate(
    name: 'Academic',
    css: '''
    body {
      font-family: 'Palatino Linotype', 'Book Antiqua', Palatino, serif;
      max-width: 720px;
      margin: 0 auto;
      padding: 3em;
      line-height: 1.8;
      color: #000;
      font-size: 12pt;
    }
    h1, h2, h3, h4 {
      font-family: 'Times New Roman', Times, serif;
      margin-top: 2em;
      font-weight: bold;
    }
    h1 { font-size: 16pt; text-align: center; margin-bottom: 1em; }
    h2 { font-size: 14pt; }
    h3 { font-size: 12pt; }
    code {
      font-family: 'Courier New', Courier, monospace;
      font-size: 10pt;
    }
    pre {
      padding: 1em;
      overflow-x: auto;
      line-height: 1.4;
      border: 1px solid #ccc;
      background: #f9f9f9;
    }
    blockquote {
      margin: 1.5em 2em;
      padding-left: 1em;
      border-left: 2px solid #999;
      font-style: italic;
    }
    table { border-collapse: collapse; width: 100%; margin: 1.5em 0; }
    th, td { border: 1px solid #000; padding: 8px 12px; text-align: left; }
    th { font-weight: bold; background: #f0f0f0; }
    img { max-width: 100%; }
    hr { border: none; border-top: 1px solid #000; margin: 2em 0; }
    a { color: #000; text-decoration: underline; }
''',
  );

  static const CssTemplate technicalTemplate = CssTemplate(
    name: 'Technical',
    css: '''
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      max-width: 900px;
      margin: 0 auto;
      padding: 2em;
      line-height: 1.6;
      color: #333;
      font-size: 14px;
    }
    h1, h2, h3, h4 { margin-top: 1.5em; color: #0066cc; font-weight: 600; }
    h1 { font-size: 24px; border-bottom: 2px solid #0066cc; padding-bottom: 0.3em; }
    h2 { font-size: 20px; border-bottom: 1px solid #ddd; padding-bottom: 0.2em; }
    h3 { font-size: 16px; }
    code {
      background: #f5f5f5;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
      font-size: 13px;
      color: #c7254e;
    }
    pre {
      background: #f8f8f8;
      padding: 12px;
      border-radius: 4px;
      border: 1px solid #e1e1e1;
      overflow-x: auto;
      line-height: 1.5;
    }
    pre code { background: none; padding: 0; color: inherit; }
    blockquote {
      border-left: 4px solid #0066cc;
      padding: 0.5em 1em;
      margin: 1em 0;
      background: #f0f7ff;
      color: #555;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
    th { background: #0066cc; color: white; font-weight: 600; }
    tr:nth-child(even) { background: #f9f9f9; }
    img { max-width: 100%; border: 1px solid #ddd; }
    hr { border: none; border-top: 1px solid #ddd; margin: 2em 0; }
    a { color: #0066cc; }
''',
  );


  static const CssTemplate newspaperTemplate = CssTemplate(
    name: 'Newspaper',
    css: '''
    body {
      font-family: 'Georgia', 'Times New Roman', serif;
      max-width: 1100px;
      margin: 0 auto;
      padding: 2em;
      line-height: 1.6;
      color: #1a1a1a;
      font-size: 15px;
      column-count: 2;
      column-gap: 40px;
      column-rule: 1px solid #ccc;
    }
    h1, h2, h3, h4 {
      font-family: 'Times New Roman', serif;
      margin-top: 1em;
      font-weight: bold;
      column-span: all;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    h1 { font-size: 2.2em; border-bottom: 3px double #333; padding-bottom: 0.3em; margin-bottom: 0.5em; }
    h2 { font-size: 1.6em; border-bottom: 1px solid #666; padding-bottom: 0.2em; }
    h3 { font-size: 1.3em; }
    code {
      font-family: 'Courier New', monospace;
      font-size: 0.85em;
      background: #f5f5f5;
      padding: 0.1em 0.3em;
    }
    pre {
      background: #f5f5f5;
      padding: 1em;
      overflow-x: auto;
      column-span: all;
      border: 1px solid #ddd;
      font-size: 13px;
    }
    pre code { background: none; padding: 0; }
    blockquote {
      font-style: italic;
      margin: 1em 0;
      padding: 0.5em 1em;
      border-left: 3px solid #666;
      background: #f9f9f9;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; column-span: all; }
    th, td { border: 1px solid #999; padding: 6px 10px; text-align: left; font-size: 14px; }
    th { background: #333; color: white; font-weight: bold; }
    img { max-width: 100%; }
    hr { border: none; border-top: 2px solid #333; margin: 1.5em 0; column-span: all; }
    a { color: #0066cc; text-decoration: none; border-bottom: 1px dotted #0066cc; }
    p { margin: 0.8em 0; text-align: justify; }
    p:first-letter { font-size: 1.2em; font-weight: bold; }
''',
  );

  static const CssTemplate presentationTemplate = CssTemplate(
    name: 'Presentation',
    css: '''
    body {
      font-family: 'Helvetica Neue', Arial, sans-serif;
      max-width: 1200px;
      margin: 0 auto;
      padding: 3em 4em;
      line-height: 1.8;
      color: #2c3e50;
      font-size: 20px;
      background: #ffffff;
    }
    h1, h2, h3, h4 {
      margin-top: 1.5em;
      font-weight: 700;
      color: #1a252f;
      letter-spacing: -0.5px;
    }
    h1 { font-size: 2.8em; color: #e74c3c; margin-bottom: 0.3em; }
    h2 { font-size: 2em; color: #34495e; border-left: 6px solid #e74c3c; padding-left: 0.5em; }
    h3 { font-size: 1.5em; color: #7f8c8d; }
    code {
      background: #ecf0f1;
      padding: 0.2em 0.5em;
      border-radius: 4px;
      font-family: 'Fira Code', 'Consolas', monospace;
      font-size: 0.85em;
      color: #c0392b;
    }
    pre {
      background: #2c3e50;
      color: #ecf0f1;
      padding: 1.5em;
      border-radius: 8px;
      overflow-x: auto;
      font-size: 16px;
      line-height: 1.5;
    }
    pre code { background: none; color: inherit; padding: 0; }
    blockquote {
      border-left: 5px solid #e74c3c;
      padding: 0.8em 1.5em;
      margin: 1.5em 0;
      background: #fdf2f2;
      font-size: 1.1em;
      font-style: italic;
      color: #555;
    }
    table { border-collapse: collapse; width: 100%; margin: 1.5em 0; font-size: 18px; }
    th, td { border: 2px solid #bdc3c7; padding: 12px 18px; text-align: left; }
    th { background: #34495e; color: white; font-weight: 600; }
    tr:nth-child(even) { background: #f8f9fa; }
    img { max-width: 100%; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    hr { border: none; border-top: 3px solid #e74c3c; margin: 2.5em 0; width: 30%; }
    a { color: #3498db; font-weight: 600; }
    ul, ol { padding-left: 1.5em; }
    li { margin: 0.5em 0; }
''',
  );

  static const CssTemplate notionTemplate = CssTemplate(
    name: 'Notion',
    css: '''
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
      max-width: 900px;
      margin: 0 auto;
      padding: 2em 3em;
      line-height: 1.7;
      color: #37352f;
      font-size: 16px;
    }
    h1, h2, h3, h4 { margin-top: 1.8em; font-weight: 600; color: #37352f; }
    h1 { font-size: 1.9em; }
    h2 { font-size: 1.5em; }
    h3 { font-size: 1.2em; }
    code {
      background: rgba(135,131,120,0.15);
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'SFMono-Regular', 'Consolas', 'Liberation Mono', monospace;
      font-size: 85%;
      color: #eb5757;
    }
    pre {
      background: #f7f6f3;
      padding: 1em 1.2em;
      border-radius: 4px;
      overflow-x: auto;
      line-height: 1.5;
    }
    pre code { background: none; padding: 0; color: #37352f; }
    blockquote {
      border-left: 3px solid #37352f;
      padding: 0.3em 1em;
      margin: 1em 0;
      color: #37352f;
      background: transparent;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #e9e9e7; padding: 8px 12px; text-align: left; font-size: 14px; }
    th { background: #f7f6f3; font-weight: 600; }
    tr:hover { background: #f7f6f3; }
    img { max-width: 100%; border-radius: 4px; }
    hr { border: none; border-top: 1px solid #e9e9e7; margin: 2em 0; }
    a { color: #37352f; text-decoration: underline; text-decoration-color: rgba(55,53,47,0.4); }
    a:hover { text-decoration-color: #37352f; }
    ul, ol { padding-left: 1.5em; }
    li { margin: 0.3em 0; }
    li > p { margin: 0.5em 0; }
''',
  );

  static const CssTemplate draculaTemplate = CssTemplate(
    name: 'Dracula',
    css: '''
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 820px;
      margin: 0 auto;
      padding: 2.2em;
      line-height: 1.7;
      color: #f8f8f2;
      background: #282a36;
      font-size: 15px;
    }
    h1, h2, h3, h4 { margin-top: 1.4em; color: #f8f8f2; font-weight: 600; }
    h1 { font-size: 1.8em; color: #bd93f9; }
    h2 { font-size: 1.4em; color: #ff79c6; }
    h3 { font-size: 1.15em; color: #8be9fd; }
    code {
      background: #44475a;
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-family: 'Fira Code', 'Consolas', monospace;
      font-size: 0.9em;
      color: #ffb86c;
    }
    pre {
      background: #44475a;
      padding: 1em 1.2em;
      border-radius: 6px;
      overflow-x: auto;
      line-height: 1.45;
      border: 1px solid #6272a4;
    }
    pre code { background: none; padding: 0; color: #f8f8f2; }
    blockquote {
      border-left: 4px solid #bd93f9;
      padding: 0.5em 1em;
      margin: 1em 0;
      background: #44475a;
      color: #f8f8f2;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid #6272a4; padding: 8px 12px; text-align: left; }
    th { background: #44475a; font-weight: 600; color: #bd93f9; }
    tr:nth-child(even) { background: rgba(68,71,90,0.3); }
    img { max-width: 100%; border-radius: 6px; }
    hr { border: none; border-top: 1px solid #6272a4; margin: 2em 0; }
    a { color: #8be9fd; }
    a:hover { color: #50fa7b; }
    strong { color: #ff79c6; }
    em { color: #f1fa8c; }
''',
  );

  static const List<CssTemplate> all = [
    defaultTemplate,
    darkTemplate,
    minimalTemplate,
    githubTemplate,
    solarizedTemplate,
    nordTemplate,
    draculaTemplate,
    academicTemplate,
    technicalTemplate,
    newspaperTemplate,
    presentationTemplate,
    notionTemplate,
  ];
}