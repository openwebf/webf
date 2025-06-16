interface FlutterCupertinoCheckboxProperties {
  val?: string;
  disabled?: boolean;
  'active-color'?: string;
  'check-color'?: string;
  'focus-color'?: string;
  'fill-color-selected'?: string;
  'fill-color-disabled'?: string;
}

interface FlutterCupertinoCheckboxEvents {
  change: CustomEvent<boolean>;
}
