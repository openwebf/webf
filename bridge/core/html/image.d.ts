import {HTMLImageElement} from "./html_image_element";

interface Image extends HTMLImageElement {
  new(): Image;
}