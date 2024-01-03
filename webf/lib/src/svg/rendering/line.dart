
import 'dart:ui';

import 'package:webf/src/svg/rendering/shape.dart';

// https://developer.mozilla.org/en-US/docs/Web/SVG/Element/line
class RenderSVGLine extends RenderSVGShape{
  RenderSVGLine({required super.renderStyle,super.element});

  @override
  Path asPath() {
    final x1 = renderStyle.x1.computedValue;
    final y1 = renderStyle.y1.computedValue;
    final x2 = renderStyle.x2.computedValue;
    final y2 = renderStyle.y2.computedValue;
    return Path()..moveTo(x1, y1)..lineTo(x2, y2);
  }

}
