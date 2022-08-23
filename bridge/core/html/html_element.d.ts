import {Element} from "../dom/element";
import {GlobalEventHandlers} from "../dom/global_event_handlers";

export interface HTMLElement extends Element, GlobalEventHandlers {
  // CSSOM View Module
  // https://drafts.csswg.org/cssom-view/#extensions-to-the-htmlelement-interface
  readonly offsetTop: DartImpl<double>;
  readonly offsetLeft: DartImpl<double>;
  readonly offsetWidth: DartImpl<double>;
  readonly offsetHeight: DartImpl<double>;

  new(): void;
}
