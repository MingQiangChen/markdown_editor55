import 'package:markdown/markdown.dart';

/// Parses mermaid code blocks: ```mermaid ... ```
class MermaidBlockSyntax extends FencedCodeBlockSyntax {
  @override
  Node parse(BlockParser parser) {
    final infoString = parser.current.content.substring(3).trim();

    // Only handle mermaid code blocks
    if (infoString.toLowerCase() != 'mermaid') {
      // Fall back to default code block handling
      return super.parse(parser);
    }

    final lines = <String>[];
    parser.advance(); // Skip opening ```

    while (!parser.isDone) {
      if (RegExp(r'^```\s*$').hasMatch(parser.current.content)) {
        parser.advance(); // Skip closing ```
        break;
      }
      lines.add(parser.current.content);
      parser.advance();
    }

    final element = Element.withTag('mermaid');
    element.attributes['diagram'] = lines.join('\n');
    return element;
  }
}
