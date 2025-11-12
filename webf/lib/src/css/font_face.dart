/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'dart:convert';
import 'package:webf/src/foundation/logger.dart';

final List<String> supportedFonts = [
  'ttc',
  'ttf',
  'otf',
  'data'
];

class _Font {
  String src = '';
  String format = '';
  Uint8List content = Uint8List(0);
  _Font(this.src, this.format);
  _Font.content(Uint8List value) {
    src = '';
    format = 'data';
    content = value;
  }
}

class FontFaceDescriptor {
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final _Font font;
  final double contextId;
  final String? baseHref;
  // Optional owner sheet identifier from bridge (for unregister on sheet removal)
  final int? sheetId;
  bool isLoaded = false;

  FontFaceDescriptor({
    required this.fontFamily,
    required this.fontWeight,
    required this.fontStyle,
    required this.font,
    required this.contextId,
    this.baseHref,
    this.sheetId,
  });
}

class CSSFontFace {
  // Store font face descriptors indexed by font family
  static final Map<String, List<FontFaceDescriptor>> _fontFaceRegistry = {};
  // Track descriptors by stylesheet for unregister
  static final Map<int, List<FontFaceDescriptor>> _sheetRegistry = {};

  // Cache loaded font combinations
  static final Set<String> _loadedFonts = {};

  static String _getFontKey(String fontFamily, FontWeight fontWeight) {
    return '${fontFamily}_${fontWeight.index}';
  }
  static Uri? _resolveFontSource(double contextId, String source, String? base) {
    WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
    // Treat about:* or empty base as absent so we fallback to document URL.
    if (base == null || base.isEmpty || base.startsWith('about:')) {
      base = controller.url;
    }
    try {
      return controller.uriParser!.resolve(Uri.parse(base), Uri.parse(source));
    } catch (_) {
      return null;
    }
  }
  // Parse and store font face rules for lazy loading
  static void resolveFontFaceRules(CSSFontFaceRule fontFaceRule, double contextId, String? baseHref) {
    CSSStyleDeclaration declaration = fontFaceRule.declarations;
    String fontFamily = declaration.getPropertyValue('fontFamily');
    String url = declaration.getPropertyValue('src');
    String fontWeightStr = declaration.getPropertyValue('fontWeight');
    String fontStyleStr = declaration.getPropertyValue('fontStyle');

    if (fontFamily.isNotEmpty && url.isNotEmpty && CSSFunction.isFunction(url)) {
      // Parse font weight
      FontWeight fontWeight = _parseFontWeight(fontWeightStr);

      // Parse font style
      FontStyle fontStyle = fontStyleStr == 'italic' ? FontStyle.italic : FontStyle.normal;

      List<CSSFunctionalNotation> functions = CSSFunction.parseFunction(url);
      List<_Font> fonts = [];

      for(int i = 0; i < functions.length; i ++) {
        CSSFunctionalNotation notation = functions[i];
        if (notation.name == 'url') {
          String tmp_src = notation.args[0];
          tmp_src = removeQuotationMark(tmp_src);

          if (tmp_src.startsWith('data')) {
            String tmp_content = tmp_src.split(';').last;
            if (tmp_content.startsWith('base64')) {
              String base64 = tmp_src.split(',').last;
              try {
                Uint8List decoded = base64Decode(base64);
                if (decoded.isNotEmpty) {
                  fonts.add(_Font.content(decoded));
                }
              } catch(e) {}
            }
          } else {
            String formatFromExt = tmp_src.split('.').last;
            fonts.add(_Font(tmp_src, formatFromExt));
          }
        }
      }

      _Font? targetFont = fonts.firstWhereOrNull((f) {
        return supportedFonts.contains(f.format);
      });

      if (targetFont == null) return;

      // Store font descriptor for lazy loading
      String cleanFontFamily = removeQuotationMark(fontFamily);
      // Prefer property-specific baseHref if present (e.g., from imported CSS)
      String? srcBaseHref = declaration.getPropertyBaseHref('src') ?? baseHref;

      FontFaceDescriptor descriptor = FontFaceDescriptor(
        fontFamily: cleanFontFamily,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        font: targetFont,
        contextId: contextId,
        baseHref: srcBaseHref,
        sheetId: null,
      );

      _fontFaceRegistry.putIfAbsent(cleanFontFamily, () => []).add(descriptor);
    }
  }

