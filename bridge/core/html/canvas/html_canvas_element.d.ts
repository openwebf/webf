/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLElement} from "../html_element";
import {CanvasRenderingContext2D} from "./canvas_rendering_context_2d";

interface HTMLCanvasElement extends HTMLElement {
  width: SupportAsync<DartImpl<int64>>;
  height: SupportAsync<DartImpl<int64>>;
  getContext(contextType: string): CanvasRenderingContext2D | null;
  new(): void;
}
