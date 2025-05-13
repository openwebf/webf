import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface ScreenEventInit extends EventInit {
  state?: any;
  path?: string;
}