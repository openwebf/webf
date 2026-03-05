/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-input-otp>
 *
 * Accessible one-time password input with individual character slots.
 *
 * @example
 * ```html
 * <flutter-shadcn-input-otp maxlength="6" onchange="handleChange(event)">
 *   <flutter-shadcn-input-otp-group>
 *     <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
 *     <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
 *     <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
 *   </flutter-shadcn-input-otp-group>
 *   <flutter-shadcn-input-otp-separator></flutter-shadcn-input-otp-separator>
 *   <flutter-shadcn-input-otp-group>
 *     <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
 *     <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
 *     <flutter-shadcn-input-otp-slot></flutter-shadcn-input-otp-slot>
 *   </flutter-shadcn-input-otp-group>
 * </flutter-shadcn-input-otp>
 * ```
 */
interface FlutterShadcnInputOtpProperties {
  /**
   * Maximum number of characters (required).
   */
  maxlength: string;

  /**
   * Current OTP value.
   */
  value?: string;

  /**
   * Disable the input.
   */
  disabled?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-input-otp>
 */
interface FlutterShadcnInputOtpEvents {
  /** Fired when the OTP value changes. */
  change: Event;
  /** Fired when all slots are filled. */
  complete: Event;
}

/**
 * Properties for <flutter-shadcn-input-otp-group>
 *
 * Groups OTP slots together visually.
 */
interface FlutterShadcnInputOtpGroupProperties {}

interface FlutterShadcnInputOtpGroupEvents {}

/**
 * Properties for <flutter-shadcn-input-otp-slot>
 *
 * Individual character slot managed by the parent input.
 */
interface FlutterShadcnInputOtpSlotProperties {}

interface FlutterShadcnInputOtpSlotEvents {}

/**
 * Properties for <flutter-shadcn-input-otp-separator>
 *
 * Visual separator between OTP groups.
 */
interface FlutterShadcnInputOtpSeparatorProperties {}

interface FlutterShadcnInputOtpSeparatorEvents {}
