/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "../html_element";
import {HTMLCollection} from "../html_collection";

interface HTMLSelectElement extends HTMLElement {
  readonly options: HTMLCollection;
  value: string;
  selectedIndex: double;
  multiple: boolean;
  new(): void;
}

