// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
import {HTMLElement} from "../html_element";

interface HTMLTextareaElement extends HTMLElement {
  defaultValue: DartImpl<string>;
  value: DartImpl<string>;
  cols: DartImpl<double>;
  rows: DartImpl<double>;
  wrap: DartImpl<string>;
  autofocus: DartImpl<boolean>;
  autocomplete: DartImpl<string>;
  disabled: DartImpl<boolean>;
  minLength: DartImpl<double>;
  maxLength: DartImpl<double>;
  selectionStart: DartImpl<double>;
  selectionEnd: DartImpl<double>;
  name: DartImpl<string>;
  placeholder: DartImpl<string>;
  readonly: DartImpl<boolean>;
  required: DartImpl<boolean>;
  inputMode: DartImpl<string>;
  focus(): DartImpl<void>;
  blur(): DartImpl<void>;
  new(): void;
}
