import {Event} from "../dom/events/event";
import {GestureEventInit} from "./gesture_event_init";

interface GestureEvent extends Event {
  readonly state: string;
  readonly direction: string;
  readonly deltaX: number;
  readonly deltaY: number;
  readonly velocityX: number;
  readonly velocityY: number;
  readonly scale: number;
  readonly rotation: number;
  [key: string]: any;
  new(type: string, init?: GestureEventInit): GestureEvent;
}
