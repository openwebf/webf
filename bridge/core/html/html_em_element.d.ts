import {HTMLElement} from "./html_element";

export interface HTMLEmElement extends HTMLElement {
  new(): void;
}