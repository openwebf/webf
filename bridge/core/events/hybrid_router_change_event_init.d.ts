import {EventInit} from "../dom/events/event_init";

// @ts-ignore
@Dictionary()
export interface HybridRouterChangeEventInit extends EventInit {
  kind?: string;
  path?: string;
  state?: any;
}