/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/painting.dart';
import 'package:webf/html.dart';
import 'package:webf/css.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';

// CSS Backgrounds: https://drafts.csswg.org/css-backgrounds/
// CSS Images: https://drafts.csswg.org/css-images-3/

const String _singleQuote = '\'';
const String _doubleQuote = '"';

String removeQuotationMark(String input) {
  if ((input.startsWith(_singleQuote) && input.endsWith(_singleQuote)) ||
      (input.startsWith(_doubleQuote) && input.endsWith(_doubleQuote))) {
    input = input.substring(1, input.length - 1);
  }
  return input;
}

// https://drafts.csswg.org/css-backgrounds/#typedef-attachment
enum CSSBackgroundAttachmentType {
  scroll,
  fixed,
  local,
}

extension CSSBackgroundAttachmentTypeText on CSSBackgroundAttachmentType {
  String cssText() {
    switch (this) {
      case CSSBackgroundAttachmentType.scroll:
        return 'scroll';
      case CSSBackgroundAttachmentType.fixed:
        return 'fixed';
      case CSSBackgroundAttachmentType.local:
        return 'local';
    }
  }
}

enum CSSBackgroundRepeatType {
  repeat,
  repeatX,
  repeatY,
  noRepeat,
}

extension CSSBackgroundRepeatTypeText on CSSBackgroundRepeatType {
  String cssText() {
    switch (this) {
      case CSSBackgroundRepeatType.repeat:
        return 'repeat';
      case CSSBackgroundRepeatType.repeatX:
        return 'repeat-x';
      case CSSBackgroundRepeatType.repeatY:
        return 'repeat-y';
      case CSSBackgroundRepeatType.noRepeat:
        return 'no-repeat';
    }
  }

  ImageRepeat imageRepeat() {
    switch (this) {
      case CSSBackgroundRepeatType.repeat:
        return ImageRepeat.repeat;
      case CSSBackgroundRepeatType.repeatX:
        return ImageRepeat.repeatX;
      case CSSBackgroundRepeatType.repeatY:
        return ImageRepeat.repeatY;
      case CSSBackgroundRepeatType.noRepeat:
        return ImageRepeat.noRepeat;
    }
  }
}

enum CSSBackgroundSizeType {
  auto,
  cover,
  contain,
}

