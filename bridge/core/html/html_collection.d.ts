/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {Element} from "../dom/element";

interface HTMLCollection {
    readonly length: double;
    item(index: double): Element | null;
    readonly [key: number]: Element | null;
    new(): void;
}