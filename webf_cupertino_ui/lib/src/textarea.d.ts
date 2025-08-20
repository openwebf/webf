interface FlutterCupertinoTextareaProperties {
  val?: string;
  placeholder?: string;
  disabled?: boolean;
  readonly?: boolean;
  maxLength?: int;
  rows?: int;
  showCount?: boolean;
  autoSize?: boolean;
  transparent?: boolean;
}

interface FlutterCupertinoTextareaMethods {
  focus(): void;
  blur(): void;
  clear(): void;
}

interface FlutterCupertinoTextareaEvents {
  input: CustomEvent<string>;
  complete: Event;
}
