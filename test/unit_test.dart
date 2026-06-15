import 'package:flutter_test/flutter_test.dart';

import 'package:markdown_editor/editor/document_stats.dart';
import 'package:markdown_editor/recent_store/recent_store_base.dart';
import 'package:markdown_editor/settings/settings_base.dart';
import 'package:markdown_editor/export/css_templates.dart';
import 'package:markdown_editor/export/export_service.dart';

void main() {
  group('DocumentStats', () {
    test('counts words and characters', () {
      final stats = DocumentStats.fromText('hello world');
      expect(stats.words, 2);
      expect(stats.characters, 11);
    });

    test('empty text has zero words', () {
      final stats = DocumentStats.fromText('');
      expect(stats.words, 0);
      expect(stats.characters, 0);
    });

    test('whitespace-only text has zero words', () {
      final stats = DocumentStats.fromText('   ');
      expect(stats.words, 0);
      expect(stats.characters, 3);
    });

    test('multiline text counts words correctly', () {
      final stats = DocumentStats.fromText('hello\nworld\nfoo');
      expect(stats.words, 3);
    });

    test('single word', () {
      final stats = DocumentStats.fromText('hello');
      expect(stats.words, 1);
      expect(stats.characters, 5);
    });
  });

  group('AppSettings', () {
    test('default values', () {
      const settings = AppSettings();
      expect(settings.fontSize, 14);
      expect(settings.fontFamily, '');
      expect(settings.tabSize, 2);
      expect(settings.defaultViewMode, EditorViewMode.split);
      expect(settings.wordWrap, true);
      expect(settings.autoSaveIntervalMs, 500);
    });

    test('copyWith overrides fields', () {
      const settings = AppSettings();
      final updated = settings.copyWith(fontSize: 18, wordWrap: false);
      expect(updated.fontSize, 18);
      expect(updated.wordWrap, false);
      expect(updated.tabSize, 2);
    });

    test('toJson and fromJson roundtrip', () {
      const settings = AppSettings(
        fontSize: 16,
        fontFamily: 'Consolas',
        tabSize: 4,
        defaultViewMode: EditorViewMode.editor,
        wordWrap: false,
        autoSaveIntervalMs: 1000,
      );
      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);
      expect(restored.fontSize, 16);
      expect(restored.fontFamily, 'Consolas');
      expect(restored.tabSize, 4);
      expect(restored.defaultViewMode, EditorViewMode.editor);
      expect(restored.wordWrap, false);
      expect(restored.autoSaveIntervalMs, 1000);
    });

    test('fromJson handles missing fields with defaults', () {
      final settings = AppSettings.fromJson(<String, dynamic>{});
      expect(settings.fontSize, 14);
      expect(settings.tabSize, 2);
      expect(settings.wordWrap, true);
    });
  });

  group('RecentDocument', () {
    test('toJson and fromJson roundtrip', () {
      final doc = RecentDocument(
        path: '/tmp/test.md',
        name: 'test.md',
        content: '# Hello',
        lastOpened: DateTime(2026, 1, 15),
      );
      final json = doc.toJson();
      final restored = RecentDocument.fromJson(json);
      expect(restored.path, '/tmp/test.md');
      expect(restored.name, 'test.md');
      expect(restored.content, '# Hello');
      expect(restored.lastOpened, DateTime(2026, 1, 15));
    });

    test('toJson omits null content', () {
      final doc = RecentDocument(
        path: '/tmp/test.md',
        name: 'test.md',
        lastOpened: DateTime(2026, 1, 15),
      );
      final json = doc.toJson();
      expect(json.containsKey('content'), false);
    });
  });

  group('CssTemplates', () {
    test('has default template', () {
      expect(CssTemplates.defaultTemplate.name, isNotEmpty);
      expect(CssTemplates.defaultTemplate.css, isNotEmpty);
    });

    test('has dark template', () {
      expect(CssTemplates.darkTemplate.name, isNotEmpty);
      expect(CssTemplates.darkTemplate.css, isNotEmpty);
    });

    test('has minimal template', () {
      expect(CssTemplates.minimalTemplate.name, isNotEmpty);
      expect(CssTemplates.minimalTemplate.css, isNotEmpty);
    });

    test('has github template', () {
      expect(CssTemplates.githubTemplate.name, isNotEmpty);
      expect(CssTemplates.githubTemplate.css, isNotEmpty);
    });
  });

  group('markdownToHtmlPage', () {
    test('generates valid HTML page', () {
      final html = markdownToHtmlPage('# Hello\n\nWorld');
      expect(html, contains('<!DOCTYPE html>'));
      expect(html, contains('<html'));
      expect(html, contains('</html>'));
      expect(html, contains('Hello'));
      expect(html, contains('World'));
    });

    test('includes KaTeX when enabled', () {
      final html = markdownToHtmlPage('# Hello', enableKatex: true);
      expect(html, contains('katex'));
    });

    test('includes Mermaid when enabled', () {
      final html = markdownToHtmlPage('# Hello', enableMermaid: true);
      expect(html, contains('mermaid'));
    });

    test('uses custom CSS template', () {
      final html = markdownToHtmlPage(
        '# Hello',
        template: CssTemplates.darkTemplate,
      );
      expect(html, contains(CssTemplates.darkTemplate.css));
    });
  });
}
