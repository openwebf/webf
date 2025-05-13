import {Event} from "../dom/events/event";

interface ScreenEvent extends Event {
  readonly state: any;
  readonly path: string;
  new(): ScreenEvent;
}