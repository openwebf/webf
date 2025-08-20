import {MouseEventInit} from "./mouse_event_init";

// @ts-ignore
@Dictionary()
export interface PointerEventInit extends MouseEventInit {
    isPrimary?: boolean;
    pointerId?: number;
    pointerType?: string;
    pressure?: number;
    tangentialPressure?: number;
    tiltX?: number;
    tiltY?: number;
    twist?: number;
    width?: number;
    height?: number;
}