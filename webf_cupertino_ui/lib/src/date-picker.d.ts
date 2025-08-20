interface FlutterCupertinoDatePickerProperties {
  mode?: string;
  'minimum-date'?: string;
  'maximum-date'?: string;
  'minute-interval'?: string;
  value?: string;
  'minimum-year'?: string;
  'maximum-year'?: string;
  'show-day-of-week'?: string;
  'date-order'?: string;
  height?: string;
  'use-24h'?: boolean;
}

interface FlutterCupertinoDatePickerEvents {
  change: CustomEvent<string>;
}
