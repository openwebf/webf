import {Element} from "../dom/element";
import {GlobalEventHandlers} from "../dom/global_event_handlers";

export interface HTMLElement extends Element, GlobalEventHandlers {
  // CSSOM View Module
  // https://drafts.csswg.org/cssom-view/#extensions-to-the-htmlelement-interface
  readonly offsetTop: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly offsetLeft: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly offsetWidth: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly offsetHeight: SupportAsync<DartImpl<DependentsOnLayout<double>>>;

  click(): DartImpl<DependentsOnLayout<void>>;

  new(): void;
}
