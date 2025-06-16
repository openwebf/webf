interface FlutterCupertinoInputProperties {
  val?: string;
  placeholder?: string;
  type?: string;
  disabled?: boolean;
  autofocus: boolean;
  clearable?: boolean;
  maxlength?: int;
  readonly?: boolean;
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
}

interface FlutterCupertinoInputEvents {
  input: CustomEvent<string>;
  submit: CustomEvent<string>;
}
