/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {EventTarget} from "../dom/events/event_target";
import {ScrollOptions} from "../dom/scroll_options";
import {ScrollToOptions} from "../dom/scroll_to_options";
import {Screen} from "./screen";
import {WindowEventHandlers} from "./window_event_handlers";
import {GlobalEventHandlers} from "../dom/global_event_handlers";
import {Element} from "../dom/element";
import {WindowIdleRequestOptions} from "./window_idle_request_options";

// Forward-decl for std::variant WindowComputedStyle
declare class WindowComputedStyleVariant {}

interface Window extends EventTarget, WindowEventHandlers, GlobalEventHandlers {
  // base64 utility methods
  btoa(string: string): string;
  atob(string: string): string;
  open(url?: string): SupportAsync<Window | null>;
  scroll(x: number, y: number): SupportAsyncManual<void>;
  scroll(options?: ScrollToOptions): SupportAsyncManual<void>;
  scrollTo(options?: ScrollToOptions): SupportAsyncManual<void>;
  scrollTo(x: number, y: number):  SupportAsyncManual<void>;
  scrollBy(options?: ScrollToOptions): SupportAsyncManual<void>;
  scrollBy(x: number, y: number): SupportAsyncManual<void>;

  postMessage(message: any, targetOrigin: string): void;
  postMessage(message: any): void;

  __requestIdleCallback__(callback: Function, options?: WindowIdleRequestOptions): int64;

  getComputedStyle(element: Element, pseudoElt?: string): SupportAsync<WindowComputedStyleVariant>;

  readonly window: Window;
  readonly parent: Window;
  readonly self: Window;
  readonly screen: SupportAsync<Screen>;

  readonly scrollX: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly scrollY: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly pageXOffset: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly pageYOffset: SupportAsync<DartImpl<DependentsOnLayout<double>>>;
  readonly devicePixelRatio: SupportAsync<DartImpl<double>>;
  readonly colorScheme: SupportAsync<DartImpl<string>>;
  readonly innerWidth: SupportAsync<DartImpl<double>>;
  readonly innerHeight: SupportAsync<DartImpl<double>>;

  new(): void;
}
