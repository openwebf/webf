/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import {Element} from "../dom/element";
import {GlobalEventHandlers} from "../dom/global_event_handlers";

export interface SVGElement extends Element, GlobalEventHandlers {
  new(): void;
}
