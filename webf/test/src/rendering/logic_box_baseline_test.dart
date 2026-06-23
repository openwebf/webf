/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Repro for the flow-layout baseline crash on a detached render box.
 *
 * RenderStyle.flushLayout() lays out a render subtree that is NOT attached to a
 * pipeline owner (owner == null) via performLayout() — this happens during
 * prerender (not yet mounted) and during a FlutterBoost container pop (the WebF
 * renderer tree is still attached but detached from the Flutter pipeline) when
 * JS reads geometry like offsetTop. During that layout, RenderFlowLayout's
 * cross-axis baseline computation calls LogicInlineBox.getChildAscent, which
 * asks the child for getDistanceToBaseline. That method's debug assert reads
 * `owner!` (box.dart) — for a detached render box `owner` is null, so it throws
 * "Null check operator used on a null value".
 */

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/rendering.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getChildAscent falls back instead of crashing for a detached child render box', () {
    // A render box that is laid out (hasSize == true, debugNeedsLayout == false)
    // but never attached to a pipeline (owner == null) — exactly the state
    // flushLayout's performLayout branch operates on.
    final RenderConstrainedBox box =
        RenderConstrainedBox(additionalConstraints: const BoxConstraints.tightFor(width: 10, height: 20));
    box.layout(const BoxConstraints.tightFor(width: 10, height: 20));

    expect(box.hasSize, isTrue);
    expect(box.debugNeedsLayout, isFalse);
    expect(box.owner, isNull, reason: 'box must be detached to reproduce the owner! null check');

    final LogicInlineBox inline = LogicInlineBox(renderObject: box);

    // Before the fix: box.getDistanceToBaseline()'s assert reads owner! -> throws
    // "Null check operator used on a null value".
    // After the fix: the baseline query is skipped for a detached child and the
    // margin-box fallback (marginTop + height) is returned.
    final double ascent = inline.getChildAscent(0, 0);
    expect(ascent, 20);
  });
}
