import {DOMMatrixInit} from "./dom_matrix_init";
import {DOMMatrixReadOnly} from "./dom_matrix_read_only";

interface DOMMatrix extends DOMMatrixReadOnly {
    fromMatrix(matrix: DOMMatrix): StaticMethod<DOMMatrix>;
    new(init?: number[] | DOMMatrixInit): DOMMatrix;
}