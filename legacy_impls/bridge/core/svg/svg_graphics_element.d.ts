/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import {SVGElement} from "./svg_element";

export interface SVGGraphicsElement extends SVGElement {
  new(): void;
}
