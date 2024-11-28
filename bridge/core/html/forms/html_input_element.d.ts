import {HTMLElement} from "../html_element";

interface HTMLInputElement extends HTMLElement {
  width: DartImpl<number>;
  height: DartImpl<number>;
  defaultValue: SupportAsync<DartImpl<string>>;
  value: DartImpl<LegacyNullToEmptyString>;
  accept: DartImpl<string>;
  autocomplete: DartImpl<string>;
  autofocus: SupportAsync<DartImpl<boolean>>;
  checked: DartImpl<boolean>;
  disabled: SupportAsync<DartImpl<boolean>>;
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
  readonly: SupportAsync<DartImpl<boolean>>;
  placeholder: SupportAsync<DartImpl<string>>
  type: SupportAsync<DartImpl<string>>;
  inputMode: DartImpl<string>;
  focus(): SupportAsync<DartImpl<void>>;
  blur(): SupportAsync<DartImpl<void>>;
  new(): void;
}
