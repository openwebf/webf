import {HTMLElement} from "./html_element";

export interface HTMLVarElement extends HTMLElement {
  new(): void;
}