/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Global type definitions for webf_shadcn_ui components.
 */

/**
 * Available color schemes for shadcn_ui theming.
 */
type ShadcnColorScheme =
  | 'blue'
  | 'gray'
  | 'green'
  | 'neutral'
  | 'orange'
  | 'red'
  | 'rose'
  | 'slate'
  | 'stone'
  | 'violet'
  | 'yellow'
  | 'zinc';

/**
 * Brightness mode for theming.
 */
type ShadcnBrightness = 'light' | 'dark' | 'system';

/**
 * Common button variants used across shadcn components.
 */
type ShadcnButtonVariant =
  | 'default'
  | 'secondary'
  | 'destructive'
  | 'outline'
  | 'ghost'
  | 'link';

/**
 * Common button sizes.
 */
type ShadcnButtonSize = 'default' | 'sm' | 'lg' | 'icon';

/**
 * Alert variants.
 */
type ShadcnAlertVariant = 'default' | 'destructive';

/**
 * Badge variants.
 */
type ShadcnBadgeVariant = 'default' | 'secondary' | 'destructive' | 'outline';

/**
 * Input types.
 */
type ShadcnInputType =
  | 'text'
  | 'password'
  | 'email'
  | 'number'
  | 'tel'
  | 'url'
  | 'search';

/**
 * Dialog/Sheet side positions.
 */
type ShadcnSide = 'top' | 'bottom' | 'left' | 'right';

/**
 * Popover/Tooltip placement positions.
 */
type ShadcnPlacement =
  | 'top'
  | 'top-start'
  | 'top-end'
  | 'bottom'
  | 'bottom-start'
  | 'bottom-end'
  | 'left'
  | 'left-start'
  | 'left-end'
  | 'right'
  | 'right-start'
  | 'right-end';

/**
 * Common orientation for components.
 */
type ShadcnOrientation = 'horizontal' | 'vertical';

/**
 * Calendar selection mode.
 */
type ShadcnCalendarMode = 'single' | 'multiple' | 'range';

/**
 * Date picker mode.
 */
type ShadcnDatePickerMode = 'single' | 'range';

/**
 * Progress indicator variant.
 */
type ShadcnProgressVariant = 'default' | 'indeterminate';
