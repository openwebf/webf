import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface PopstateEventInit extends EventInit {
  state?: any;
}