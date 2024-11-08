import {DOMMatrixInit} from "./dom_matrix_init";
import {DOMMatrixReadOnly} from "./dom_matrix_read_only";

interface DOMMatrix extends DOMMatrixReadOnly {
    new(init?: number[] | DOMMatrixInit): DOMMatrix;
}