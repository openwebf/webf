type IDLEventHandler = Function;

// @ts-ignore
@Mixin()
export interface GlobalEventHandlers {
    /**
     * Fires when the user aborts the download.
     * @param ev The event.
     */
    onabort: IDLEventHandler | null;
    onanimationcancel: IDLEventHandler | null;
    onanimationend: IDLEventHandler | null;
    onanimationiteration: IDLEventHandler | null;
    onanimationstart: IDLEventHandler | null;
    /**
     * Fires when the object loses the input focus.
     * @param ev The focus event.
     */
    onblur: IDLEventHandler | null;
    oncancel: IDLEventHandler | null;
    /**
     * Occurs when playback is possible, but would require further buffering.
     * @param ev The event.
     */
    oncanplay: IDLEventHandler | null;
    oncanplaythrough: IDLEventHandler | null;
    /**
     * Fires when the contents of the object or selection have changed.
     * @param ev The event.
     */
    onchange: IDLEventHandler | null;
    /**
     * Fires when the user clicks the left mouse button on the object
     * @param ev The mouse event.
     */
    onclick: IDLEventHandler | null;
    onclose: IDLEventHandler | null;
    /**
     * Fires when the user double-clicks the object.
     * @param ev The mouse event.
     */
    ondblclick: IDLEventHandler | null;
    /**
     * Fires on the source object continuously during a drag operation.
     * @param ev The event.
     */
    // ondrag: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    /**
     * Fires on the source object when the user releases the mouse at the close of a drag operation.
     * @param ev The event.
     */
    // ondragend: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    /**
     * Fires on the target element when the user drags the object to a valid drop target.
     * @param ev The drag event.
     */
    // ondragenter: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    // ondragexit: ((this: GlobalEventHandlers, ev: Event) => any) | null;
    /**
     * Fires on the target object when the user moves the mouse out of a valid drop target during a drag operation.
     * @param ev The drag event.
     */
    // ondragleave: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    /**
     * Fires on the target element continuously while the user drags the object over a valid drop target.
     * @param ev The event.
     */
    // ondragover: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    /**
     * Fires on the source object when the user starts to drag a text selection or selected object.
     * @param ev The event.
     */
    // ondragstart: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    // ondrop: ((this: GlobalEventHandlers, ev: DragEvent) => any) | null;
    /**
     * Occurs when the end of playback is reached.
     * @param ev The event
     */
    onended: IDLEventHandler | null;
    /**
     * Fires when an error occurs during object loading.
     * @param ev The event.
     */
    onerror: IDLEventHandler | null;
    /**
     * Fires when the object receives focus.
     * @param ev The event.
     */
    onfocus: IDLEventHandler | null;
    ongotpointercapture: IDLEventHandler | null;
    oninput: IDLEventHandler | null;
    oninvalid: IDLEventHandler | null;
    /**
     * Fires when the user presses a key.
     * @param ev The keyboard event
     */
    onkeydown: IDLEventHandler | null;
    /**
     * Fires when the user presses an alphanumeric key.
     * @param ev The event.
     */
    onkeypress: IDLEventHandler | null;
    /**
     * Fires when the user releases a key.
     * @param ev The keyboard event
     */
    onkeyup: IDLEventHandler | null;
    /**
     * Fires immediately after the browser loads the object.
     * @param ev The event.
     */
    onload: IDLEventHandler | null;
    // /**
    //  * Occurs when media data is loaded at the current playback position.
    //  * @param ev The event.
    //  */
    // onloadeddata: IDLEventHandler | null;
    // /**
    //  * Occurs when the duration and dimensions of the media have been determined.
    //  * @param ev The event.
    //  */
    // onloadedmetadata: IDLEventHandler | null;
    // /**
    //  * Occurs when Internet Explorer begins looking for media data.
    //  * @param ev The event.
    //  */
    // onloadstart: IDLEventHandler | null;
    // onlostpointercapture: IDLEventHandler | null;
    /**
     * Fires when the user clicks the object with either mouse button.
     * @param ev The mouse event.
     */
    onmousedown: IDLEventHandler | null;
    onmouseenter: IDLEventHandler | null;
    onmouseleave: IDLEventHandler | null;
    /**
     * Fires when the user moves the mouse over the object.
     * @param ev The mouse event.
     */
    onmousemove: IDLEventHandler | null;
    /**
     * Fires when the user moves the mouse pointer outside the boundaries of the object.
     * @param ev The mouse event.
     */
    onmouseout: IDLEventHandler | null;
    /**
     * Fires when the user moves the mouse pointer into the object.
     * @param ev The mouse event.
     */
    onmouseover: IDLEventHandler | null;
    /**
     * Fires when the user releases a mouse button while the mouse is over the object.
     * @param ev The mouse event.
     */
    onmouseup: IDLEventHandler | null;
    /**
     * Occurs when playback is paused.
     * @param ev The event.
     */
    onpause: IDLEventHandler | null;
    /**
     * Occurs when the play method is requested.
     * @param ev The event.
     */
    onplay: IDLEventHandler | null;
    /**
     * Occurs when the audio or video has started playing.
     * @param ev The event.
     */
    onplaying: IDLEventHandler | null;
    onpointercancel: IDLEventHandler | null;
    onpointerdown: IDLEventHandler | null;
    onpointerenter: IDLEventHandler | null;
    onpointerleave: IDLEventHandler | null;
    onpointermove: IDLEventHandler | null;
    onpointerout: IDLEventHandler | null;
    onpointerover: IDLEventHandler | null;
    onpointerup: IDLEventHandler | null;
    /**
     * Occurs to indicate progress while downloading media data.
     * @param ev The event.
     */
    // onprogress: ((this: GlobalEventHandlers, ev: ProgressEvent) => any) | null;
    /**
     * Occurs when the playback rate is increased or decreased.
     * @param ev The event.
     */
    onratechange: IDLEventHandler | null;
    /**
     * Fires when the user resets a form.
     * @param ev The event.
     */
    onreset: IDLEventHandler | null;
    onresize: IDLEventHandler | null;
    /**
     * Fires when the user repositions the scroll box in the scroll bar on the object.
     * @param ev The event.
     */
    onscroll: IDLEventHandler | null;
    // onsecuritypolicyviolation: ((this: GlobalEventHandlers, ev: SecurityPolicyViolationEvent) => any) | null;
    /**
     * Occurs when the seek operation ends.
     * @param ev The event.
     */
    onseeked: IDLEventHandler | null;
    /**
     * Occurs when the current playback position is moved.
     * @param ev The event.
     */
    onseeking: IDLEventHandler | null;
    /**
     * Fires when the current selection changes.
     * @param ev The event.
     */
    onselect: IDLEventHandler | null;
    onselectionchange: IDLEventHandler | null;
    onselectstart: IDLEventHandler | null;
    /**
     * Occurs when the download has stopped.
     * @param ev The event.
     */
    onstalled: IDLEventHandler | null;
    onsubmit: IDLEventHandler | null;
    /**
     * Occurs if the load operation has been intentionally halted.
     * @param ev The event.
     */
    onsuspend: IDLEventHandler | null;
    ontoggle: IDLEventHandler | null;
    ontouchcancel?: IDLEventHandler | null;
    ontouchend?: IDLEventHandler | null;
    ontouchmove?: IDLEventHandler | null;
    ontouchstart?: IDLEventHandler | null;
    ontransitioncancel: IDLEventHandler | null;
    ontransitionend: IDLEventHandler | null;
    ontransitionrun: IDLEventHandler | null;
    ontransitionstart: IDLEventHandler | null;
    /**
     * Occurs when playback stops because the next frame of a video resource is not available.
     * @param ev The event.
     */
    onwaiting: IDLEventHandler | null;
    onwheel: IDLEventHandler | null;

    /**
     * Occurs when the renderObject of this Element had been attached to detached from flutter tree
     */
    ononscreen: IDLEventHandler | null;
    onoffscreen: IDLEventHandler | null;
}