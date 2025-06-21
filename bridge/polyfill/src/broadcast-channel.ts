/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

export interface BroadcastChannelInterface extends EventTarget {
  readonly name: string;
  postMessage(message: any): void;
  close(): void;
  
  addEventListener(type: string, callback: EventListener | EventListenerObject): void;
  removeEventListener(type: string, callback: EventListener | EventListenerObject): void;
  dispatchEvent(event: Event): boolean;
}

function initPropertyHandlersForEventTargets(eventTarget: any, builtInEvents: string[]) {
  var _loop_1 = function (i: number) {
    var eventName = builtInEvents[i];
    var propertyName = 'on' + eventName;
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
  };
  for (var i = 0; i < builtInEvents.length; i++) {
    _loop_1(i);
  }
}

const builtInEvents = [
  'message', 'messageerror'
];

export class BroadcastChannel extends EventTarget implements BroadcastChannelInterface {
  readonly name: string;
  private _closed: boolean = false;

  constructor(name: string) {
    // @ts-ignore
    super();
    this.name = name;
    initPropertyHandlersForEventTargets(this, builtInEvents);
  }

  postMessage(message: any): void {
    if (this._closed) {
      throw new DOMException('BroadcastChannel is closed', 'InvalidStateError');
    }
    // Mock implementation - no actual broadcasting
  }

  close(): void {
    this._closed = true;
  }

  addEventListener(type: string, callback: EventListener | EventListenerObject) {
    super.addEventListener(type, callback);
  }
}