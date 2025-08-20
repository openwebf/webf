interface FlutterCupertinoTimerPickerProperties {
  mode?: string;
  'initial-timer-duration'?: int;
  'minute-interval'?: int;
  'second-interval'?: int;
  'background-color'?: string;
  height?: double;
}

interface FlutterCupertinoTimerPickerEvents {
  change: CustomEvent<int>;
}
