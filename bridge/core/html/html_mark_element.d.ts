import {HTMLElement} from "./html_element";

export interface HTMLMarkElement extends HTMLElement {
  new(): void;
}