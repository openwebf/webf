import {DOMMatrix} from "../../geometry/dom_matrix";

interface CanvasPattern {
  setTransform(matrix: DOMMatrix): void;
  new(): void;
}