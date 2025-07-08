import {HTMLElement} from "./html_element";

export interface HTMLSmallElement extends HTMLElement {
  new(): void;
}