import {Element} from "../dom/element";
import {GlobalEventHandlers} from "../dom/global_event_handlers";

export interface HTMLElement extends Element, GlobalEventHandlers {
  // CSSOM View Module
  // https://drafts.csswg.org/cssom-view/#extensions-to-the-htmlelement-interface
  readonly offsetTop: DartImpl<DependentsOnLayout<double>>;
  readonly offsetLeft: DartImpl<DependentsOnLayout<double>>;
  readonly offsetWidth: DartImpl<DependentsOnLayout<double>>;
  readonly offsetHeight: DartImpl<DependentsOnLayout<double>>;

  click(): DartImpl<void>;

  new(): void;
}
