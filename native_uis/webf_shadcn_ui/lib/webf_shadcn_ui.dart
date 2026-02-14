/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/// shadcn/ui style components for WebF applications.
///
/// This package provides shadcn_ui Flutter widgets wrapped as HTML custom elements
/// for use in WebF applications.
///
/// ## Quick Start
///
/// 1. Install the package in your Flutter app
/// 2. Call [installWebFShadcnUI] in your main function:
///
/// ```dart
/// import 'package:webf_shadcn_ui/webf_shadcn_ui.dart';
///
/// void main() {
///   installWebFShadcnUI();
///   runApp(MyApp());
/// }
/// ```
///
/// 3. Use the components in your HTML:
///
/// ```html
/// <flutter-shadcn-theme color-scheme="blue" brightness="light">
///   <flutter-shadcn-button variant="default">
///     Click me
///   </flutter-shadcn-button>
/// </flutter-shadcn-theme>
/// ```
library webf_shadcn_ui;

import 'package:webf/webf.dart';

// Theme
export 'src/theme/theme.dart';
export 'src/theme/colors.dart';

// Form Controls
export 'src/components/button.dart';
export 'src/components/icon_button.dart';
export 'src/components/input.dart';
export 'src/components/textarea.dart';
export 'src/components/checkbox.dart';
export 'src/components/radio.dart';
export 'src/components/switch.dart';
export 'src/components/select.dart';
export 'src/components/slider.dart';
export 'src/components/combobox.dart';
export 'src/components/form.dart';
export 'src/components/input_otp.dart';

// Display Components
export 'src/components/card.dart';
export 'src/components/alert.dart';
export 'src/components/badge.dart';
export 'src/components/avatar.dart';
export 'src/components/toast.dart';
export 'src/components/tooltip.dart';
export 'src/components/progress.dart';
export 'src/components/separator.dart';

// Navigation/Layout
export 'src/components/tabs.dart';
export 'src/components/dialog.dart';
export 'src/components/sheet.dart';
export 'src/components/popover.dart';
export 'src/components/breadcrumb.dart';
export 'src/components/dropdown_menu.dart';
export 'src/components/context_menu.dart';
export 'src/components/menubar.dart';

// Data Display
export 'src/components/table.dart';
export 'src/components/accordion.dart';
export 'src/components/calendar.dart';
export 'src/components/date_picker.dart';
export 'src/components/time_picker.dart';
export 'src/components/image.dart';

// Advanced Components
export 'src/components/scroll_area.dart';
export 'src/components/skeleton.dart';
export 'src/components/collapsible.dart';

// Import all components for registration
import 'src/theme/theme.dart';
import 'src/components/button.dart';
import 'src/components/icon_button.dart';
import 'src/components/input.dart';
import 'src/components/textarea.dart';
import 'src/components/checkbox.dart';
import 'src/components/radio.dart';
import 'src/components/switch.dart';
import 'src/components/select.dart';
import 'src/components/slider.dart';
import 'src/components/combobox.dart';
import 'src/components/form.dart';
import 'src/components/input_otp.dart';
import 'src/components/card.dart';
import 'src/components/alert.dart';
import 'src/components/badge.dart';
import 'src/components/avatar.dart';
import 'src/components/toast.dart';
import 'src/components/tooltip.dart';
import 'src/components/progress.dart';
import 'src/components/separator.dart';
import 'src/components/tabs.dart';
import 'src/components/dialog.dart';
import 'src/components/sheet.dart';
import 'src/components/popover.dart';
import 'src/components/breadcrumb.dart';
import 'src/components/dropdown_menu.dart';
import 'src/components/context_menu.dart';
import 'src/components/menubar.dart';
import 'src/components/table.dart';
import 'src/components/accordion.dart';
import 'src/components/calendar.dart';
import 'src/components/date_picker.dart';
import 'src/components/time_picker.dart';
import 'src/components/image.dart';
import 'src/components/scroll_area.dart';
import 'src/components/skeleton.dart';
import 'src/components/collapsible.dart';

