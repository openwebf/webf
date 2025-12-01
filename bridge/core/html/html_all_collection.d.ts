/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLCollection} from "./html_collection";
import {Element} from "../dom/element";

interface HTMLAllCollection extends HTMLCollection {
    item(index: double): Element | null;
    readonly [key: number]: Element | null;
    new(): void;
}