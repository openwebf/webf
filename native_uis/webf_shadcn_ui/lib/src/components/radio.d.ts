/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-radio>
 *
 * Container for radio button groups.
 *
 * @example
 * ```html
 * <flutter-shadcn-radio value="option1" onchange="handleChange(event)">
 *   <flutter-shadcn-radio-item value="option1">Option 1</flutter-shadcn-radio-item>
 *   <flutter-shadcn-radio-item value="option2">Option 2</flutter-shadcn-radio-item>
 * </flutter-shadcn-radio>
 * ```
 */
interface FlutterShadcnRadioProperties {
  /**
   * Currently selected value.
   */
  value?: string;

  /**
   * Disable all radio items.
   */
  disabled?: boolean;

  /**
   * Orientation of the radio group.
   * Options: 'horizontal', 'vertical'
   * Default: 'vertical'
   */
  orientation?: string;
}

/**
 * Events emitted by <flutter-shadcn-radio>
 */
interface FlutterShadcnRadioEvents {
  /** Fired when selection changes. */
  change: Event;
}

/**
 * Properties for <flutter-shadcn-radio-item>
 *
 * Individual radio button option.
 */
interface FlutterShadcnRadioItemProperties {
  /**
   * Value of this radio option.
   */
  value: string;

  /**
   * Disable this specific radio item.
   */
  disabled?: boolean;
}

interface FlutterShadcnRadioItemEvents {}
