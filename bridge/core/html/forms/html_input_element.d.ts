import {HTMLElement} from "../html_element";

interface HTMLInputElement extends HTMLElement {
  width: DartImpl<number>;
  height: DartImpl<number>;
  defaultValue: DartImpl<string>;
  value: DartImpl<string>;
  accept: DartImpl<string>;
  autocomplete: DartImpl<string>;
  autofocus: DartImpl<boolean>;
  checked: DartImpl<boolean>;
  disabled: DartImpl<boolean>;
  min: DartImpl<string>;
  max: DartImpl<string>;
  minLength: DartImpl<double>;
  maxLength: DartImpl<double>;
  size: DartImpl<double>;
  multiple: DartImpl<boolean>;
  name: DartImpl<string>;
  step: DartImpl<string>;
  pattern: DartImpl<string>;
  required: DartImpl<boolean>;
  readonly: DartImpl<boolean>;
  placeholder: DartImpl<string>
  type: DartImpl<string>;
  inputMode: DartImpl<string>;
  focus(): DartImpl<void>;
  blur(): DartImpl<void>;
  _clearFocus__(): DartImpl<void>;
  new(): void;
}
