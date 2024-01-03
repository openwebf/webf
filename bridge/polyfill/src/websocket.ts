/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import {webf} from './webf';

function validateUrl(url: string) {
  let protocol = url.substring(0, url.indexOf(':'));
  if (protocol !== 'ws' && protocol !== 'wss') {
    throw new Error(`Failed to construct 'WebSocket': The URL's scheme must be either 'ws' or 'wss'. '${protocol}' is not allowed.`);
  }
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

var ReadyState = Object.create(null);
(function (ReadyState) {
  ReadyState[ReadyState["CONNECTING"] = 0] = "CONNECTING";
  ReadyState[ReadyState["OPEN"] = 1] = "OPEN";
  ReadyState[ReadyState["CLOSING"] = 2] = "CLOSING";
  ReadyState[ReadyState["CLOSED"] = 3] = "CLOSED";
})(ReadyState || (ReadyState = {}));

var BinaryType = Object.create(null);
(function (BinaryType) {
  BinaryType["blob"] = "blob";
  BinaryType["arraybuffer"] = "arraybuffer";
})(BinaryType || (BinaryType = {}));

const wsClientMap = {};

function dispatchWebSocketEvent(clientId: string, event: any) {
  let client = wsClientMap[clientId];
  if (client) {
    let readyState = client.readyState;
    switch (event.type) {
      case 'open':
        readyState = ReadyState.OPEN;
        break;
      case 'close':
        readyState = ReadyState.CLOSED;
        break;
      case 'error':
        readyState = ReadyState.CLOSED;
        let connectionStatus = '';
        switch (readyState) {
          case ReadyState.CLOSED: {
            connectionStatus = 'closed';
            break;
          }
          case ReadyState.OPEN: {
            connectionStatus = 'establishment';
            break;
          }
          case ReadyState.CONNECTING: {
            connectionStatus = 'establishment';
            break;
          }
        }
        console.error('WebSocket connection to \'' + client.url + '\' failed: ' +
          'Error in connection ' + connectionStatus + ': ' + event.error);
        break;
    }
    client.readyState = readyState;
    client.dispatchEvent(event);
  }
}

const builtInEvents$1 = [
  'open', 'close', 'message', 'error'
];

export class WebSocket extends EventTarget {
  CONNECTING: string;
  OPEN: string;
  CLOSING: string;
  CLOSED: string;
  extensions: string;
  protocol: string;
  binaryType: string;
  url: string;
  readyState: string;
  id: string;

  constructor(url: string, protocol: string) {
    // @ts-ignore
    super();
    this.CONNECTING = ReadyState.CONNECTING;
    this.OPEN = ReadyState.OPEN;
    this.CLOSING = ReadyState.CLOSING;
    this.CLOSED = ReadyState.CLOSED;
    this.extensions = ''; // TODO add extensions support
    this.protocol = ''; // TODO add protocol support
    this.binaryType = BinaryType.blob;
    // verify url schema
    validateUrl(url);
    this.url = url;
    this.readyState = ReadyState.CONNECTING;
    this.id = webf.invokeModule('WebSocket', 'init', url);
    wsClientMap[this.id] = this;
    initPropertyHandlersForEventTargets(this, builtInEvents$1);
  }

  addEventListener(type: string, callback: EventListener | EventListenerObject) {
    webf.invokeModule('WebSocket', 'addEvent', ([this.id, type]));
    super.addEventListener(type, callback);
  }

  // TODO add blob arrayBuffer ArrayBufferView format support
  send(message: string) {
    webf.invokeModule('WebSocket', 'send', ([this.id, message]));
  }

  close(code: string, reason: string) {
    this.readyState = ReadyState.CLOSING;
    webf.invokeModule('WebSocket', 'close', ([this.id, code, reason]));
  }
}

webf.addWebfModuleListener('WebSocket', function (event, data) {
  dispatchWebSocketEvent(data, event);
});
