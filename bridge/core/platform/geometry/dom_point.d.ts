/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {DOMPointInit} from "./dom_point_init";
import {DOMPointReadOnly} from "./dom_point_read_only";

interface DOMPoint extends DOMPointReadOnly {
    fromPoint(point: DOMPoint): StaticMethod<DOMPoint>;
    new(x?: number | DOMPointInit, y?: number, z?: number, w?: number): DOMPoint;
}