/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "../html_element";

interface HTMLButtonElement extends HTMLElement {
    disabled: DartImpl<boolean>;
    type: DartImpl<string>;
    name: DartImpl<string>;
    value: DartImpl<string>;
    new(): void;
}