/// Installs all shadcn UI custom elements for WebF.
///
/// Call this function in your main() before running your WebF application
/// to register all available shadcn-style custom elements.
///
/// Example:
/// ```dart
/// void main() {
///   installWebFShadcnUI();
///   runApp(MyApp());
/// }
/// ```
void installWebFShadcnUI() {
  // Theme
  WebF.defineCustomElement(
      'flutter-shadcn-theme', (context) => FlutterShadcnTheme(context));

  // Form Controls
  WebF.defineCustomElement(
      'flutter-shadcn-button', (context) => FlutterShadcnButton(context));
  WebF.defineCustomElement(
      'flutter-shadcn-icon-button', (context) => FlutterShadcnIconButton(context));
  WebF.defineCustomElement(
      'flutter-shadcn-input', (context) => FlutterShadcnInput(context));
  WebF.defineCustomElement(
      'flutter-shadcn-textarea', (context) => FlutterShadcnTextarea(context));
  WebF.defineCustomElement(
      'flutter-shadcn-checkbox', (context) => FlutterShadcnCheckbox(context));
  WebF.defineCustomElement(
      'flutter-shadcn-radio', (context) => FlutterShadcnRadio(context));
  WebF.defineCustomElement(
      'flutter-shadcn-radio-item', (context) => FlutterShadcnRadioItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-switch', (context) => FlutterShadcnSwitch(context));
  WebF.defineCustomElement(
      'flutter-shadcn-select', (context) => FlutterShadcnSelect(context));
  WebF.defineCustomElement(
      'flutter-shadcn-select-item', (context) => FlutterShadcnSelectItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-select-group', (context) => FlutterShadcnSelectGroup(context));
  WebF.defineCustomElement(
      'flutter-shadcn-select-separator', (context) => FlutterShadcnSelectSeparator(context));
  WebF.defineCustomElement(
      'flutter-shadcn-slider', (context) => FlutterShadcnSlider(context));
  WebF.defineCustomElement(
      'flutter-shadcn-combobox', (context) => FlutterShadcnCombobox(context));
  WebF.defineCustomElement(
      'flutter-shadcn-combobox-item', (context) => FlutterShadcnComboboxItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-form', (context) => FlutterShadcnForm(context));
  WebF.defineCustomElement(
      'flutter-shadcn-form-field', (context) => FlutterShadcnFormField(context));
  WebF.defineCustomElement(
      'flutter-shadcn-form-label', (context) => FlutterShadcnFormLabel(context));
  WebF.defineCustomElement(
      'flutter-shadcn-form-description', (context) => FlutterShadcnFormDescription(context));
  WebF.defineCustomElement(
      'flutter-shadcn-form-message', (context) => FlutterShadcnFormMessage(context));
  WebF.defineCustomElement(
      'flutter-shadcn-input-otp', (context) => FlutterShadcnInputOtp(context));
  WebF.defineCustomElement(
      'flutter-shadcn-input-otp-group', (context) => FlutterShadcnInputOtpGroup(context));
  WebF.defineCustomElement(
      'flutter-shadcn-input-otp-slot', (context) => FlutterShadcnInputOtpSlot(context));
  WebF.defineCustomElement(
      'flutter-shadcn-input-otp-separator', (context) => FlutterShadcnInputOtpSeparator(context));

  // Display Components
  WebF.defineCustomElement(
      'flutter-shadcn-card', (context) => FlutterShadcnCard(context));
  WebF.defineCustomElement(
      'flutter-shadcn-card-header', (context) => FlutterShadcnCardHeader(context));
  WebF.defineCustomElement(
      'flutter-shadcn-card-title', (context) => FlutterShadcnCardTitle(context));
  WebF.defineCustomElement(
      'flutter-shadcn-card-description', (context) => FlutterShadcnCardDescription(context));
  WebF.defineCustomElement(
      'flutter-shadcn-card-content', (context) => FlutterShadcnCardContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-card-footer', (context) => FlutterShadcnCardFooter(context));
  WebF.defineCustomElement(
      'flutter-shadcn-alert', (context) => FlutterShadcnAlert(context));
  WebF.defineCustomElement(
      'flutter-shadcn-alert-title', (context) => FlutterShadcnAlertTitle(context));
  WebF.defineCustomElement(
      'flutter-shadcn-alert-description', (context) => FlutterShadcnAlertDescription(context));
  WebF.defineCustomElement(
      'flutter-shadcn-badge', (context) => FlutterShadcnBadge(context));
  WebF.defineCustomElement(
      'flutter-shadcn-avatar', (context) => FlutterShadcnAvatar(context));
  WebF.defineCustomElement(
      'flutter-shadcn-toast', (context) => FlutterShadcnToast(context));
  WebF.defineCustomElement(
      'flutter-shadcn-tooltip', (context) => FlutterShadcnTooltip(context));
  WebF.defineCustomElement(
      'flutter-shadcn-progress', (context) => FlutterShadcnProgress(context));
  WebF.defineCustomElement(
      'flutter-shadcn-separator', (context) => FlutterShadcnSeparator(context));

  // Navigation/Layout
  WebF.defineCustomElement(
      'flutter-shadcn-tabs', (context) => FlutterShadcnTabs(context));
  WebF.defineCustomElement(
      'flutter-shadcn-tabs-list', (context) => FlutterShadcnTabsList(context));
  WebF.defineCustomElement(
      'flutter-shadcn-tabs-trigger', (context) => FlutterShadcnTabsTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-tabs-content', (context) => FlutterShadcnTabsContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dialog', (context) => FlutterShadcnDialog(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dialog-header', (context) => FlutterShadcnDialogHeader(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dialog-title', (context) => FlutterShadcnDialogTitle(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dialog-description', (context) => FlutterShadcnDialogDescription(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dialog-content', (context) => FlutterShadcnDialogContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dialog-footer', (context) => FlutterShadcnDialogFooter(context));
  WebF.defineCustomElement(
      'flutter-shadcn-sheet', (context) => FlutterShadcnSheet(context));
  WebF.defineCustomElement(
      'flutter-shadcn-sheet-header', (context) => FlutterShadcnSheetHeader(context));
  WebF.defineCustomElement(
      'flutter-shadcn-sheet-title', (context) => FlutterShadcnSheetTitle(context));
  WebF.defineCustomElement(
      'flutter-shadcn-sheet-description', (context) => FlutterShadcnSheetDescription(context));
  WebF.defineCustomElement(
      'flutter-shadcn-sheet-content', (context) => FlutterShadcnSheetContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-sheet-footer', (context) => FlutterShadcnSheetFooter(context));
  WebF.defineCustomElement(
      'flutter-shadcn-popover', (context) => FlutterShadcnPopover(context));
  WebF.defineCustomElement(
      'flutter-shadcn-popover-trigger', (context) => FlutterShadcnPopoverTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-popover-content', (context) => FlutterShadcnPopoverContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb', (context) => FlutterShadcnBreadcrumb(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-list', (context) => FlutterShadcnBreadcrumbList(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-item', (context) => FlutterShadcnBreadcrumbItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-link', (context) => FlutterShadcnBreadcrumbLink(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-page', (context) => FlutterShadcnBreadcrumbPage(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-separator', (context) => FlutterShadcnBreadcrumbSeparator(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-ellipsis', (context) => FlutterShadcnBreadcrumbEllipsis(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-dropdown', (context) => FlutterShadcnBreadcrumbDropdown(context));
  WebF.defineCustomElement(
      'flutter-shadcn-breadcrumb-dropdown-item', (context) => FlutterShadcnBreadcrumbDropdownItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dropdown-menu', (context) => FlutterShadcnDropdownMenu(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dropdown-menu-trigger', (context) => FlutterShadcnDropdownMenuTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dropdown-menu-content', (context) => FlutterShadcnDropdownMenuContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dropdown-menu-item', (context) => FlutterShadcnDropdownMenuItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dropdown-menu-separator', (context) => FlutterShadcnDropdownMenuSeparator(context));
  WebF.defineCustomElement(
      'flutter-shadcn-dropdown-menu-label', (context) => FlutterShadcnDropdownMenuLabel(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu', (context) => FlutterShadcnContextMenu(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-trigger', (context) => FlutterShadcnContextMenuTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-content', (context) => FlutterShadcnContextMenuContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-item', (context) => FlutterShadcnContextMenuItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-separator', (context) => FlutterShadcnContextMenuSeparator(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-label', (context) => FlutterShadcnContextMenuLabel(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-sub', (context) => FlutterShadcnContextMenuSub(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-sub-trigger', (context) => FlutterShadcnContextMenuSubTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-sub-content', (context) => FlutterShadcnContextMenuSubContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-checkbox-item', (context) => FlutterShadcnContextMenuCheckboxItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-radio-group', (context) => FlutterShadcnContextMenuRadioGroup(context));
  WebF.defineCustomElement(
      'flutter-shadcn-context-menu-radio-item', (context) => FlutterShadcnContextMenuRadioItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar', (context) => FlutterShadcnMenubar(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-menu', (context) => FlutterShadcnMenubarMenu(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-trigger', (context) => FlutterShadcnMenubarTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-content', (context) => FlutterShadcnMenubarContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-item', (context) => FlutterShadcnMenubarItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-separator', (context) => FlutterShadcnMenubarSeparator(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-label', (context) => FlutterShadcnMenubarLabel(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-sub', (context) => FlutterShadcnMenubarSub(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-sub-trigger', (context) => FlutterShadcnMenubarSubTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-sub-content', (context) => FlutterShadcnMenubarSubContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-checkbox-item', (context) => FlutterShadcnMenubarCheckboxItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-radio-group', (context) => FlutterShadcnMenubarRadioGroup(context));
  WebF.defineCustomElement(
      'flutter-shadcn-menubar-radio-item', (context) => FlutterShadcnMenubarRadioItem(context));

  // Data Display
  WebF.defineCustomElement(
      'flutter-shadcn-table', (context) => FlutterShadcnTable(context));
  WebF.defineCustomElement(
      'flutter-shadcn-table-header', (context) => FlutterShadcnTableHeader(context));
  WebF.defineCustomElement(
      'flutter-shadcn-table-body', (context) => FlutterShadcnTableBody(context));
  WebF.defineCustomElement(
      'flutter-shadcn-table-row', (context) => FlutterShadcnTableRow(context));
  WebF.defineCustomElement(
      'flutter-shadcn-table-head', (context) => FlutterShadcnTableHead(context));
  WebF.defineCustomElement(
      'flutter-shadcn-table-cell', (context) => FlutterShadcnTableCell(context));
  WebF.defineCustomElement(
      'flutter-shadcn-accordion', (context) => FlutterShadcnAccordion(context));
  WebF.defineCustomElement(
      'flutter-shadcn-accordion-item', (context) => FlutterShadcnAccordionItem(context));
  WebF.defineCustomElement(
      'flutter-shadcn-accordion-trigger', (context) => FlutterShadcnAccordionTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-accordion-content', (context) => FlutterShadcnAccordionContent(context));
  WebF.defineCustomElement(
      'flutter-shadcn-calendar', (context) => FlutterShadcnCalendar(context));
  WebF.defineCustomElement(
      'flutter-shadcn-date-picker', (context) => FlutterShadcnDatePicker(context));
  WebF.defineCustomElement(
      'flutter-shadcn-time-picker', (context) => FlutterShadcnTimePicker(context));
  WebF.defineCustomElement(
      'flutter-shadcn-image', (context) => FlutterShadcnImage(context));

  // Advanced Components
  WebF.defineCustomElement(
      'flutter-shadcn-scroll-area', (context) => FlutterShadcnScrollArea(context));
  WebF.defineCustomElement(
      'flutter-shadcn-skeleton', (context) => FlutterShadcnSkeleton(context));
  WebF.defineCustomElement(
      'flutter-shadcn-collapsible', (context) => FlutterShadcnCollapsible(context));
  WebF.defineCustomElement(
      'flutter-shadcn-collapsible-trigger', (context) => FlutterShadcnCollapsibleTrigger(context));
  WebF.defineCustomElement(
      'flutter-shadcn-collapsible-content', (context) => FlutterShadcnCollapsibleContent(context));
}
