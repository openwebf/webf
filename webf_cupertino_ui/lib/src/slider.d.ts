/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-cupertino-slider>
 * iOS-style continuous or stepped slider.
 */
interface FlutterCupertinoSliderProperties {
  /**
   * Current value of the slider.
   * Default: 0.0.
   */
  val?: double;

  /**
   * Minimum value of the slider range.
   * Default: 0.0.
   */
  min?: double;

  /**
   * Maximum value of the slider range.
   * Default: 100.0.
   */
  max?: double;

  /**
   * Number of discrete divisions between min and max.
   * When omitted, the slider is continuous.
   */
  step?: int;

  /**
   * Whether the slider is disabled.
   * Default: false.
   */
  disabled?: boolean;
}

interface FlutterCupertinoSliderMethods {
  /** Get the current value. */
  getValue(): double;
  /** Set the current value (clamped between min and max). */
  setValue(val: double): void;
}

interface FlutterCupertinoSliderEvents {
  /** Fired whenever the slider value changes. detail = value. */
  change: CustomEvent<double>;
  /** Fired when the user starts interacting with the slider. */
  changestart: CustomEvent<double>;
  /** Fired when the user stops interacting with the slider. */
  changeend: CustomEvent<double>;
}
