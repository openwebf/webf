/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

// Based on BroadcastChannel polyfill implementation
// Reference: https://github.com/JSmith01/broadcastchannel-polyfill

export interface BroadcastChannelInterface {
  readonly name: string;
  postMessage(message: any): void;
  close(): void;
  onmessage: ((ev: MessageEvent) => any) | null;
  
  addEventListener(type: string, callback: EventListener | EventListenerObject): void;
  removeEventListener(type: string, callback: EventListener | EventListenerObject): void;
  dispatchEvent(event: Event): boolean;
}

// Global channels registry
const channels: { [key: string]: BroadcastChannel[] } = {};

export class BroadcastChannel implements BroadcastChannelInterface {
  private _name: string;
  private _id: string;
  private _closed: boolean = false;
  private _mc: MessageChannel;

  constructor(channel: string) {
    const channelName = String(channel);
    const id = '$BroadcastChannel$' + channelName;

    channels[id] = channels[id] || [];
    channels[id].push(this);

    this._name = channelName;
    this._id = id;
    this._closed = false;
    this._mc = new MessageChannel();
    this._mc.port1.start();
    this._mc.port2.start();

    const $this = this;
    
    // Listen for storage events from other contexts
    if (typeof globalThis.addEventListener !== 'undefined') {
      globalThis.addEventListener('storage', function(e: StorageEvent) {
        if (e.storageArea !== globalThis.localStorage) return;
        if (e.newValue == null || e.newValue === '') return;
        if (e.key && e.key.substring(0, id.length) !== id) return;
        try {
          const data = JSON.parse(e.newValue);
          $this._mc.port2.postMessage(data);
        } catch (err) {
          // Ignore invalid JSON
        }
      });
    }
  }

  get name(): string {
    return this._name;
  }

  postMessage(message: any): void {
    if (this._closed) {
      const e = new Error('BroadcastChannel is closed');
      e.name = 'InvalidStateError';
      throw e;
    }

    const value = JSON.stringify(message);

    // Broadcast to other contexts via localStorage
    if (typeof globalThis.localStorage !== 'undefined') {
      const key = this._id + String(Date.now()) + '$' + String(Math.random());
      try {
        globalThis.localStorage.setItem(key, value);
        setTimeout(() => {
          try {
            globalThis.localStorage.removeItem(key);
          } catch (err) {
            // Ignore storage errors
          }
        }, 500);
      } catch (err) {
        // Ignore storage errors
      }
    }

    // Broadcast to current context via MessageChannel
    const $this = this;
    channels[this._id].forEach(function(bc) {
      if (bc === $this) return;
      try {
        bc._mc.port2.postMessage(JSON.parse(value));
      } catch (err) {
        // Ignore errors
      }
    });
  }

  close(): void {
    if (this._closed) return;
    this._closed = true;
    this._mc.port1.close();
    this._mc.port2.close();

    const index = channels[this._id].indexOf(this);
    if (index > -1) {
      channels[this._id].splice(index, 1);
    }
  }

  // EventTarget API delegation to MessageChannel port
  get onmessage(): ((ev: MessageEvent) => any) | null {
    return this._mc.port1.onmessage as ((ev: MessageEvent) => any) | null;
  }

  set onmessage(value: ((ev: MessageEvent) => any) | null) {
    this._mc.port1.onmessage = value as ((this: MessagePort, ev: MessageEvent) => any) | null;
  }

  addEventListener(type: string, callback: EventListener | EventListenerObject): void {
    return this._mc.port1.addEventListener(type, callback);
  }

  removeEventListener(type: string, callback: EventListener | EventListenerObject): void {
    return this._mc.port1.removeEventListener(type, callback);
  }

  dispatchEvent(event: Event): boolean {
    return this._mc.port1.dispatchEvent(event);
  }
}