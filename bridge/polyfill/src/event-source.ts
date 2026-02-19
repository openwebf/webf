/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import {webf} from './webf';

const esClientMap: Record<string, EventSource> = {};
// Separate storage for named SSE event listeners. The bridge cannot create
// a MessageEvent with a non-standard type (like 'update'), so we route named
// events outside of the normal EventTarget.dispatchEvent path.
const namedListenersMap: Record<string, Record<string, Array<EventListener>>> = {};

function initPropertyHandlersForEventTargets(eventTarget: any, builtInEvents: string[]) {
  for (let i = 0; i < builtInEvents.length; i++) {
    const eventName = builtInEvents[i];
    const propertyName = 'on' + eventName;
    Object.defineProperty(eventTarget, propertyName, {
      get: function () {
        return this['_' + propertyName];
      },
      set: function (value) {
        if (value == null) {
          this.removeEventListener(eventName, this['_' + propertyName]);
        } else {
          this.addEventListener(eventName, value);
        }
        this['_' + propertyName] = value;
      }
    });
  }
}

function validateUrl(url: string): string {
  // Resolve relative URLs
  let resolvedUrl: string;
  try {
    resolvedUrl = new URL(url, location.href).toString();
  } catch (e) {
    throw new SyntaxError(`Failed to construct 'EventSource': The URL '${url}' is invalid.`);
  }
  const protocol = resolvedUrl.substring(0, resolvedUrl.indexOf(':'));
  if (protocol !== 'http' && protocol !== 'https') {
    throw new SyntaxError(
      `Failed to construct 'EventSource': The URL's scheme must be either 'http' or 'https'. '${protocol}' is not allowed.`
    );
  }
  return resolvedUrl;
}

const builtInEvents = ['open', 'message', 'error'];

export class EventSource extends EventTarget {
  static CONNECTING = 0;
  static OPEN = 1;
  static CLOSED = 2;

  CONNECTING: number;
  OPEN: number;
  CLOSED: number;

  url: string;
  withCredentials: boolean;
  readyState: number;
  id: string;

  constructor(url: string | URL, eventSourceInitDict?: { withCredentials?: boolean }) {
    // @ts-ignore
    super();
    this.CONNECTING = EventSource.CONNECTING;
    this.OPEN = EventSource.OPEN;
    this.CLOSED = EventSource.CLOSED;

    const urlStr = typeof url === 'object' && url instanceof URL ? url.toString() : url;
    this.url = validateUrl(urlStr);
    this.withCredentials = eventSourceInitDict?.withCredentials ?? false;
    this.readyState = EventSource.CONNECTING;
    this.id = webf.invokeModule('EventSource', 'init', this.url, this.withCredentials);
    esClientMap[this.id] = this;
    initPropertyHandlersForEventTargets(this, builtInEvents);
  }

  addEventListener(type: string, callback: EventListener | EventListenerObject) {
    webf.invokeModule('EventSource', 'addEvent', this.id, type);
    if (builtInEvents.indexOf(type) === -1) {
      // Named event — store in separate map since the bridge cannot create
      // a MessageEvent with a non-standard type.
      if (!namedListenersMap[this.id]) namedListenersMap[this.id] = {};
      if (!namedListenersMap[this.id][type]) namedListenersMap[this.id][type] = [];
      namedListenersMap[this.id][type].push(callback as EventListener);
    } else {
      super.addEventListener(type, callback);
    }
  }

  removeEventListener(type: string, callback: EventListener | EventListenerObject) {
    if (builtInEvents.indexOf(type) === -1) {
      const listeners = namedListenersMap[this.id]?.[type];
      if (listeners) {
        const idx = listeners.indexOf(callback as EventListener);
        if (idx !== -1) listeners.splice(idx, 1);
      }
    } else {
      super.removeEventListener(type, callback);
    }
  }

  close() {
    this.readyState = EventSource.CLOSED;
    webf.invokeModule('EventSource', 'close', this.id);
    delete esClientMap[this.id];
    delete namedListenersMap[this.id];
  }
}

webf.addWebfModuleListener('EventSource', function (event: any, data: string) {
  // For named SSE events, data is encoded as "clientId\nnamedEventType".
  // For standard events (open, error, message), data is just the clientId.
  let clientId = data;
  let namedEventType = '';
  const nlIdx = data.indexOf('\n');
  if (nlIdx !== -1) {
    clientId = data.substring(0, nlIdx);
    namedEventType = data.substring(nlIdx + 1);
  }

  const client = esClientMap[clientId];
  if (client) {
    switch (event.type) {
      case 'open':
        client.readyState = EventSource.OPEN;
        break;
      case 'error':
        if (client.readyState !== EventSource.CLOSED) {
          client.readyState = EventSource.CONNECTING;
        }
        break;
    }

    if (namedEventType) {
      // Named SSE events arrive as MessageEvent with type='message' from the
      // bridge (to preserve .data). The bridge cannot create a MessageEvent
      // with a non-standard type, and event.type is read-only on the JS side.
      // Dispatch directly to stored named listeners.
      const listeners = namedListenersMap[clientId]?.[namedEventType];
      if (listeners) {
        for (let i = 0; i < listeners.length; i++) {
          listeners[i](event);
        }
      }
    } else {
      client.dispatchEvent(event);
    }
  }
});
