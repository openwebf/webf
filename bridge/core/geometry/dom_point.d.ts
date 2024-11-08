import {DOMPointInit} from "./dom_point_init";
import {DOMPointReadOnly} from "./dom_point_read_only";

interface DOMPoint extends DOMPointReadOnly {
    new(x?: number | DOMPointInit, y?: number, z?: number, w?: number): DOMPoint;
}