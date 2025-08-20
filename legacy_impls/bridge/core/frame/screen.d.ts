import {EventTarget} from "../dom/events/event_target";

export interface Screen extends EventTarget {
  readonly availWidth: int64;
  readonly availHeight: int64;
  readonly width: int64;
  readonly height: int64;

  new(): void;
}
