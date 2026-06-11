import 'package:markdown/markdown.dart';

/// Parses block math: $$...$$
class MathBlockSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\$\$\s*$');

  @override
  bool canParse(BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  Node? parse(BlockParser parser) {
    final lines = <String>[];
    parser.advance(); // Skip opening $$

    while (!parser.isDone) {
      if (RegExp(r'^\$\$\s*$').hasMatch(parser.current.content)) {
        parser.advance(); // Skip closing $$
        break;
      }
      lines.add(parser.current.content);
      parser.advance();
    }

    final element = Element.withTag('math');
    element.attributes['latex'] = lines.join('\n');
    element.attributes['display'] = 'true';
    return element;
  }
}
