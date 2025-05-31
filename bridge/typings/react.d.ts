/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// React utility types and helpers for WebF

/**
 * Cast a standard DOM element to its WebF equivalent
 * Usage: const webfDiv = toWebF(divRef.current);
 */
export function toWebF(element: null): null;
export function toWebF(element: HTMLDivElement): webf.HTMLDivElement;
export function toWebF(element: HTMLCanvasElement): webf.HTMLCanvasElement;
export function toWebF(element: HTMLImageElement): webf.HTMLImageElement;
export function toWebF(element: HTMLFormElement): webf.HTMLFormElement;
export function toWebF(element: HTMLInputElement): webf.HTMLInputElement;
export function toWebF(element: HTMLTextAreaElement): webf.HTMLTextareaElement;
export function toWebF(element: HTMLButtonElement): webf.HTMLButtonElement;
export function toWebF(element: HTMLAnchorElement): webf.HTMLAnchorElement;
export function toWebF(element: HTMLSpanElement): webf.HTMLElement;
export function toWebF(element: HTMLParagraphElement): webf.HTMLElement;
export function toWebF(element: HTMLHeadingElement): webf.HTMLElement;
export function toWebF(element: HTMLUListElement): webf.HTMLElement;
export function toWebF(element: HTMLOListElement): webf.HTMLElement;
export function toWebF(element: HTMLLIElement): webf.HTMLElement;
export function toWebF(element: HTMLTableElement): webf.HTMLElement;
export function toWebF(element: HTMLVideoElement): webf.HTMLElement;
export function toWebF(element: HTMLAudioElement): webf.HTMLElement;
export function toWebF(element: HTMLIFrameElement): webf.HTMLIFrameElement;
export function toWebF(element: HTMLScriptElement): webf.HTMLScriptElement;
export function toWebF(element: HTMLLinkElement): webf.HTMLLinkElement;
export function toWebF(element: HTMLBodyElement): webf.HTMLBodyElement;
export function toWebF(element: HTMLHtmlElement): webf.HTMLHtmlElement;
export function toWebF(element: HTMLHeadElement): webf.HTMLHeadElement;
export function toWebF(element: HTMLBRElement): webf.HTMLBrElement;
export function toWebF(element: HTMLTemplateElement): webf.HTMLTemplateElement;
export function toWebF(element: SVGSVGElement): webf.SVGSVGElement;
export function toWebF(element: SVGPathElement): webf.SVGPathElement;
export function toWebF(element: SVGCircleElement): webf.SVGCircleElement;
export function toWebF(element: SVGRectElement): webf.SVGRectElement;
export function toWebF(element: SVGLineElement): webf.SVGLineElement;
export function toWebF(element: SVGEllipseElement): webf.SVGEllipseElement;
export function toWebF(element: SVGGElement): webf.SVGGElement;
export function toWebF(element: SVGTextElement): webf.SVGTextElement;
export function toWebF(element: Element): webf.Element;

/**
 * Type guard to check if an element supports WebF features
 */
export function isWebFElement(element: any): element is webf.Element;

/**
 * Utility to create a WebF-aware event handler
 */
export function webfEventHandler<E extends Event>(
  handler: (event: E extends MouseEvent ? webf.MouseEvent : 
             E extends TouchEvent ? webf.TouchEvent :
             E extends KeyboardEvent ? webf.KeyboardEvent :
             webf.Event) => void
): (event: E) => void;

/**
 * React hook for WebF elements (requires React as peer dependency)
 * Usage:
 * ```tsx
 * const { ref, webf } = useWebFRef<HTMLDivElement>();
 * 
 * useEffect(() => {
 *   webf?.toBlob(); // WebF-specific method
 * }, []);
 * 
 * return <div ref={ref}>Content</div>;
 * ```
 */
export function useWebFRef<T extends HTMLElement>(): {
  ref: React.RefObject<T>;
  webf: T extends HTMLDivElement ? webf.HTMLDivElement | null :
        T extends HTMLCanvasElement ? webf.HTMLCanvasElement | null :
        T extends HTMLImageElement ? webf.HTMLImageElement | null :
        T extends HTMLFormElement ? webf.HTMLFormElement | null :
        T extends HTMLInputElement ? webf.HTMLInputElement | null :
        T extends HTMLTextAreaElement ? webf.HTMLTextareaElement | null :
        T extends HTMLButtonElement ? webf.HTMLButtonElement | null :
        T extends HTMLAnchorElement ? webf.HTMLAnchorElement | null :
        T extends HTMLIFrameElement ? webf.HTMLIFrameElement | null :
        T extends HTMLScriptElement ? webf.HTMLScriptElement | null :
        T extends HTMLLinkElement ? webf.HTMLLinkElement | null :
        T extends HTMLBodyElement ? webf.HTMLBodyElement | null :
        T extends HTMLHtmlElement ? webf.HTMLHtmlElement | null :
        T extends HTMLHeadElement ? webf.HTMLHeadElement | null :
        T extends HTMLBRElement ? webf.HTMLBrElement | null :
        T extends HTMLTemplateElement ? webf.HTMLTemplateElement | null :
        webf.HTMLElement | null;
};