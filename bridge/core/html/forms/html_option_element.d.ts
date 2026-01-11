/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "../html_element";

interface HTMLOptionElement extends HTMLElement {
  value: string;
  selected: boolean;
  defaultSelected: boolean;
  disabled: boolean;
  new(): void;
}

