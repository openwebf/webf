interface FlutterCupertinoSearchInputProperties {
  val?: string;
  placeholder?: string;
  disabled?: boolean;
  type?: string;
  'prefix-icon'?: string;
  'suffix-icon'?: string;
  'suffix-model'?: string;
  'item-color'?: string;
  'item-size'?: double;
  autofocus: boolean;
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
  clear(): void;
}

interface FlutterCupertinoSearchInputEvents {
  input: CustomEvent<string>;
  search: CustomEvent<string>;
  clear: CustomEvent;
}
