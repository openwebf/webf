/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
import {HTMLElement} from "../html_element";

interface HTMLTextareaElement extends HTMLElement {
  defaultValue: DartImpl<LegacyNullToEmptyString>;
  value: DartImpl<LegacyNullToEmptyString>;
  cols: DartImpl<double>;
  rows: DartImpl<double>;
  wrap: DartImpl<LegacyNullToEmptyString>;
  autofocus: DartImpl<boolean>;
  autocomplete: DartImpl<LegacyNullToEmptyString>;
  disabled: DartImpl<boolean>;
  minLength: DartImpl<double>;
  maxLength: DartImpl<double>;
  selectionStart: DartImpl<double>;
  selectionEnd: DartImpl<double>;
  name: DartImpl<string>;
  placeholder: DartImpl<LegacyNullToEmptyString>;
  readonly: DartImpl<LegacyNullToEmptyString>;
  required: DartImpl<LegacyNullToEmptyString>;
  inputMode: DartImpl<LegacyNullToEmptyString>;
  focus(): DartImpl<void>;
  blur(): DartImpl<void>;
  new(): void;
}
