import 'package:markdown/markdown.dart';

/// Parses inline math: $...$
class MathInlineSyntax extends InlineSyntax {
  MathInlineSyntax() : super(r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final math = match.group(1) ?? '';
    final element = Element.withTag('math');
    element.attributes['latex'] = math;
    element.attributes['display'] = 'false';
    parser.addNode(element);
    return true;
  }
}
