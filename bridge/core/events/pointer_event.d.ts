import {MouseEvent} from "./mouse_event";
import {PointerEventInit} from "./pointer_event_init";

/** The state of a DOM event produced by a pointer such as the geometry of the contact point, the device type that generated the event, the amount of pressure that was applied on the contact surface, etc. */
interface PointerEvent extends MouseEvent {
    readonly height: number;
    readonly isPrimary: boolean;
    readonly pointerId: number;
    readonly pointerType: string;
    readonly pressure: number;
    readonly tangentialPressure: number;
    readonly tiltX: number;
    readonly tiltY: number;
    readonly twist: number;
    readonly width: number;
    [key: string]: any;
    new(type: string, init?: PointerEventInit): PointerEvent;
}