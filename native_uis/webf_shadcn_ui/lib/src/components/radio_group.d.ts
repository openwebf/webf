/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-radio-group>
 *
 * Container for radio button groups.
 *
 * @example
 * ```html
 * <flutter-shadcn-radio-group value="option1" onchange="handleChange(event)">
 *   <flutter-shadcn-radio-group-item value="option1">Option 1</flutter-shadcn-radio-group-item>
 *   <flutter-shadcn-radio-group-item value="option2">Option 2</flutter-shadcn-radio-group-item>
 * </flutter-shadcn-radio-group>
 * ```
 */
interface FlutterShadcnRadioGroupProperties {
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
 * Events emitted by <flutter-shadcn-radio-group>
 */
interface FlutterShadcnRadioGroupEvents {
  /** Fired when selection changes. detail.value contains the selected value. */
  change: CustomEvent<{ value: string }>;
}

/**
 * Properties for <flutter-shadcn-radio-group-item>
 *
 * Individual radio button option.
 */
interface FlutterShadcnRadioGroupItemProperties {
  /**
   * Value of this radio option.
   */
  value: string;

  /**
   * Disable this specific radio item.
   */
  disabled?: boolean;
}

interface FlutterShadcnRadioGroupItemEvents {}
