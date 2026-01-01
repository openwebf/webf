/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-sliding-segmented-control>
 * iOS-style segmented control with a sliding thumb.
 */
interface FlutterCupertinoSlidingSegmentedControlProperties {
  /**
   * Zero-based index of the selected segment.
   * Default: 0. Values outside range are clamped.
   */
  'current-index'?: int;

  /**
   * Background color of the segmented control track.
   * Hex string: '#RRGGBB' or '#AARRGGBB'.
   */
  'background-color'?: string;

  /**
   * Color of the sliding thumb.
   * Hex string: '#RRGGBB' or '#AARRGGBB'.
   */
  'thumb-color'?: string;
}

interface FlutterCupertinoSlidingSegmentedControlEvents {
  /**
   * Fired when the selected segment changes.
   * detail = zero-based selected index.
   */
  change: CustomEvent<number>;
}

/**
 * Segment item for <flutter-cupertino-sliding-segmented-control>.
 * Acts as a logical segment with a title.
 */
interface FlutterCupertinoSlidingSegmentedControlItemProperties {
  /**
   * Text label shown for this segment.
   */
  title?: string;
}

interface FlutterCupertinoSlidingSegmentedControlItemEvents {}
