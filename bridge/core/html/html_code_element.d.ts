/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "./html_element";

export interface HTMLCodeElement extends HTMLElement {
  new(): void;
}