/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "./html_element";
import {CSSStyleSheet} from "../css/css_style_sheet";

interface HTMLLinkElement extends HTMLElement {
  disabled: SupportAsync<DartImpl<boolean>>;
  rel: SupportAsync<DartImpl<string>>;
  readonly relList: DOMTokenList;
  href: SupportAsync<DartImpl<string>>;
  type: SupportAsync<DartImpl<string>>;
  readonly sheet: CSSStyleSheet | null;
  new(): void;
}
