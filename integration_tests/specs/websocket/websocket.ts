describe('WebSocket', () => {
  it('closed before create connection', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    ws.onopen = () => {
      throw new Error('should not connected');
    };
    ws.onerror = () => {
      throw new Error('connection failed');
    };
    ws.onclose = () => {
      done();
    };
    ws.close();
  });

  it('send and receive', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    ws.onopen = () => {
      ws.send('helloworld');
    };
    let index = 0;
    ws.onmessage = (event) => {
      if (index === 0) {
        expect(event.data).toBe('something');
      } else if (index === 1) {
        expect(event.data).toBe('receive: helloworld');
        done();
      }
      index++;
    }
  });

  it('trigger on error when failed connection', (done) => {
    let ws = new WebSocket('ws://127.0.0.1');
    ws.onerror = () => {
      done();
    };
    ws.onmessage = () => {
      throw new Error('should not connected');
    };
    ws.onopen = () => {
      throw new Error('should not be opened');
    };
  });

  it('trigger on onerror when server shutdown', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT'] + 1}`);
    ws.onclose = () => {
      done();
    };
    ws.onerror = () => {
      done();
    };
  });

  // Regression test: verify that open/message/close events are correctly
  // dispatched after removing the Dart-side _listenMap gate.
  // Previously, addEventListener called invokeModule('WebSocket', 'addEvent')
  // to register interest in Dart; now Dart fires unconditionally and the
  // JS-side EventTarget handles dispatch filtering.

  it('open event fires when listener registered via onopen property', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    ws.onopen = () => {
      expect(ws.readyState).toBe(1); // WebSocket.OPEN = 1
      ws.close();
      done();
    };
  });

  it('open event fires when listener registered via addEventListener', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    ws.addEventListener('open', () => {
      expect(ws.readyState).toBe(1); // WebSocket.OPEN = 1
      ws.close();
      done();
    });
  });

  it('no open event fired when no listener registered', (done) => {
    // Dart now fires open unconditionally; without a JS listener nothing
    // should throw and the connection should still close cleanly.
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    // Intentionally no onopen listener
    ws.onclose = () => {
      done();
    };
    setTimeout(() => {
      ws.close();
    }, 100);
  });

  it('message event fires after open without addEvent gate', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    ws.onopen = () => {
      ws.send('ping');
    };
    ws.onmessage = (event) => {
      // Server sends 'something' on connect, then echoes 'receive: ping'
      if (event.data === 'receive: ping') {
        ws.close();
        done();
      }
    };
  });

  it('close event fires after connection closed', (done) => {
    let ws = new WebSocket(`ws://127.0.0.1:${window['WEBSOCKET_PORT']}`);
    ws.onopen = () => {
      ws.close();
    };
    ws.onclose = (event) => {
      expect(ws.readyState).toBe(3); // WebSocket.CLOSED = 3
      done();
    };
  });
});
