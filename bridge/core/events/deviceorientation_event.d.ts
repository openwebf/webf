import {Event} from "../dom/events/event";
import {DeviceorientationEventInit} from "./device_orientation_event_init";

interface DeviceorientationEvent extends Event {
  readonly absolute: boolean;
  readonly alpha: number;
  readonly beta: number;
  readonly gamma: number;
  [key: string]: any;
  new(type: string, init?: DeviceorientationEventInit): DeviceorientationEvent;
}
