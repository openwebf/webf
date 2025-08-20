type IDLEventHandler = Function;

// @ts-ignore
@Mixin()
export interface WindowEventHandlers {
    onbeforeunload: IDLEventHandler | null;
    onhashchange: IDLEventHandler | null;
    onmessage: IDLEventHandler | null;
    onmessageerror: IDLEventHandler | null;
    onpagehide: IDLEventHandler | null;
    onpageshow: IDLEventHandler | null;
    onpopstate: IDLEventHandler | null;
    onrejectionhandled: IDLEventHandler | null;
    onunhandledrejection: IDLEventHandler | null;
    onunload: IDLEventHandler | null;
}