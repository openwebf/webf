import {HTMLElement} from "../html_element";

interface HTMLInputElement extends HTMLElement {
  width: number;
  height: number;
  defaultValue: string;
  value: string;
  accept: string;
  autocomplete: string;
  autofocus: boolean;
  checked: boolean;
  disabled: boolean;
  min: string;
  max: string;
  minLength: double;
  maxLength: double;
  size: double;
  multiple: boolean;
  name: string;
  step: string;
  pattern: string;
  required: boolean;
  readonly: boolean;
  placeholder: string
  type: string;
  inputMode: string;
  focus(): void;
  blur(): void;
  new(): void;
}
