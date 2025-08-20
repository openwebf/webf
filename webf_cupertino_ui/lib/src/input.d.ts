interface FlutterCupertinoInputProperties {
  val?: string;
  placeholder?: string;
  type?: string;
  disabled?: boolean;
  autofocus: boolean;
  clearable?: boolean;
  maxlength?: int;
  readonly?: boolean;
}

interface FlutterCupertinoInputMethods {
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
  clear(): void;
}

interface FlutterCupertinoInputEvents {
  input: CustomEvent<string>;
  submit: CustomEvent<string>;
  focus?: CustomEvent;
  blur?: CustomEvent;
  clear?: CustomEvent;
}

// Input sub-components
interface FlutterCupertinoInputPrefixProperties {}
interface FlutterCupertinoInputPrefixEvents {}

interface FlutterCupertinoInputSuffixProperties {}
interface FlutterCupertinoInputSuffixEvents {}