  // Bridge API: register a parsed @font-face coming from C++ side.
  // The src string may contain one or more url()/local()/data: entries, we will
  // pick the first supported source similar to resolveFontFaceRules.
  static void registerFromBridge({
    required int sheetId,
    required String fontFamily,
    required String src,
    required String? fontWeight,
    required String? fontStyle,
    required double contextId,
    String? baseHref,
  }) {
    cssLogger.info('[font-face][register] incoming sheet=$sheetId family=$fontFamily weight=${fontWeight ?? 'null'} style=${fontStyle ?? 'null'} base=${baseHref ?? 'null'}');

    if (fontFamily.isEmpty || src.isEmpty) return;

    final String cleanFamily = removeQuotationMark(fontFamily);

    final FontWeight weight = _parseFontWeight(fontWeight);
    final FontStyle style = (fontStyle == 'italic') ? FontStyle.italic : FontStyle.normal;

    List<CSSFunctionalNotation> functions = CSSFunction.parseFunction(src);
    List<_Font> fonts = [];
    for (final CSSFunctionalNotation notation in functions) {
      if (notation.name == 'url' && notation.args.isNotEmpty) {
        String tmpSrc = removeQuotationMark(notation.args[0]);
        cssLogger.fine('[font-face][register] candidate src=$tmpSrc');
        if (tmpSrc.startsWith('data')) {
          // data:...;base64,<...>
          String tmpContent = tmpSrc.split(';').last;
          if (tmpContent.startsWith('base64')) {
            String base64 = tmpSrc.split(',').last;
            try {
              Uint8List decoded = base64Decode(base64);
              if (decoded.isNotEmpty) {
                fonts.add(_Font.content(decoded));
              }
            } catch (_) {}
          }
        } else {
          String formatFromExt = tmpSrc.split('.').last;
          fonts.add(_Font(tmpSrc, formatFromExt));
        }
      }
    }

    _Font? targetFont = fonts.firstWhereOrNull((f) => supportedFonts.contains(f.format));
    if (targetFont == null) {
      cssLogger.warning('[font-face][register] no supported font format in src (sheet=$sheetId family=$cleanFamily)');
      return;
    }

    final descriptor = FontFaceDescriptor(
      fontFamily: cleanFamily,
      fontWeight: weight,
      fontStyle: style,
      font: targetFont,
      contextId: contextId,
      baseHref: baseHref,
      sheetId: sheetId,
    );

    _fontFaceRegistry.putIfAbsent(cleanFamily, () => []).add(descriptor);
    _sheetRegistry.putIfAbsent(sheetId, () => []).add(descriptor);
    cssLogger.info('[font-face][register] stored family=$cleanFamily formats=${fonts.map((f)=>f.format).join(',')} chosen=${targetFont.format} registryFamilies=${_fontFaceRegistry.keys.join('|')}');
  }

  // Bridge API: unregister all font-faces associated with a stylesheet id.
  static void unregisterFromSheet(int sheetId) {
    final list = _sheetRegistry.remove(sheetId);
    if (list == null) return;
    for (final desc in list) {
      final familyList = _fontFaceRegistry[desc.fontFamily];
      if (familyList == null) continue;
      familyList.removeWhere((d) => identical(d, desc) || d.sheetId == sheetId);
      if (familyList.isEmpty) {
        _fontFaceRegistry.remove(desc.fontFamily);
      }
    }
  }

  // Parse font weight from CSS value
  static FontWeight _parseFontWeight(String? weight) {
    if (weight == null || weight.isEmpty) return FontWeight.w400;

    switch (weight) {
      case '100':
      case 'thin':
        return FontWeight.w100;
      case '200':
      case 'extra-light':
      case 'ultra-light':
        return FontWeight.w200;
      case '300':
      case 'light':
        return FontWeight.w300;
      case '400':
      case 'normal':
      case 'regular':
        return FontWeight.w400;
      case '500':
      case 'medium':
        return FontWeight.w500;
      case '600':
      case 'semi-bold':
      case 'demi-bold':
        return FontWeight.w600;
      case '700':
      case 'bold':
        return FontWeight.w700;
      case '800':
      case 'extra-bold':
      case 'ultra-bold':
        return FontWeight.w800;
      case '900':
      case 'black':
      case 'heavy':
        return FontWeight.w900;
      default:
        // Try to parse as number
        try {
          int weightValue = int.parse(weight);
          if (weightValue >= 100 && weightValue <= 900) {
            int index = ((weightValue - 100) / 100).round();
            return FontWeight.values[index];
          }
        } catch (_) {}
        return FontWeight.w400;
    }
  }

  // Track fonts that are currently being loaded to prevent duplicate loads
  static final Map<String, Future<void>> _loadingFonts = {};

