import {HTMLElement} from "./html_element";

export interface HTMLDataElement extends HTMLElement {
  new(): void;
}