enum CSSBackgroundPositionType {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum CSSBackgroundBoundary { borderBox, paddingBox, contentBox, text }

extension CSSBackgroundBoundaryText on CSSBackgroundBoundary {
  String cssText() {
    switch (this) {
      case CSSBackgroundBoundary.borderBox:
        return 'border-box';
      case CSSBackgroundBoundary.paddingBox:
        return 'padding-box';
      case CSSBackgroundBoundary.contentBox:
        return 'content-box';
      case CSSBackgroundBoundary.text:
        return 'text';
    }
  }
}

enum CSSBackgroundImageType {
  none,
  gradient,
  image,
}

/// The [CSSBackgroundMixin] mixin used to handle background shorthand and compute
/// to single value of background.
mixin CSSBackgroundMixin on RenderStyle {
  static CSSBackgroundPosition DEFAULT_BACKGROUND_POSITION = CSSBackgroundPosition(percentage: -1);
  static CSSBackgroundSize DEFAULT_BACKGROUND_SIZE = CSSBackgroundSize(fit: BoxFit.none);

  /// Background-clip
  @override
  CSSBackgroundBoundary? get backgroundClip => _backgroundClip;
  CSSBackgroundBoundary? _backgroundClip;

  set backgroundClip(CSSBackgroundBoundary? value) {
    if (value == _backgroundClip) return;
    _backgroundClip = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-origin
  @override
  CSSBackgroundBoundary? get backgroundOrigin => _backgroundOrigin;
  CSSBackgroundBoundary? _backgroundOrigin;

  set backgroundOrigin(CSSBackgroundBoundary? value) {
    if (value == _backgroundOrigin) return;
    _backgroundOrigin = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  @override
  CSSColor? get backgroundColor => _backgroundColor;
  CSSColor? _backgroundColor;

  set backgroundColor(CSSColor? value) {
    if (value == _backgroundColor) return;
    _backgroundColor = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-image
  @override
  CSSBackgroundImage? get backgroundImage => _backgroundImage;
  CSSBackgroundImage? _backgroundImage;

  set backgroundImage(CSSBackgroundImage? value) {
    if (value == _backgroundImage) return;
    if (_backgroundImage != null) {
      _backgroundImage!.dispose();
    }

    _backgroundImage = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-position-x
  @override
  CSSBackgroundPosition get backgroundPositionX => _backgroundPositionX ?? DEFAULT_BACKGROUND_POSITION;
  CSSBackgroundPosition? _backgroundPositionX;

  set backgroundPositionX(CSSBackgroundPosition? value) {
    if (value == _backgroundPositionX) return;
    _backgroundPositionX = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-position-y
  @override
  CSSBackgroundPosition get backgroundPositionY => _backgroundPositionY ?? DEFAULT_BACKGROUND_POSITION;
  CSSBackgroundPosition? _backgroundPositionY;

  set backgroundPositionY(CSSBackgroundPosition? value) {
    if (value == _backgroundPositionY) return;
    _backgroundPositionY = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-size
  @override
  CSSBackgroundSize get backgroundSize => _backgroundSize ?? DEFAULT_BACKGROUND_SIZE;
  CSSBackgroundSize? _backgroundSize;

  set backgroundSize(CSSBackgroundSize? value) {
    if (value == _backgroundSize) return;
    _backgroundSize = value;
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-attachment
  @override
  CSSBackgroundAttachmentType? get backgroundAttachment => _backgroundAttachment;
  CSSBackgroundAttachmentType? _backgroundAttachment;

  set backgroundAttachment(CSSBackgroundAttachmentType? value) {
    if (value == _backgroundAttachment) return;
    _backgroundAttachment = value;
    if (DebugFlags.enableBackgroundLogs) {
      try {
        final el = target;
        final id = (el.id != null && el.id!.isNotEmpty) ? '#${el.id}' : '';
        final cls = (el.className != null && el.className!.isNotEmpty) ? '.${el.className}' : '';
        renderingLogger.finer('[Background] set BACKGROUND_ATTACHMENT on <${el.tagName.toLowerCase()}$id$cls> -> '
            '${_backgroundAttachment?.cssText() ?? 'null'}');
      } catch (_) {}
    }
    markNeedsPaint();
    resetBoxDecoration();
  }

  /// Background-repeat
  @override
  CSSBackgroundRepeatType get backgroundRepeat => _backgroundRepeat ?? CSSBackgroundRepeatType.repeat;
  CSSBackgroundRepeatType? _backgroundRepeat;

  set backgroundRepeat(CSSBackgroundRepeatType? value) {
    if (value == _backgroundRepeat) return;
    _backgroundRepeat = value;
    markNeedsPaint();
    resetBoxDecoration();
  }
}

class CSSColorStop {
  Color? color;
  double? stop;

  CSSColorStop(this.color, this.stop);
}

class CSSBackgroundImage {
  List<CSSFunctionalNotation> functions;
  RenderStyle renderStyle;
  WebFController controller;
  String? baseHref;
  // Optional per-layer length hint to normalize px stops, provided by painter.
  final double? gradientLengthHint;

  CSSBackgroundImage(this.functions, this.renderStyle, this.controller, {this.baseHref, this.gradientLengthHint});

  ImageProvider? _image;

  static Future<ImageLoadResponse> _obtainImage(Element element, Uri url) async {
    ImageRequest request = ImageRequest.fromUri(url);
    // Increment count when request.
    element.ownerDocument.controller.view.document.incrementRequestCount();

    ImageLoadResponse data = await request.obtainImage(element.ownerDocument.controller);

    // Decrement count when response.
    element.ownerDocument.controller.view.document.decrementRequestCount();
    return data;
  }

  static void _handleBitFitImageLoad(
      Element element, int naturalWidth, int naturalHeight, int frameCount) {
    if (frameCount > 1 && !element.isRepaintBoundary) {
      element.forceToRepaintBoundary = true;
      element.renderStyle.getSelfRenderBoxValue((renderBox, _) {
        renderBox.invalidateBoxPainter();
      });
    }
  }

  ImageProvider? get image {
    if (_image != null) return _image;
    for (CSSFunctionalNotation method in functions) {
      if (method.name == 'url') {
        String url = method.args.isNotEmpty ? method.args[0] : '';
        if (url.isEmpty) {
          continue;
        }
        // Method may contain quotation mark, like ['"assets/foo.png"']
        url = removeQuotationMark(url);

        Uri uri = Uri.parse(url);
        if (url.isNotEmpty) {
          final String base = baseHref ?? controller.url;

          uri = controller.uriParser!.resolve(Uri.parse(base), uri);
          FlutterView ownerFlutterView = controller.ownerFlutterView!;

          return _image = BoxFitImage(
            boxFit: renderStyle.backgroundSize.fit,
            url: uri,
            contextId: controller.view.contextId,
            targetElementPtr: renderStyle.target.pointer!,
            loadImage: _obtainImage,
            onImageLoad: _handleBitFitImageLoad,
            devicePixelRatio: ownerFlutterView.devicePixelRatio);
        }
      }
    }

    return null;
  }

  Gradient? _gradient;
  Gradient? get gradient {
    if (_gradient != null) return _gradient;
    List<Color> colors = [];
    List<double> stops = [];
    int start = 0;
    for (CSSFunctionalNotation method in functions) {
      switch (method.name) {
        case 'linear-gradient':
        case 'repeating-linear-gradient':
          double? linearAngle;
          Alignment begin = Alignment.topCenter;
          Alignment end = Alignment.bottomCenter;
          String arg0 = method.args[0].trim();
          double? gradientLength = gradientLengthHint;
          if (DebugFlags.enableBackgroundLogs) {
            renderingLogger.finer('[Background] parse ${method.name}: rawArgs=${method.args}');
          }
          if (arg0.startsWith('to ')) {
            List<String> parts = arg0.split(splitRegExp);
            if (parts.length >= 2) {
              switch (parts[1]) {
                case LEFT:
                  if (parts.length == 3) {
                    if (parts[2] == TOP) {
                      begin = Alignment.bottomRight;
                      end = Alignment.topLeft;
                    } else if (parts[2] == BOTTOM) {
                      begin = Alignment.topRight;
                      end = Alignment.bottomLeft;
                    }
                  } else {
                    begin = Alignment.centerRight;
                    end = Alignment.centerLeft;
                  }
                  gradientLength = renderStyle.paddingBoxWidth;
                  break;
                case TOP:
                  if (parts.length == 3) {
                    if (parts[2] == LEFT) {
                      begin = Alignment.bottomRight;
                      end = Alignment.topLeft;
                    } else if (parts[2] == RIGHT) {
                      begin = Alignment.bottomLeft;
                      end = Alignment.topRight;
                    }
                  } else {
                    begin = Alignment.bottomCenter;
                    end = Alignment.topCenter;
                  }
                  gradientLength = renderStyle.paddingBoxHeight;
                  break;
                case RIGHT:
                  if (parts.length == 3) {
                    if (parts[2] == TOP) {
                      begin = Alignment.bottomLeft;
                      end = Alignment.topRight;
                    } else if (parts[2] == BOTTOM) {
                      begin = Alignment.topLeft;
                      end = Alignment.bottomRight;
                    }
                  } else {
                    begin = Alignment.centerLeft;
                    end = Alignment.centerRight;
                  }
                  gradientLength = renderStyle.paddingBoxWidth;
                  break;
                case BOTTOM:
                  if (parts.length == 3) {
                    if (parts[2] == LEFT) {
                      begin = Alignment.topRight;
                      end = Alignment.bottomLeft;
                    } else if (parts[2] == RIGHT) {
                      begin = Alignment.topLeft;
                      end = Alignment.bottomRight;
                    }
                  } else {
                    begin = Alignment.topCenter;
                    end = Alignment.bottomCenter;
                  }
                  gradientLength = renderStyle.paddingBoxHeight;
                  break;
              }
            }
            linearAngle = null;
            start = 1;
          } else if (CSSAngle.isAngle(arg0)) {
            linearAngle = CSSAngle.parseAngle(arg0);
            start = 1;
          }
          // If no explicit gradientLength was resolved from painter hint or direction keywords,
          // try to derive it from background-size so px color-stops normalize
          // against the actual tile dimension instead of the element box.
          if (gradientLength == null) {
            final CSSBackgroundSize bs = renderStyle.backgroundSize;
            double? bsW = (bs.width != null && !bs.width!.isAuto) ? bs.width!.computedValue : null;
            double? bsH = (bs.height != null && !bs.height!.isAuto) ? bs.height!.computedValue : null;
            // Fallbacks when background-size is auto or layout not finalized yet.
            final double fbW = renderStyle.paddingBoxWidth ??
                (renderStyle.target.ownerDocument.viewport?.viewportSize.width ?? 0.0);
            final double fbH = renderStyle.paddingBoxHeight ??
                (renderStyle.target.ownerDocument.viewport?.viewportSize.height ?? 0.0);
            if (linearAngle != null) {
              // For angle-based gradients, approximate the gradient line length
              // using the tile size and the same projection used at shader time.
              final double sin = math.sin(linearAngle);
              final double cos = math.cos(linearAngle);
              final double w = bsW ?? fbW;
              final double h = bsH ?? fbH;
              gradientLength = (sin.abs() * w) + (cos.abs() * h);
            } else {
              // No angle provided: infer axis from begin/end and use the
              // background-size along that axis when available, else fall back to box/viewport.
              bool isVertical = (begin == Alignment.topCenter || begin == Alignment.bottomCenter) &&
                  (end == Alignment.topCenter || end == Alignment.bottomCenter);
              bool isHorizontal = (begin == Alignment.centerLeft || begin == Alignment.centerRight) &&
                  (end == Alignment.centerLeft || end == Alignment.centerRight);
              if (isVertical) {
                gradientLength = bsH ?? fbH;
              } else if (isHorizontal) {
                gradientLength = bsW ?? fbW;
              } else {
                // Diagonal without an explicit angle; use diagonal of available size.
                final double w = bsW ?? fbW;
                final double h = bsH ?? fbH;
                gradientLength = math.sqrt(w * w + h * h);
              }
            }
            if (DebugFlags.enableBackgroundLogs) {
              renderingLogger.finer('[Background] linear-gradient choose gradientLength = '
                  '${gradientLength?.toStringAsFixed(2)} (bg-size: w=${bs.width?.computedValue.toStringAsFixed(2) ?? 'auto'}, '
                  'h=${bs.height?.computedValue.toStringAsFixed(2) ?? 'auto'}; fb: w=${fbW.toStringAsFixed(2)}, h=${fbH.toStringAsFixed(2)})');
            }
          }
          if (gradientLengthHint != null && DebugFlags.enableBackgroundLogs) {
            renderingLogger.finer('[Background] linear-gradient using painter length hint = ${gradientLengthHint!.toStringAsFixed(2)}');
          }
          _applyColorAndStops(start, method.args, colors, stops, renderStyle, BACKGROUND_IMAGE, gradientLength);
          double? repeatPeriodPx;
          // For repeating-linear-gradient, normalize the stop range to one cycle [0..1]
          // so Flutter's TileMode.repeated repeats the intended segment length.
          if (method.name == 'repeating-linear-gradient' && stops.isNotEmpty) {
            final double first = stops.first;
            final double last = stops.last;
            double range = last - first;
            if (DebugFlags.enableBackgroundLogs) {
              final double? gl = gradientLength;
              final double periodPx = (gl != null && range > 0) ? (range * gl) : -1;
              renderingLogger.finer('[Background] repeating-linear normalize: first=${first.toStringAsFixed(4)} last=${last.toStringAsFixed(4)} '
                  'range=${range.toStringAsFixed(4)} periodPx=${periodPx >= 0 ? periodPx.toStringAsFixed(2) : '<unknown>'}');
            }
            if (range <= 0) {
              // Guard: invalid or zero-length cycle; fall back to full [0..1]
              // Keep stops as-is to avoid division by zero.
            } else {
              // Capture period in device pixels for shader scaling.
              if (gradientLength != null) {
                repeatPeriodPx = range * gradientLength!;
                if (DebugFlags.enableBackgroundLogs) {
                  renderingLogger.finer('[Background] repeating-linear periodPx=${repeatPeriodPx!.toStringAsFixed(2)}');
                }
              }
              for (int i = 0; i < stops.length; i++) {
                stops[i] = ((stops[i] - first) / range).clamp(0.0, 1.0);
              }
              if (DebugFlags.enableBackgroundLogs) {
                renderingLogger.finer('[Background] repeating-linear normalized stops=${stops.map((s)=>s.toStringAsFixed(4)).toList()}');
              }
            }
          }
          if (DebugFlags.enableBackgroundLogs) {
            final cs = colors
                .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
                .toList();
            final st = stops.map((s) => s.toStringAsFixed(4)).toList();
            final dir = linearAngle != null
                ? 'angle=' + (linearAngle * 180 / math.pi).toStringAsFixed(1) + 'deg'
                : 'begin=$begin end=$end';
            final len = gradientLength?.toStringAsFixed(2) ?? '<none>';
            renderingLogger.finer('[Background] ${method.name} colors=$cs stops=$st $dir gradientLength=$len');
          }
          if (colors.length >= 2) {
            _gradient = CSSLinearGradient(
                begin: begin,
                end: end,
                angle: linearAngle,
                repeatPeriod: repeatPeriodPx,
                colors: colors,
                stops: stops,
                tileMode: method.name == 'linear-gradient' ? TileMode.clamp : TileMode.repeated);
            return _gradient;
          }
          break;
        // Radial gradients: support "[<shape> || <size>] [at <position>]" prelude.
        // Current implementation treats shape as circle and size as farthest-corner by default,
        // but we do parse the optional "at <position>" correctly, including single-value forms
        // like "at 100%" meaning x=100%, y=center.
        case 'radial-gradient':
        case 'repeating-radial-gradient':
          double? atX = 0.5;
          double? atY = 0.5;
          double radius = 0.5; // normalized factor; 0.5 -> farthest-corner in CSSRadialGradient
          bool isEllipse = false;

          if (method.args.isNotEmpty) {
            final String prelude = method.args[0].trim();
            if (prelude.isNotEmpty) {
              // Split by whitespace while collapsing multiple spaces.
              final List<String> tokens = prelude.split(splitRegExp).where((s) => s.isNotEmpty).toList();

              // Detect ellipse/circle keywords
              isEllipse = tokens.contains('ellipse');
              // Detect and parse "at <position>" anywhere in prelude.
              final int atIndex = tokens.indexOf('at');
              if (atIndex != -1) {
                // Position tokens follow 'at'. They can be 1 or 2 tokens.
                final List<String> pos = tokens.sublist(atIndex + 1);
                if (pos.isNotEmpty) {
                  double parseX(String s) {
                    if (s == LEFT) return 0.0;
                    if (s == CENTER) return 0.5;
                    if (s == RIGHT) return 1.0;
                    if (CSSPercentage.isPercentage(s)) return CSSPercentage.parsePercentage(s)!;
                    return 0.5;
                  }
                  double parseY(String s) {
                    if (s == TOP) return 0.0;
                    if (s == CENTER) return 0.5;
                    if (s == BOTTOM) return 1.0;
                    if (CSSPercentage.isPercentage(s)) return CSSPercentage.parsePercentage(s)!;
                    return 0.5;
                  }

                  if (pos.length == 1) {
                    // Single-value position: percentage or a keyword on one axis.
                    final String v = pos.first;
                    if (v == TOP || v == BOTTOM) {
                      atY = parseY(v);
                      atX = 0.5;
                    } else {
                      atX = parseX(v);
                      atY = 0.5;
                    }
                  } else {
                    // Two-value position: x y.
                    atX = parseX(pos[0]);
                    atY = parseY(pos[1]);
                  }
                }
              }

              // Only treat arg[0] as a radial prelude when it does NOT start with a color token.
              // Previously, the presence of a percentage (e.g., "black 50%") caused arg[0]
              // to be misclassified as a prelude and skipped. Guard against that by checking
              // whether the first token looks like a color (named/hex/rgb[a]/hsl[a]/var()).
              final String firstToken = tokens.isNotEmpty ? tokens.first : '';
              final bool firstLooksLikeColor = CSSColor.isColor(firstToken) || firstToken.startsWith('var(');

              // Recognize common prelude markers when the first token is not a color.
              final bool hasPrelude = !firstLooksLikeColor && (
                  tokens.contains('circle') ||
                  tokens.contains('ellipse') ||
                  tokens.contains('closest-side') ||
                  tokens.contains('closest-corner') ||
                  tokens.contains('farthest-side') ||
                  tokens.contains('farthest-corner') ||
                  atIndex != -1 ||
                  // Allow explicit numeric size in prelude only if arg[0] doesn't start with a color.
                  tokens.any((t) => CSSPercentage.isPercentage(t) || CSSLength.isLength(t))
              );
              if (hasPrelude) start = 1;
            }
          }
          // Normalize px stops using painter-provided length hint when available.
          _applyColorAndStops(start, method.args, colors, stops, renderStyle, BACKGROUND_IMAGE, gradientLengthHint);
          // Ensure non-decreasing stops per CSS Images spec when explicit positions are out of order.
          if (stops.isNotEmpty) {
            double last = stops[0].clamp(0.0, 1.0);
            stops[0] = last;
            for (int i = 1; i < stops.length; i++) {
              double s = stops[i].clamp(0.0, 1.0);
              if (s < last) s = last;
              stops[i] = s;
              last = s;
            }
          }
          // For repeating-radial-gradient, normalize to one cycle [0..1] for tile repetition.
          double? repeatPeriodPx;
          if (method.name == 'repeating-radial-gradient' && stops.isNotEmpty) {
            final double first = stops.first;
            final double last = stops.last;
            double range = last - first;
            if (DebugFlags.enableBackgroundLogs) {
              final double periodPx = (gradientLengthHint != null && range > 0) ? (range * gradientLengthHint!) : -1;
              renderingLogger.finer('[Background] repeating-radial normalize: first=${first.toStringAsFixed(4)} last=${last.toStringAsFixed(4)} '
                  'range=${range.toStringAsFixed(4)} periodPx=${periodPx >= 0 ? periodPx.toStringAsFixed(2) : '<unknown>'}');
            }
            if (range > 0) {
              if (gradientLengthHint != null) {
                repeatPeriodPx = range * gradientLengthHint!;
              }
              for (int i = 0; i < stops.length; i++) {
                stops[i] = ((stops[i] - first) / range).clamp(0.0, 1.0);
              }
              if (DebugFlags.enableBackgroundLogs) {
                renderingLogger.finer('[Background] repeating-radial normalized stops=${stops.map((s)=>s.toStringAsFixed(4)).toList()}');
              }
            }
          }
          if (DebugFlags.enableBackgroundLogs) {
            final cs = colors
                .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
                .toList();
            renderingLogger.finer('[Background] ${method.name} colors=$cs stops=${stops.map((s)=>s.toStringAsFixed(4)).toList()} '
                'center=(${atX!.toStringAsFixed(3)},${atY!.toStringAsFixed(3)}) radius=$radius');
          }
          if (colors.length >= 2) {
            // Apply an ellipse transform when requested.
            final GradientTransform? xf = isEllipse ? CSSGradientEllipseTransform(atX!, atY!) : null;
            _gradient = CSSRadialGradient(
              center: FractionalOffset(atX!, atY!),
              radius: radius,
              colors: colors,
              stops: stops,
              tileMode: method.name == 'radial-gradient' ? TileMode.clamp : TileMode.repeated,
              transform: xf,
              repeatPeriod: repeatPeriodPx,
            );
            return _gradient;
          }
          break;
        case 'conic-gradient':
          double? from = 0.0;
          double? atX = 0.5;
          double? atY = 0.5;
          if (method.args.isNotEmpty && (method.args[0].contains('from ') || method.args[0].contains('at '))) {
            final List<String> tokens = method.args[0].trim().split(splitRegExp).where((s) => s.isNotEmpty).toList();
            final int fromIndex = tokens.indexOf('from');
            final int atIndex = tokens.indexOf('at');
            if (fromIndex != -1 && fromIndex + 1 < tokens.length) {
              from = CSSAngle.parseAngle(tokens[fromIndex + 1]);
            }
            if (atIndex != -1) {
              double parseX(String s) {
                if (s == LEFT) return 0.0;
                if (s == CENTER) return 0.5;
                if (s == RIGHT) return 1.0;
                if (CSSPercentage.isPercentage(s)) return CSSPercentage.parsePercentage(s)!;
                return 0.5;
              }
              double parseY(String s) {
                if (s == TOP) return 0.0;
                if (s == CENTER) return 0.5;
                if (s == BOTTOM) return 1.0;
                if (CSSPercentage.isPercentage(s)) return CSSPercentage.parsePercentage(s)!;
                return 0.5;
              }
              final List<String> pos = tokens.sublist(atIndex + 1);
              if (pos.isNotEmpty) {
                if (pos.length == 1) {
                  final String v = pos.first;
                  if (v == TOP || v == BOTTOM) {
                    atY = parseY(v);
                    atX = 0.5;
                  } else {
                    atX = parseX(v);
                    atY = 0.5;
                  }
                } else {
                  atX = parseX(pos[0]);
                  atY = parseY(pos[1]);
                }
              }
            }
            start = 1;
          }
          _applyColorAndStops(start, method.args, colors, stops, renderStyle, BACKGROUND_IMAGE);
          if (DebugFlags.enableBackgroundLogs) {
            final cs = colors
                .map((c) => 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})')
                .toList();
            final fromDeg = ((from ?? 0) * 180 / math.pi).toStringAsFixed(1);
            renderingLogger.finer('[Background] ${method.name} from=${fromDeg}deg colors=$cs stops=${stops.map((s)=>s.toStringAsFixed(4)).toList()}');
          }
          if (colors.length >= 2) {
            _gradient = CSSConicGradient(
                center: FractionalOffset(atX!, atY!),
                colors: colors,
                stops: stops,
                transform: GradientRotation(-math.pi / 2 + from!));
            return _gradient;
          }
          break;
      }
    }
    return null;
  }

  String cssText() {
    // Prefer stable serialization from functions rather than provider types.
    for (final method in functions) {
      switch (method.name) {
        case 'url':
          String url = method.args.isNotEmpty ? method.args[0] : '';
          url = removeQuotationMark(url);
          if (url.isEmpty) return 'none';
          // Resolve against baseHref/controller.url for computed style output
          final resolved = controller.uriParser!
              .resolve(Uri.parse(baseHref ?? controller.url), Uri.parse(url))
              .toString();
          return 'url($resolved)';
        case 'linear-gradient':
        case 'repeating-linear-gradient':
          return (gradient as CSSLinearGradient?)?.cssText() ?? 'none';
        case 'radial-gradient':
        case 'repeating-radial-gradient':
          return (gradient as CSSRadialGradient?)?.cssText() ?? 'none';
        case 'conic-gradient':
          return (gradient as CSSConicGradient?)?.cssText() ?? 'none';
      }
    }
    return 'none';
  }

  void dispose() {
    _image = null;
  }
}

class CSSBackgroundPosition {
  CSSBackgroundPosition({
    this.length,
    this.percentage,
    this.calcValue,
  });

  /// Absolute position to image container when length type is set.
  CSSLengthValue? length;

  /// Relative position to image container when keyword or percentage type is set.
  double? percentage;

  /// Relative position to image container when keyword or calcValue type is set.
  CSSCalcValue? calcValue;

  String cssText() {
    if (length != null) {
      // For computed style serialization of background-position axes, prefer
      // the authored absolute length for PX to avoid mixing in any cached
      // or layout-dependent adjustments. Other units (em/rem/%) still resolve
      // to absolute pixels via CSSLengthValue.cssText().
      if (length!.type == CSSLengthType.PX && length!.value != null) {
        return '${length!.value!.cssText()}px';
      }
      return length!.cssText();
    }
    if (percentage != null) {
      return '${((percentage! * 100 + 100) / 100 * 50).cssText()}%';
    }
    if (calcValue != null) {
      return '${(calcValue!.computedValue('') as double).cssText()}px';
    }
    return '';
  }

  String toString() {
    return cssText();
  }
}

class CSSBackgroundSize {
  CSSBackgroundSize({
    required this.fit,
    this.width,
    this.height,
  });

  // Keyword value (contain/cover/auto)
  BoxFit fit = BoxFit.none;

  // Length/percentage value
  CSSLengthValue? width;
  CSSLengthValue? height;

  @override
  String toString() => 'CSSBackgroundSize(fit: $fit, width: $width, height: $height)';

  String cssText() {
    if (fit == BoxFit.contain) {
      return 'contain';
    }
    if (fit == BoxFit.cover) {
      return 'cover';
    }
    if (width == null && height == null) {
      return 'auto';
    }

    if (width != null && (width == height || height == null)) {
      return width!.cssText();
    }

    return '${width!.cssText()} ${height!.cssText()}';
  }
}

class CSSBackground {
  static bool isValidBackgroundRepeatValue(String value) {
    return value == REPEAT || value == NO_REPEAT || value == REPEAT_X || value == REPEAT_Y;
  }

  static bool isValidBackgroundSizeValue(String value) {
    return value == AUTO ||
        value == CONTAIN ||
        value == COVER ||
        value == FIT_WIDTH ||
        value == FIT_HEIGTH ||
        value == SCALE_DOWN ||
        value == FILL ||
        CSSLength.isNonNegativeLength(value) ||
        CSSPercentage.isNonNegativePercentage(value);
  }

  static bool isValidBackgroundAttachmentValue(String value) {
    // Support all standard attachment keywords: scroll | fixed | local
    return value == SCROLL || value == LOCAL || value == FIXED;
  }

  static bool isValidBackgroundImageValue(String value) {
    // According to CSS Backgrounds spec, 'none' is a valid <bg-image> keyword.
    if (value == 'none') return true;
    return (value.lastIndexOf(')') == value.length - 1) &&
        (value.startsWith('url(') ||
            value.startsWith('linear-gradient(') ||
            value.startsWith('repeating-linear-gradient(') ||
            value.startsWith('radial-gradient(') ||
            value.startsWith('repeating-radial-gradient(') ||
            value.startsWith('conic-gradient('));
  }

  static bool isValidBackgroundPositionValue(String value) {
    return value == CENTER ||
        value == LEFT ||
        value == RIGHT ||
        value == TOP ||
        value == BOTTOM ||
        CSSLength.isLength(value) ||
        CSSPercentage.isPercentage(value);
  }

  static resolveBackgroundAttachment(String value) {
    switch (value) {
      case LOCAL:
        return CSSBackgroundAttachmentType.local;
      case FIXED:
        return CSSBackgroundAttachmentType.fixed;
      case SCROLL:
      default:
        return CSSBackgroundAttachmentType.scroll;
    }
  }

  static CSSBackgroundSize resolveBackgroundSize(String value, RenderStyle renderStyle, String propertyName) {
    switch (value) {
      case CONTAIN:
        return CSSBackgroundSize(fit: BoxFit.contain);
      case COVER:
        return CSSBackgroundSize(fit: BoxFit.cover);
      case AUTO:
        return CSSBackgroundSize(fit: BoxFit.none);
      default:
        List<String> values = value.split(splitRegExp);

        if (values.length == 1 && values[0].isNotEmpty) {
          CSSLengthValue width = CSSLength.parseLength(values[0], renderStyle, propertyName, Axis.horizontal);
          return CSSBackgroundSize(
            fit: BoxFit.none,
            width: width,
          );
        } else if (values.length == 2) {
          CSSLengthValue width = CSSLength.parseLength(values[0], renderStyle, propertyName, Axis.horizontal);
          CSSLengthValue height = CSSLength.parseLength(values[1], renderStyle, propertyName, Axis.vertical);
          // Value which is neither length/percentage/auto is considered to be invalid.
          return CSSBackgroundSize(
            fit: BoxFit.none,
            width: width,
            height: height,
          );
        }
        return CSSBackgroundSize(fit: BoxFit.none);
    }
  }

  static resolveBackgroundImage(
      String present, RenderStyle renderStyle, String property, WebFController controller, String? baseHref) {
    // Expand CSS variables inside the background-image string so that
    // values like linear-gradient(..., var(--tw-gradient-stops)) work.
    // Tailwind sets --tw-gradient-stops to a comma-separated list
    // (e.g., "var(--tw-gradient-from), var(--tw-gradient-to)") which
    // must be expanded before parsing function args, otherwise only the
    // first token would be seen and gradients would be dropped.
    String expanded = _expandBackgroundVars(present, renderStyle);
    List<CSSFunctionalNotation> functions = CSSFunction.parseFunction(expanded);
    if (DebugFlags.enableBackgroundLogs) {
      for (final f in functions) {
        if (f.name == 'url') {
          final raw = f.args.isNotEmpty ? f.args[0] : '';
          renderingLogger.finer('[Background] resolve image url raw=$raw baseHref=${baseHref ?? controller.url}');
        } else if (f.name.contains('gradient')) {
          renderingLogger.finer('[Background] resolve gradient ${f.name} args=${f.args.length}');
        }
      }
    }
    return CSSBackgroundImage(functions, renderStyle, controller, baseHref: baseHref);
  }

  // Regex adapted from color var handling to match var(...) including
  // simple nesting cases: var( ... var(...) ... )
  static final RegExp _varFunctionRegExp = RegExp(r'var\(([^()]*\(.*?\)[^()]*)\)|var\(([^()]*)\)');

  // Expand CSS custom properties within a background-image string.
  // This performs textual substitution using the raw variable value
  // (not property-typed resolution) and repeats until no var() remains
  // or a small guard limit is reached.
  static String _expandBackgroundVars(String input, RenderStyle renderStyle) {
    if (!input.contains('var(')) return input;
    String result = input;
    // Limit to avoid infinite loops on pathological input.
    int guard = 0;
    while (result.contains('var(') && guard++ < 8) {
      final original = result;
      result = result.replaceAllMapped(_varFunctionRegExp, (Match match) {
        final String? varString = match[0];
        if (varString == null) return '';
        // Parse the var() expression to get identifier and (optional) fallback.
        final CSSVariable? variable = CSSVariable.tryParse(renderStyle, varString);
        if (variable == null) {
          return '';
        }
        // Track dependency on this variable for backgroundImage recomputation.
        final depKey = '${BACKGROUND_IMAGE}_$input';
        final dynamic raw = renderStyle.getCSSVariable(variable.identifier, depKey);

        if (raw == null || raw == INITIAL) {
          // Use fallback defined in var(--x, <fallback>) if provided.
          final fallback = variable.defaultValue;
          return fallback?.toString() ?? '';
        }
        return raw.toString();
      });
      if (result == original) break;
    }

    return result;
  }

  static CSSBackgroundRepeatType resolveBackgroundRepeat(String value) {
    switch (value) {
      case REPEAT_X:
        return CSSBackgroundRepeatType.repeatX;
      case REPEAT_Y:
        return CSSBackgroundRepeatType.repeatY;
      case NO_REPEAT:
        return CSSBackgroundRepeatType.noRepeat;
      case REPEAT:
      default:
        return CSSBackgroundRepeatType.repeat;
    }
  }

  static CSSBackgroundBoundary resolveBackgroundClip(String value) {
    switch (value) {
      case 'padding-box':
        return CSSBackgroundBoundary.paddingBox;
      case 'content-box':
        return CSSBackgroundBoundary.contentBox;
      case 'text':
        return CSSBackgroundBoundary.text;
      case 'border-box':
      default:
        return CSSBackgroundBoundary.borderBox;
    }
  }

  static CSSBackgroundBoundary resolveBackgroundOrigin(String value) {
    switch (value) {
      case 'border-box':
        return CSSBackgroundBoundary.borderBox;
      case 'content-box':
        return CSSBackgroundBoundary.contentBox;
      case 'padding-box':
      default:
        return CSSBackgroundBoundary.paddingBox;
    }
  }
}

void _applyColorAndStops(
    int start, List<String> args, List<Color> colors, List<double> stops, RenderStyle renderStyle, String propertyName,
    [double? gradientLength]) {
  // colors should more than one, otherwise invalid
  if (args.length - start - 1 > 0) {
    double grow = 1.0 / (args.length - start - 1);
    if (DebugFlags.enableBackgroundLogs) {
      final subset = args.sublist(start);
      renderingLogger.finer('[Background] applyColorStops start=$start args=${subset} gradientLength=${gradientLength?.toStringAsFixed(2) ?? '<none>'}');
    }
    for (int i = start; i < args.length; i++) {
      List<CSSColorStop> colorGradients =
          _parseColorAndStop(args[i].trim(), renderStyle, propertyName, (i - start) * grow, gradientLength);

      for (var colorStop in colorGradients) {
        if (colorStop.color != null) {
          colors.add(colorStop.color!);
          stops.add(colorStop.stop!);
        }
      }
    }
  }
}

List<CSSColorStop> _parseColorAndStop(String src, RenderStyle renderStyle, String propertyName,
    [double? defaultStop, double? gradientLength]) {
  List<String> strings = [];
  List<CSSColorStop> colorGradients = [];

  // rgba may contain space, color should handle special
  if (src.startsWith('rgba(') || src.startsWith('rgb(') || src.startsWith('hsl(') || src.startsWith('hsla(')) {
    // Treat functional color notations as a single token, since their arguments may include spaces.
    // This mirrors the special handling already in place for rgb/rgba and fixes gradients using hsl()/hsla().
    int indexOfEnd = src.lastIndexOf(')');
    if (indexOfEnd != -1) {
      strings.add(src.substring(0, indexOfEnd + 1));
      // If there are trailing tokens after the color function (e.g., "hsl(...) 30%"),
      // keep them by splitting the remainder by spaces and appending.
      if (indexOfEnd + 1 < src.length) {
        final String remainder = src.substring(indexOfEnd + 1).trim();
        if (remainder.isNotEmpty) {
          strings.addAll(remainder.split(' '));
        }
      }
    } else {
      // Fallback: unable to find a closing ')', split by spaces.
      strings = src.split(' ');
    }
  } else {
    strings = src.split(' ');
  }

  if (strings.isNotEmpty) {
    double? stop = defaultStop;
    if (strings.length >= 2) {
      try {
        for (int i = 1; i < strings.length; i++) {
          if (CSSPercentage.isPercentage(strings[i])) {
            stop = CSSPercentage.parsePercentage(strings[i]);
            // Negative percentage is invalid in gradients which will defaults to 0.
            if (stop! < 0) stop = 0;
            if (DebugFlags.enableBackgroundLogs) {
              final CSSColor? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
              final c = color?.value;
              renderingLogger.finer('[Background]   stop token="${strings[i]}" unit=% -> ${stop!.toStringAsFixed(4)} '
                  'color=${c != null ? 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})' : '<invalid>'} src="$src"');
            }
          } else if (CSSAngle.isAngle(strings[i])) {
            stop = CSSAngle.parseAngle(strings[i])! / (math.pi * 2);
            if (DebugFlags.enableBackgroundLogs) {
              final CSSColor? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
              final c = color?.value;
              renderingLogger.finer('[Background]   stop token="${strings[i]}" unit=angle -> ${stop!.toStringAsFixed(4)} '
                  'color=${c != null ? 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})' : '<invalid>'} src="$src"');
            }
          } else if (CSSLength.isLength(strings[i])) {
            if (gradientLength != null) {
              stop = CSSLength.parseLength(strings[i], renderStyle, propertyName).computedValue / gradientLength;
              if (DebugFlags.enableBackgroundLogs) {
                final CSSColor? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
                final c = color?.value;
                renderingLogger.finer('[Background]   stop token="${strings[i]}" unit=length -> ${stop!.toStringAsFixed(4)} '
                    '(length=${CSSLength.parseLength(strings[i], renderStyle, propertyName).computedValue.toStringAsFixed(2)}, '
                    'gradLen=${gradientLength.toStringAsFixed(2)}) '
                    'color=${c != null ? 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})' : '<invalid>'} src="$src"');
              }
            }
          }
          CSSColor? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
          colorGradients.add(CSSColorStop(color?.value, stop));
        }
      } catch (e) {}
    } else {
      CSSColor? color = CSSColor.resolveColor(strings[0], renderStyle, propertyName);
      colorGradients.add(CSSColorStop(color?.value, stop));
      if (DebugFlags.enableBackgroundLogs) {
        final c = color?.value;
        renderingLogger.finer('[Background]   stop default -> ${stop?.toStringAsFixed(4) ?? '<none>'} '
            'color=${c != null ? 'rgba(${c.red},${c.green},${c.blue},${c.opacity.toStringAsFixed(3)})' : '<invalid>'} src="$src"');
      }
    }
  }

  return colorGradients;
}
