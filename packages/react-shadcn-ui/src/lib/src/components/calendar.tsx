import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
/**
 * Detail for calendar change event.
 */
interface FlutterShadcnCalendarChangeEventDetail {
  /**
   * The selected value.
   * - For single mode: ISO date string (YYYY-MM-DD) or null
   * - For multiple mode: Comma-separated ISO date strings
   * - For range mode: Comma-separated start and end dates
   */
  value: string | null;
}
export interface FlutterShadcnCalendarProps {
  /**
   * Selection mode.
   * - 'single': Select one date
   * - 'multiple': Select multiple dates (value is comma-separated)
   * - 'range': Select a date range (value is start,end)
   * @default 'single'
   */
  mode?: 'single' | 'multiple' | 'range';
  /**
   * Selected date(s) in ISO format (YYYY-MM-DD).
   * - For single: '2024-01-15'
   * - For multiple: '2024-01-15,2024-01-20,2024-01-25'
   * - For range: '2024-01-15,2024-01-20' (start,end)
   */
  value?: string;
  /**
   * Disable the calendar.
   */
  disabled?: boolean;
  /**
   * Minimum selectable date (YYYY-MM-DD).
   */
  min?: string;
  /**
   * Maximum selectable date (YYYY-MM-DD).
   */
  max?: string;
  /**
   * Caption layout style.
   * - 'label': Default label style
   * - 'dropdown': Both month and year dropdowns
   * - 'dropdown-months': Month dropdown only
   * - 'dropdown-years': Year dropdown only
   * @default 'label'
   */
  captionLayout?: 'label' | 'dropdown' | 'dropdown-months' | 'dropdown-years';
  /**
   * Hide the navigation arrows (prev/next month).
   * @default false
   */
  hideNavigation?: boolean;
  /**
   * Show week numbers column.
   * @default false
   */
  showWeekNumbers?: boolean;
  /**
   * Show days from adjacent months.
   * @default true
   */
  showOutsideDays?: boolean;
  /**
   * Always display 6 weeks for consistent height.
   * @default false
   */
  fixedWeeks?: boolean;
  /**
   * Hide the weekday name headers (Mon, Tue, etc.).
   * @default false
   */
  hideWeekdayNames?: boolean;
  /**
   * Number of months to display simultaneously.
   * @default 1
   */
  numberOfMonths?: number;
  /**
   * Allow deselecting a selected date by clicking it again.
   * Only applies to 'single' selection mode.
   * @default false
   */
  allowDeselection?: boolean;
  /**
   * Fired when date selection changes. Detail contains the selected value.
   */
  onChange?: (event: CustomEvent<FlutterShadcnCalendarChangeEventDetail>) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
export interface FlutterShadcnCalendarElement extends WebFElementWithMethods<{
}> {
  /** Selection mode. */
  mode?: 'single' | 'multiple' | 'range';
  /** Selected date(s) in ISO format (YYYY-MM-DD). */
  value?: string;
  /** Disable the calendar. */
  disabled?: boolean;
  /** Minimum selectable date (YYYY-MM-DD). */
  min?: string;
  /** Maximum selectable date (YYYY-MM-DD). */
  max?: string;
  /** Caption layout style. */
  captionLayout?: 'label' | 'dropdown' | 'dropdown-months' | 'dropdown-years';
  /** Hide the navigation arrows (prev/next month). */
  hideNavigation?: boolean;
  /** Show week numbers column. */
  showWeekNumbers?: boolean;
  /** Show days from adjacent months. */
  showOutsideDays?: boolean;
  /** Always display 6 weeks for consistent height. */
  fixedWeeks?: boolean;
  /** Hide the weekday name headers (Mon, Tue, etc.). */
  hideWeekdayNames?: boolean;
  /** Number of months to display simultaneously. */
  numberOfMonths?: number;
  /** Allow deselecting a selected date by clicking it again. */
  allowDeselection?: boolean;
}
/**
 * Properties for <flutter-shadcn-calendar>
A calendar component for date selection with support for single, multiple, and range modes.
@example
```html
<!-- Single date selection -->
<flutter-shadcn-calendar mode="single" value="2024-01-15" />
<!-- Multiple date selection -->
<flutter-shadcn-calendar mode="multiple" value="2024-01-15,2024-01-20,2024-01-25" />
<!-- Date range selection -->
<flutter-shadcn-calendar mode="range" value="2024-01-15,2024-01-20" />
<!-- With dropdown year/month -->
<flutter-shadcn-calendar caption-layout="dropdown" />
<!-- Multiple months view -->
<flutter-shadcn-calendar number-of-months="2" />
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCalendar
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCalendar>
 * ```
 */
export const FlutterShadcnCalendar = createWebFComponent<FlutterShadcnCalendarElement, FlutterShadcnCalendarProps>({
  tagName: 'flutter-shadcn-calendar',
  displayName: 'FlutterShadcnCalendar',
  // Map props to attributes
  attributeProps: [
    'mode',
    'value',
    'disabled',
    'min',
    'max',
    'captionLayout',
    'hideNavigation',
    'showWeekNumbers',
    'showOutsideDays',
    'fixedWeeks',
    'hideWeekdayNames',
    'numberOfMonths',
    'allowDeselection',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    captionLayout: 'caption-layout',
    hideNavigation: 'hide-navigation',
    showWeekNumbers: 'show-week-numbers',
    showOutsideDays: 'show-outside-days',
    fixedWeeks: 'fixed-weeks',
    hideWeekdayNames: 'hide-weekday-names',
    numberOfMonths: 'number-of-months',
    allowDeselection: 'allow-deselection',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: CustomEvent<FlutterShadcnCalendarChangeEventDetail>) => void) => (event: Event) => {
        callback(event as CustomEvent<FlutterShadcnCalendarChangeEventDetail>);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});