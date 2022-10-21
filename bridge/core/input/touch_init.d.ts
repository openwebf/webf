
// @ts-ignore
import {EventTarget} from "../dom/events/event_target";

// @ts-ignore
@Dictionary()
export interface TouchInit {
    identifier: double;
    target: EventTarget;
    clientX?: double;
    clientY?: double;
    screenX?: double;
    screenY?: double;
    pageX?: double;
    pageY?: double;
    radiusX?: double;
    radiusY?: double;
    rotationAngle?: double;
    force?: double;
}
