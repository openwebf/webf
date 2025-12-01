/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {DOMMatrix} from "../../geometry/dom_matrix";

interface CanvasPattern {
  setTransform(matrix: DOMMatrix): void;
  new(): void;
}