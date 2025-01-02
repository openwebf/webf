/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

class TextMetricsData extends Struct {
  @Double()
  external double width;
  // @Double()
  // external double actualBoundingBoxLeft;
  // @Double()
  // external double actualBoundingBoxRight;
  // @Double()
  // external double fontBoundingBoxAscent;
  // @Double()
  // external double fontBoundingBoxDescent;
  // @Double()
  // external double actualBoundingBoxAscent;
  // @Double()
  // external double actualBoundingBoxDescent;
  // @Double()
  // external double emHeightAscent;
  // @Double()
  // external double emHeightDescent;
  // @Double()
  // external double hangingBaseline;
  // @Double()
  // external double alphabeticBaseline;
  // @Double()
  // external double ideographicBaseline;
}

class TextMetrics extends StaticBindingObject {
  final double width;
  // final double actualBoundingBoxLeft;
  // final double actualBoundingBoxRight;
  //
  // final double fontBoundingBoxAscent;
  // final double fontBoundingBoxDescent;
  // final double actualBoundingBoxAscent;
  // final double actualBoundingBoxDescent;
  // final double emHeightAscent;
  // final double emHeightDescent;
  // final double hangingBaseline;
  // final double alphabeticBaseline;
  // final double ideographicBaseline;

  TextMetrics({
    required BindingContext context,
    required this.width,
    // required this.actualBoundingBoxLeft,
    // required this.actualBoundingBoxRight,
    //
    // required this.fontBoundingBoxAscent,
    // required this.fontBoundingBoxDescent,
    // required this.actualBoundingBoxAscent,
    // required this.actualBoundingBoxDescent,
    // required this.emHeightAscent,
    // required this.emHeightDescent,
    // required this.hangingBaseline,
    // required this.alphabeticBaseline,
    // required this.ideographicBaseline,
  })
      : _pointer = context.pointer,
        super(context);

  @override
  Pointer<Void> buildExtraNativeData() {
    Pointer<TextMetricsData> extraData = malloc.allocate(sizeOf<TextMetricsData>());
    extraData.ref.width = width;
    // extraData.ref.actualBoundingBoxLeft = actualBoundingBoxLeft;
    // extraData.ref.actualBoundingBoxRight = actualBoundingBoxRight;
    // extraData.ref.fontBoundingBoxAscent = fontBoundingBoxAscent;
    // extraData.ref.fontBoundingBoxDescent = fontBoundingBoxDescent;
    // extraData.ref.actualBoundingBoxAscent = actualBoundingBoxAscent;
    // extraData.ref.actualBoundingBoxDescent = actualBoundingBoxDescent;
    // extraData.ref.emHeightAscent = emHeightAscent;
    // extraData.ref.emHeightDescent = emHeightDescent;
    // extraData.ref.hangingBaseline = hangingBaseline;
    // extraData.ref.alphabeticBaseline = alphabeticBaseline;
    // extraData.ref.emHeightDescent = emHeightDescent;
    // extraData.ref.ideographicBaseline = ideographicBaseline;
    return extraData.cast<Void>();
  }

  final Pointer<NativeBindingObject> _pointer;

  @override
  get pointer => _pointer;

  Map<String, double> toJSON() {
    return {
      'width': width,
      // 'actualBoundingBoxLeft' : actualBoundingBoxLeft,
      // 'actualBoundingBoxRight' : actualBoundingBoxRight,
      // 'fontBoundingBoxAscent' : fontBoundingBoxAscent,
      // 'fontBoundingBoxDescent' : fontBoundingBoxDescent,
      // 'actualBoundingBoxAscent' : actualBoundingBoxAscent,
      // 'actualBoundingBoxDescent' : actualBoundingBoxDescent,
      // 'emHeightAscent' : emHeightAscent,
      // 'emHeightDescent' : emHeightDescent,
      // 'hangingBaseline' : hangingBaseline,
      // 'alphabeticBaseline' : alphabeticBaseline,
      // 'emHeightDescent' : emHeightDescent,
      // 'ideographicBaseline' : ideographicBaseline,
    };
  }
}
