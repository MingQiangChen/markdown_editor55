import 'package:markdown/markdown.dart';

/// Parses mermaid code blocks: ```mermaid ... ```
class MermaidBlockSyntax extends FencedCodeBlockSyntax {
  @override
  bool canParse(BlockParser parser) {
    // Only match code blocks with mermaid info string
    if (!super.canParse(parser)) return false;
    
    final infoString = parser.current.content.substring(3).trim();
    return infoString.toLowerCase() == 'mermaid';
  }

  @override
  Node parse(BlockParser parser) {
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
