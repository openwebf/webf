import {HTMLElement} from "./html_element";

interface HTMLLinkElement extends HTMLElement {
  disabled: SupportAsync<DartImpl<boolean>>;
  rel: SupportAsync<DartImpl<string>>;
  readonly relList: DOMTokenList;
  href: SupportAsync<DartImpl<string>>;
  type: SupportAsync<DartImpl<string>>;
  new(): void;
}
