import {UIEvent} from "./ui_event";
import {InputEventInit} from "./input_event_init";

interface InputEvent extends UIEvent {
  readonly inputType: string;
  readonly data: string;
  new(type: string, init?: InputEventInit): InputEvent;
}
