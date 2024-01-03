import {UIEvent} from "./ui_event";
import {EventTarget} from "../dom/events/event_target";
import {MouseEventInit} from "./mouse_event_init";

/** Events that occur due to the user interacting with a pointing device (such as a mouse). Common events using this interface include click, dblclick, mouseup, mousedown. */
interface MouseEvent extends UIEvent {
    // readonly altKey: boolean;
    // readonly button: number;
    // readonly buttons: number;
    readonly clientX: number;
    readonly clientY: number;
    // readonly ctrlKey: boolean;
    // readonly metaKey: boolean;
    // readonly movementX: number;
    // readonly movementY: number;
    readonly offsetX: number;
    readonly offsetY: number;
    // readonly pageX: number;
    // readonly pageY: number;
    // readonly relatedTarget: EventTarget | null;
    // readonly screenX: number;
    // readonly screenY: number;
    // readonly shiftKey: boolean;
    // readonly x: number;
    // readonly y: number;
    [key: string]: any;
    new(type: string, init?: MouseEventInit): MouseEvent;
}