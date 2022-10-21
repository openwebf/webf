import {HTMLElement} from "../html_element";

interface HTMLCanvasElement extends HTMLElement {
  width: DartImpl<int64>;
  height: DartImpl<int64>;
  getContext(contextType: string): CanvasRenderingContext | null;
  new(): void;
}
