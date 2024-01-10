/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/svg/rendering/container.dart';
import 'package:webf/svg.dart';

abstract class RenderSVGShape extends RenderBoxModel {
  bool _needUpdateShape = true;

  SVGGeometryElement? element;

  RenderSVGShape({
    required super.renderStyle,
    this.element,
  });

  RenderSVGContainer? _rootRenderSVGContainer;
  RenderSVGContainer? findRoot() {
    if (_rootRenderSVGContainer != null) {
      return _rootRenderSVGContainer;
    }
    var parent = renderStyle.target.parentElement?.renderer;
    while (parent is RenderBoxModel) {
      if (parent is RenderSVGContainer) {
        _rootRenderSVGContainer = parent;
        return parent;
      }
      parent = parent.renderStyle.target.parentElement?.renderer;
    }
    return null;
  }

  Path? _path;
  Path get path => _path ??= asPath();

  @override
  void performPaint(PaintingContext context, Offset offset) {
    final fill = renderStyle.isFillEmpty ? findRoot()?.renderStyle.fill ?? renderStyle.fill : renderStyle.fill;
    final stroke = renderStyle.isStrokeEmpty ? findRoot()?.renderStyle.stroke ?? renderStyle.stroke : renderStyle.stroke;
    final fillRule = renderStyle.isFillRuleEmpty ? findRoot()?.renderStyle.fillRule ?? renderStyle.fillRule : renderStyle.fillRule;

    path.fillType = fillRule.fillType;

    Rect? rect = element?.findRoot()?.viewBox;
    if (rect != null) {
      parseDefs(rect);
    }
    /// support svg clipPath
    if (svgClipPath != null) {
      Path? clipPath;
      switch (svgClipPath!.boxShape) {
        case BoxShape.circle:
          clipPath = svgClipPath!.clipPath;
          break;
        case BoxShape.rectangle:
          clipPath = svgClipPath!.clipPath;
          break;
      }
      context.canvas.clipPath(clipPath!);
    }
    Path vpath = path.shift(offset);
    Paint? vpaint;
    if (shader != null) {
      vpaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.fill;
    } else if (!fill.isNone) {
      vpaint = Paint()
        ..color = fill.resolve(renderStyle)
        ..style = PaintingStyle.fill;
    }
    if (vpaint != null) {
      context.canvas.drawPath(vpath, vpaint);
    }
    if (!stroke.isNone) {
      final strokeWidth = renderStyle.strokeWidth.computedValue;
      final strokeCap = renderStyle.strokeLinecap.strokeCap;
      final strokeJoin = renderStyle.strokeLinejoin.strokeJoin;
      Paint? v2paint = Paint()
        ..color = stroke.resolve(renderStyle)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap
        ..strokeJoin = strokeJoin;
      context.canvas.drawPath(vpath, v2paint);
    }
  }

  @override
  void performLayout() {
    if (_needUpdateShape || _path == null) {
      _path = asPath();
      _needUpdateShape = false;
      size = _path!.getBounds().size;
      dispatchResize(contentSize, boxSize ?? Size.zero);
    }
  }

  @override
  void paintBoxModel(PaintingContext context, Offset offset) {
    performPaint(context, offset);
  }

  Path asPath();

  void parseDefs(Rect rect) {
    dynamic fillAttr = element?.attributeStyle['fill'] ?? findRoot()?.element?.attributeStyle['fill'];
    dynamic clipPathAttr = element?.attributeStyle['clipPath'] ?? findRoot()?.element?.attributeStyle['clipPath'];
    if (fillAttr == null && clipPathAttr == null) return null;

    NodeList? nodeList = element?.findRoot()?.childNodes;
    if (nodeList != null) {
      Iterator iterator = nodeList.iterator;
      while (iterator.moveNext()) {
        if (iterator.current is SVGDefsElement) {
          SVGDefsElement element = iterator.current ;
          if (fillAttr != null && _shader == null) {
            _shader = element.getShader(fillAttr, rect);
          }
          if (clipPathAttr != null && _svgClipPath == null) {
            _svgClipPath = element.getClipPath(clipPathAttr, rect);
          }
        }
      }
    }
    return null;
  }

  Shader? _shader;
  Shader? get shader => _shader;

  SVGClipPath? _svgClipPath;
  SVGClipPath? get svgClipPath => _svgClipPath;

  markNeedUpdateShape() {
    _needUpdateShape = true;
    // PERF: use paint instead of layout
    markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return null;
  }
}
