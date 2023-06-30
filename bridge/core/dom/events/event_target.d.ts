
// TODO: support options for addEventListener and removeEventListener
import {AddEventListenerOptions} from "./add_event_listener_options";
import {EventListenerOptions} from "./event_listener_options";
import {Event} from "./event";

interface EventTarget {
  addEventListener(type: string, callback: JSEventListener | null, options?: AddEventListenerOptions | boolean): void;
  removeEventListener(type: string, callback: JSEventListener | null, options?: EventListenerOptions | boolean): void;
  dispatchEvent(event: Event): boolean;
  new(): EventTarget;
}
