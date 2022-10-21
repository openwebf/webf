import {HTMLElement} from "./html_element";

interface HTMLLinkElement extends HTMLElement {
  disabled: DartImpl<boolean>;
  rel: DartImpl<string>;
  href: DartImpl<string>;
  type: DartImpl<string>;
  new(): void;
}