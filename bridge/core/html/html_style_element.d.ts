/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "./html_element";
import {CSSStyleSheet} from "../css/css_style_sheet";

interface HTMLStyleElement extends HTMLElement {
    readonly type: string;
    readonly sheet: CSSStyleSheet | null;
    new(): void;
}
