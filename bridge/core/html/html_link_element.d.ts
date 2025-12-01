/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "./html_element";

interface HTMLLinkElement extends HTMLElement {
  disabled: SupportAsync<DartImpl<boolean>>;
  rel: SupportAsync<DartImpl<string>>;
  readonly relList: DOMTokenList;
  href: SupportAsync<DartImpl<string>>;
  type: SupportAsync<DartImpl<string>>;
  new(): void;
}
