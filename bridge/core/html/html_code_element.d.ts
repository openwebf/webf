import {HTMLElement} from "./html_element";

export interface HTMLCodeElement extends HTMLElement {
  new(): void;
}