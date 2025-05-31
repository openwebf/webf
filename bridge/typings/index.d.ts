/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 * Use of this source code is governed by a AGPL-3.0 license that can be
 * found in the LICENSE file.
 */

// Import all WebF types
import * as WebFTypes from './webf';

// Re-export all types for module usage
export * from './webf';

// Declare WebF types under the webf namespace only (no global pollution)
declare global {
  // WebF instance
  const webf: WebFTypes.Webf;
  
  // Add webf to Window
  interface Window {
    webf: WebFTypes.Webf;
  }
  
  // Make all WebF types available under webf namespace
  namespace webf {
    // Re-export all interfaces
    export interface ComputedCssStyleDeclaration extends WebFTypes.ComputedCssStyleDeclaration {}
    export interface CSSStyleDeclaration extends WebFTypes.CSSStyleDeclaration {}
    export interface InlineCssStyleDeclaration extends WebFTypes.InlineCssStyleDeclaration {}
    export interface CharacterData extends WebFTypes.CharacterData {}
    export interface ChildNode extends WebFTypes.ChildNode {}
    export interface Comment extends WebFTypes.Comment {}
    export interface DocumentFragment extends WebFTypes.DocumentFragment {}
    export interface Document extends WebFTypes.Document {}
    export interface DOMStringMap extends WebFTypes.DOMStringMap {}
    export interface DOMTokenList extends WebFTypes.DOMTokenList {}
    export interface Element extends WebFTypes.Element {}
    export interface CustomEvent extends WebFTypes.CustomEvent {}
    export interface EventTarget extends WebFTypes.EventTarget {}
    export interface Event extends WebFTypes.Event {}
    export interface GlobalEventHandlers extends WebFTypes.GlobalEventHandlers {}
    export interface BoundingClientRect extends WebFTypes.BoundingClientRect {}
    export interface ElementAttributes extends WebFTypes.ElementAttributes {}
    export interface MutationObserverRegistration extends WebFTypes.MutationObserverRegistration {}
    export interface MutationObserver extends WebFTypes.MutationObserver {}
    export interface MutationRecord extends WebFTypes.MutationRecord {}
    export interface NodeList extends WebFTypes.NodeList {}
    export interface Node extends WebFTypes.Node {}
    export interface ParentNode extends WebFTypes.ParentNode {}
    export interface ScrollOptions extends WebFTypes.ScrollOptions {}
    export interface ScrollToOptions extends WebFTypes.ScrollToOptions {}
    export interface Text extends WebFTypes.Text {}
    export interface AnimationEvent extends WebFTypes.AnimationEvent {}
    export interface CloseEvent extends WebFTypes.CloseEvent {}
    export interface ErrorEvent extends WebFTypes.ErrorEvent {}
    export interface FocusEvent extends WebFTypes.FocusEvent {}
    export interface GestureEvent extends WebFTypes.GestureEvent {}
    export interface HashchangeEvent extends WebFTypes.HashchangeEvent {}
    export interface HybridRouterChangeEvent extends WebFTypes.HybridRouterChangeEvent {}
    export interface InputEvent extends WebFTypes.InputEvent {}
    export interface IntersectionChangeEvent extends WebFTypes.IntersectionChangeEvent {}
    export interface KeyboardEvent extends WebFTypes.KeyboardEvent {}
    export interface MessageEvent extends WebFTypes.MessageEvent {}
    export interface MouseEvent extends WebFTypes.MouseEvent {}
    export interface PointerEvent extends WebFTypes.PointerEvent {}
    export interface PopStateEvent extends WebFTypes.PopStateEvent {}
    export interface PromiseRejectionEvent extends WebFTypes.PromiseRejectionEvent {}
    export interface ScreenEvent extends WebFTypes.ScreenEvent {}
    export interface TouchEvent extends WebFTypes.TouchEvent {}
    export interface TransitionEvent extends WebFTypes.TransitionEvent {}
    export interface UIEvent extends WebFTypes.UIEvent {}
    export interface BlobOptions extends WebFTypes.BlobOptions {}
    export interface Blob extends WebFTypes.Blob {}
    export interface FileOptions extends WebFTypes.FileOptions {}
    export interface File extends WebFTypes.File {}
    export interface IdleDeadline extends WebFTypes.IdleDeadline {}
    export interface Screen extends WebFTypes.Screen {}
    export interface WindowEventHandlers extends WebFTypes.WindowEventHandlers {}
    export interface WindowIdleRequestOptions extends WebFTypes.WindowIdleRequestOptions {}
    export interface Window extends WebFTypes.Window {}
    export interface DOMMatrixReadOnly extends WebFTypes.DOMMatrixReadOnly {}
    export interface DOMMatrix extends WebFTypes.DOMMatrix {}
    export interface DOMPointReadOnly extends WebFTypes.DOMPointReadOnly {}
    export interface DOMPoint extends WebFTypes.DOMPoint {}
    export interface CanvasGradient extends WebFTypes.CanvasGradient {}
    export interface CanvasPattern extends WebFTypes.CanvasPattern {}
    export interface CanvasRenderingContext2D extends WebFTypes.CanvasRenderingContext2D {}
    export interface CanvasRenderingContext extends WebFTypes.CanvasRenderingContext {}
    export interface HTMLCanvasElement extends WebFTypes.HTMLCanvasElement {}
    export interface Path2D extends WebFTypes.Path2D {}
    export interface TextMetrics extends WebFTypes.TextMetrics {}
    export interface WebFRouterLinkElement extends WebFTypes.WebFRouterLinkElement {}
    export interface WidgetElement extends WebFTypes.WidgetElement {}
    export interface FormData extends WebFTypes.FormData {}
    export interface HTMLButtonElement extends WebFTypes.HTMLButtonElement {}
    export interface HTMLFormElement extends WebFTypes.HTMLFormElement {}
    export interface HTMLInputElement extends WebFTypes.HTMLInputElement {}
    export interface HTMLTextareaElement extends WebFTypes.HTMLTextareaElement {}
    export interface HTMLAllCollection extends WebFTypes.HTMLAllCollection {}
    export interface HTMLAnchorElement extends WebFTypes.HTMLAnchorElement {}
    export interface HTMLBodyElement extends WebFTypes.HTMLBodyElement {}
    export interface HTMLBrElement extends WebFTypes.HTMLBrElement {}
    export interface HTMLCollection extends WebFTypes.HTMLCollection {}
    export interface HTMLDivElement extends WebFTypes.HTMLDivElement {}
    export interface HTMLElement extends WebFTypes.HTMLElement {}
    export interface HTMLHeadElement extends WebFTypes.HTMLHeadElement {}
    export interface HTMLHtmlElement extends WebFTypes.HTMLHtmlElement {}
    export interface HTMLIFrameElement extends WebFTypes.HTMLIFrameElement {}
    export interface HTMLImageElement extends WebFTypes.HTMLImageElement {}
    export interface HTMLLinkElement extends WebFTypes.HTMLLinkElement {}
    export interface HTMLScriptElement extends WebFTypes.HTMLScriptElement {}
    export interface HTMLTemplateElement extends WebFTypes.HTMLTemplateElement {}
    export interface HTMLUnknownElement extends WebFTypes.HTMLUnknownElement {}
    export interface Image extends WebFTypes.Image {}
    export interface WebFTouchAreaElement extends WebFTypes.WebFTouchAreaElement {}
    export interface TouchList extends WebFTypes.TouchList {}
    export interface Touch extends WebFTypes.Touch {}
    export interface NativeLoader extends WebFTypes.NativeLoader {}
    export interface SVGCircleElement extends WebFTypes.SVGCircleElement {}
    export interface SVGElement extends WebFTypes.SVGElement {}
    export interface SVGEllipseElement extends WebFTypes.SVGEllipseElement {}
    export interface SVGGElement extends WebFTypes.SVGGElement {}
    export interface SVGGeometryElement extends WebFTypes.SVGGeometryElement {}
    export interface SVGGraphicsElement extends WebFTypes.SVGGraphicsElement {}
    export interface SVGLineElement extends WebFTypes.SVGLineElement {}
    export interface SVGPathElement extends WebFTypes.SVGPathElement {}
    export interface SVGRectElement extends WebFTypes.SVGRectElement {}
    export interface SVGStyleElement extends WebFTypes.SVGStyleElement {}
    export interface SVGSVGElement extends WebFTypes.SVGSVGElement {}
    export interface SVGTextContentElement extends WebFTypes.SVGTextContentElement {}
    export interface SVGTextElement extends WebFTypes.SVGTextElement {}
    export interface SVGTextPositioningElement extends WebFTypes.SVGTextPositioningElement {}
    export interface PerformanceEntry extends WebFTypes.PerformanceEntry {}
    export interface PerformanceMarkOptions extends WebFTypes.PerformanceMarkOptions {}
    export interface PerformanceMark extends WebFTypes.PerformanceMark {}
    export interface PerformanceMeasureOptions extends WebFTypes.PerformanceMeasureOptions {}
    export interface PerformanceMeasure extends WebFTypes.PerformanceMeasure {}
    export interface Performance extends WebFTypes.Performance {}
    export interface AbortSignalInterface extends WebFTypes.AbortSignalInterface {}
    export interface AbortControllerInterface extends WebFTypes.AbortControllerInterface {}
    export interface AsyncStorage extends WebFTypes.AsyncStorage {}
    export interface IdleRequestOptions extends WebFTypes.IdleRequestOptions {}
    export interface IdleRequestCallback extends WebFTypes.IdleRequestCallback {}
    export interface IdleDeadline extends WebFTypes.IdleDeadline {}
    export interface Console extends WebFTypes.Console {}
    export interface Cookie extends WebFTypes.Cookie {}
    export interface HistoryInterface extends WebFTypes.HistoryInterface {}
    export interface HybridHistoryInterface extends WebFTypes.HybridHistoryInterface {}
    export interface LocationInterface extends WebFTypes.LocationInterface {}
    export interface Expression extends WebFTypes.Expression {}
    export interface Query extends WebFTypes.Query {}
    export interface MediaQueryListEvent extends WebFTypes.MediaQueryListEvent {}
    export interface MediaQueryList extends WebFTypes.MediaQueryList {}
    export interface MethodChannelInterface extends WebFTypes.MethodChannelInterface {}
    export interface NavigatorInterface extends WebFTypes.NavigatorInterface {}
    export interface BoxSize extends WebFTypes.BoxSize {}
    export interface ResizeObserverEntry extends WebFTypes.ResizeObserverEntry {}
    export interface ResizeObserverInterface extends WebFTypes.ResizeObserverInterface {}
    export interface StorageInterface extends WebFTypes.StorageInterface {}
    export interface URLSearchParamsInterface extends WebFTypes.URLSearchParamsInterface {}
    export interface URLInterface extends WebFTypes.URLInterface {}
    export interface WebSocketInterface extends WebFTypes.WebSocketInterface {}
    export interface XMLHttpRequestInterface extends WebFTypes.XMLHttpRequestInterface {}
    export interface StorageInterface extends WebFTypes.StorageInterface {}
    export interface AsyncStorage extends WebFTypes.AsyncStorage {}
    export interface LocationInterface extends WebFTypes.LocationInterface {}
    export interface HistoryInterface extends WebFTypes.HistoryInterface {}
    export interface NavigatorInterface extends WebFTypes.NavigatorInterface {}
    export interface MediaQueryListEvent extends WebFTypes.MediaQueryListEvent {}
    export interface MediaQueryList extends WebFTypes.MediaQueryList {}
    export interface Webf extends WebFTypes.Webf {}
    
    // Re-export all types
    export type _AbortSignal = WebFTypes._AbortSignal;
    export type _AbortController = WebFTypes._AbortController;
    export type WebfInvokeModule = WebFTypes.WebfInvokeModule;
    export type AddWebfModuleListener = WebFTypes.AddWebfModuleListener;
    export type ClearWebfModuleListener = WebFTypes.ClearWebfModuleListener;
    export type RemoveWebfModuleListener = WebFTypes.RemoveWebfModuleListener;
    export type RequestIdleCallback = WebFTypes.RequestIdleCallback;
    export type DOMException = WebFTypes.DOMException;
    export type Headers = WebFTypes.Headers;
    export type Body = WebFTypes.Body;
    export type Request = WebFTypes.Request;
    export type Response = WebFTypes.Response;
    export type Fetch = WebFTypes.Fetch;
    export type History = WebFTypes.History;
    export type HybridHistory = WebFTypes.HybridHistory;
    export type Location = WebFTypes.Location;
    export type MatchMedia = WebFTypes.MatchMedia;
    export type ResizeObserver = WebFTypes.ResizeObserver;
    export type Storage = WebFTypes.Storage;
    export type URLSearchParams = WebFTypes.URLSearchParams;
    export type URL = WebFTypes.URL;
    export type WebSocket = WebFTypes.WebSocket;
    export type XMLHttpRequest = WebFTypes.XMLHttpRequest;
    export type RequestMode = WebFTypes.RequestMode;
    export type ResponseType = WebFTypes.ResponseType;
    export type RequestInfo = WebFTypes.RequestInfo;
    export type MatchMedia = WebFTypes.MatchMedia;
  }
}

// Ensure this is treated as a module
export {};
