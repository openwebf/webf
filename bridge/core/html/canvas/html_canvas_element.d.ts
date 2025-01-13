import {HTMLElement} from "../html_element";

interface HTMLCanvasElement extends HTMLElement {
  width: SupportAsync<DartImpl<int64>>;
  height: SupportAsync<DartImpl<int64>>;
  getContext(contextType: string): CanvasRenderingContext | null;
  new(): void;
}
