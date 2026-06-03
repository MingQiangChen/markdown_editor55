import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markdown_editor/main.dart';

void main() {
  testWidgets('editor renders initial document and toggles preview', (
    tester,
  ) async {
    await tester.pumpWidget(const MarkdownEditorApp());

    expect(find.text('QLaw Markdown'), findsWidgets);
    expect(
      find.text('Start writing on the left. The preview updates as you type.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
    expect(find.text('Edit + preview'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.text('Edit only'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
