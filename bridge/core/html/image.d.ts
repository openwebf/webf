/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {HTMLImageElement} from "./html_image_element";

interface Image extends HTMLImageElement {
  new(): Image;
}