interface FlutterCupertinoSwitchProperties {
  checked?: boolean;
  disabled?: boolean;
  'active-color'?: string;
  'inactive-color'?: string;
}

interface FlutterCupertinoSwitchEvents {
  change: CustomEvent<boolean>;
}