  // Load font on demand when it's actually used
  static Future<void> ensureFontLoaded(String fontFamily, FontWeight fontWeight, CSSRenderStyle renderStyle) async {
    String fontKey = _getFontKey(fontFamily, fontWeight);

    // Already loaded
    if (_loadedFonts.contains(fontKey)) {
      return;
    }

    // Already loading - wait for existing load to complete
    if (_loadingFonts.containsKey(fontKey)) {
      return _loadingFonts[fontKey]!;
    }

    // Find matching font descriptor
    List<FontFaceDescriptor>? descriptors = _fontFaceRegistry[fontFamily];
    if (descriptors == null || descriptors.isEmpty) {
      cssLogger.warning('[font-face][ensure] no descriptors for family="$fontFamily". Known families=${_fontFaceRegistry.keys.join('|')}');
      return;
    }

    // Find exact weight match or closest fallback
    FontFaceDescriptor? descriptor = _findBestMatchingDescriptor(descriptors, fontWeight);

    if (descriptor == null) {
      cssLogger.warning('[font-face][ensure] no matching descriptor for weight=${fontWeight.index}. availableWeights=${descriptors.map((d)=>d.fontWeight.index).join(',')}');
      return;
    }
    if (descriptor.isLoaded) {
      return;
    }

    // Mark as loaded immediately to prevent race conditions
    descriptor.isLoaded = true;
    _loadedFonts.add(fontKey);

    // Also mark the actual font weight as loaded to prevent duplicate loads
    // when the exact weight is requested later
    String actualFontKey = _getFontKey(descriptor.fontFamily, descriptor.fontWeight);
    _loadedFonts.add(actualFontKey);

    // Start loading and track the future
    final loadFuture = _loadFont(descriptor);
    _loadingFonts[fontKey] = loadFuture;
    _loadingFonts[actualFontKey] = loadFuture;

    try {
      await loadFuture;
    } finally {
      // Remove from loading map when done
      _loadingFonts.remove(fontKey);
      if (actualFontKey != fontKey) {
        _loadingFonts.remove(actualFontKey);
      }
      renderStyle.markNeedsLayout();
    }
  }

  // Separate method to handle the actual font loading
  static Future<void> _loadFont(FontFaceDescriptor descriptor) async {
    try {
      if (descriptor.font.content.isNotEmpty) {
        // Load from memory
        Uint8List content = descriptor.font.content;
        Future<ByteData> bytes = Future.value(ByteData.sublistView(content));
        FontLoader loader = FontLoader(descriptor.fontFamily);
        loader.addFont(bytes);
        await loader.load();
        SchedulerBinding.instance.scheduleFrame();
      } else {
        // Load from URL
        Uri? uri = _resolveFontSource(descriptor.contextId, descriptor.font.src, descriptor.baseHref);
        if (uri == null) return;

        final WebFController? controller = WebFController.getControllerOfJSContextId(descriptor.contextId);
        if (controller == null) return;

        WebFBundle bundle = controller.getPreloadBundleFromUrl(uri.toString()) ?? WebFBundle.fromUrl(uri.toString());
        await bundle.resolve(baseUrl: controller.url, uriParser: controller.uriParser);
        await bundle.obtainData(controller.view.contextId);

        FontLoader loader = FontLoader(descriptor.fontFamily);
        Future<ByteData> bytes = Future.value(bundle.data?.buffer.asByteData());
        loader.addFont(bytes);
        await loader.load();
        SchedulerBinding.instance.scheduleFrame();
      }
    } catch(e, stack) {
      // On error, mark as not loaded so it can be retried
      descriptor.isLoaded = false;
      _loadedFonts.remove(_getFontKey(descriptor.fontFamily, descriptor.fontWeight));
      print('Failed to load font: $e\n$stack');
    }
  }

  // Find best matching font descriptor based on weight
  static FontFaceDescriptor? _findBestMatchingDescriptor(List<FontFaceDescriptor> descriptors, FontWeight targetWeight) {
    // First try exact match
    FontFaceDescriptor? exactMatch = descriptors.firstWhereOrNull(
      (d) => d.fontWeight == targetWeight
    );
    if (exactMatch != null) return exactMatch;

    // If not found, use CSS font-weight fallback algorithm
    int targetIndex = targetWeight.index;

    // For weights 400-500, prefer lighter weights
    if (targetIndex >= 3 && targetIndex <= 4) {
      // Try weights in order: exact -> lighter -> heavier
      for (int i = targetIndex; i >= 0; i--) {
        FontFaceDescriptor? match = descriptors.firstWhereOrNull(
          (d) => d.fontWeight.index == i
        );
        if (match != null) return match;
      }
      for (int i = targetIndex + 1; i < FontWeight.values.length; i++) {
        FontFaceDescriptor? match = descriptors.firstWhereOrNull(
          (d) => d.fontWeight.index == i
        );
        if (match != null) return match;
      }
    } else {
      // For other weights, prefer heavier weights
      for (int i = targetIndex; i < FontWeight.values.length; i++) {
        FontFaceDescriptor? match = descriptors.firstWhereOrNull(
          (d) => d.fontWeight.index == i
        );
        if (match != null) return match;
      }
      for (int i = targetIndex - 1; i >= 0; i--) {
        FontFaceDescriptor? match = descriptors.firstWhereOrNull(
          (d) => d.fontWeight.index == i
        );
        if (match != null) return match;
      }
    }

    // Return any available font as last resort
    return descriptors.firstOrNull;
  }

  // Clear font cache (useful for testing or memory management)
  static void clearFontCache() {
    _fontFaceRegistry.clear();
    _sheetRegistry.clear();
    _loadedFonts.clear();
  }
}
