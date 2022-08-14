import {Element} from "../dom/element";
import {GlobalEventHandlers} from "../dom/global_event_handlers";

export interface HTMLElement extends Element, GlobalEventHandlers {
  new(): void;
}
