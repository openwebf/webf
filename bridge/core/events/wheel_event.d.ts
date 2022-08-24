import {MouseEvent} from "./mouse_event";
import {WheelEventInit} from "./wheel_event_init";
/** Events that occur due to the user moving a mouse wheel or similar input device. */
interface WheelEvent extends MouseEvent {
    readonly deltaMode: number;
    readonly deltaX: number;
    readonly deltaY: number;
    readonly deltaZ: number;
    readonly DOM_DELTA_LINE: StaticMember<number>;
    readonly DOM_DELTA_PAGE: StaticMember<number>;
    readonly DOM_DELTA_PIXEL: StaticMember<number>;
    new(type: string, init?: WheelEventInit): WheelEvent;
}
