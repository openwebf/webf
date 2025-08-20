import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface PopStateEventInit extends EventInit {
  state?: any;
}