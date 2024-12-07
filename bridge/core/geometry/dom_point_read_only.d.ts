import {DOMPointInit} from "./dom_point_init";
import {DOMMatrix} from "./dom_matrix";
import {DOMPoint} from "./dom_point";

interface DOMPointReadOnly {
    x: SupportAsync<number>;
    y: SupportAsync<number>;
    z: SupportAsync<number>;
    w: SupportAsync<number>;
    matrixTransform(matrix: DOMMatrix): SupportAsync<DOMPoint>;
    fromPoint(point: DOMPoint): StaticMethod<DOMPoint>;
    new(x?: number | DOMPointInit, y?: number, z?: number, w?: number): DOMPointReadOnly;
}