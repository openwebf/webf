/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "./html_element";
import {DocumentFragment} from "../dom/document_fragment";

export interface HTMLTemplateElement extends HTMLElement {
  readonly content: DocumentFragment;
  new(): void;
}
