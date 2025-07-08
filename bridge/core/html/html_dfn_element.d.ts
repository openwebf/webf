import {HTMLElement} from "./html_element";

export interface HTMLDfnElement extends HTMLElement {
  new(): void;
}