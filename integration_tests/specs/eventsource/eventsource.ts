describe('EventSource', () => {
  const SSE_BASE = `http://localhost:${location.port}/sse`;

  it('should have correct static constants', () => {
    expect(EventSource.CONNECTING).toBe(0);
    expect(EventSource.OPEN).toBe(1);
    expect(EventSource.CLOSED).toBe(2);
  });

  it('should have correct instance constants', () => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    expect(es.CONNECTING).toBe(0);
    expect(es.OPEN).toBe(1);
    expect(es.CLOSED).toBe(2);
    es.close();
  });

  it('should set url and withCredentials', () => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    expect(es.url).toBe(`${SSE_BASE}/basic`);
    expect(es.withCredentials).toBe(false);
    es.close();
  });

  it('should set withCredentials from init dict', () => {
    const es = new EventSource(`${SSE_BASE}/basic`, { withCredentials: true });
    expect(es.withCredentials).toBe(true);
    es.close();
  });

  it('should start in CONNECTING state', () => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    expect(es.readyState).toBe(EventSource.CONNECTING);
    es.close();
  });

  it('should transition to OPEN on connection', (done) => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    es.onopen = () => {
      expect(es.readyState).toBe(EventSource.OPEN);
      es.close();
      done();
    };
  });

  it('should transition to CLOSED after close()', (done) => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    es.onopen = () => {
      es.close();
      expect(es.readyState).toBe(EventSource.CLOSED);
      done();
    };
  });

  it('should receive basic messages via onmessage', (done) => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    const received: string[] = [];

    es.onmessage = (event: MessageEvent) => {
      received.push(event.data);
      if (received.length === 3) {
        expect(received[0]).toBe('hello');
        expect(received[1]).toBe('world');
        expect(received[2]).toBe('done');
        es.close();
        done();
      }
    };
  });

  it('should receive messages via addEventListener', (done) => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    const received: string[] = [];

    es.addEventListener('message', ((event: MessageEvent) => {
      received.push(event.data);
      if (received.length === 3) {
        expect(received[0]).toBe('hello');
        expect(received[1]).toBe('world');
        expect(received[2]).toBe('done');
        es.close();
        done();
      }
    }) as EventListener);
  });

  it('should receive named events', (done) => {
    const es = new EventSource(`${SSE_BASE}/named-events`);
    const updates: string[] = [];
    const alerts: string[] = [];
    const messages: string[] = [];

    es.addEventListener('update', ((event: MessageEvent) => {
      updates.push(event.data);
      checkDone();
    }) as EventListener);

    es.addEventListener('alert', ((event: MessageEvent) => {
      alerts.push(event.data);
      checkDone();
    }) as EventListener);

    es.onmessage = (event: MessageEvent) => {
      messages.push(event.data);
      checkDone();
    };

    function checkDone() {
      if (updates.length === 1 && alerts.length === 1 && messages.length === 1) {
        expect(updates[0]).toBe('first-update');
        expect(alerts[0]).toBe('important-alert');
        expect(messages[0]).toBe('default-message');
        es.close();
        done();
      }
    }
  });

  it('should handle multi-line data fields', (done) => {
    const es = new EventSource(`${SSE_BASE}/multiline`);
    es.onmessage = (event: MessageEvent) => {
      expect(event.data).toBe('line1\nline2');
      es.close();
      done();
    };
  });

  it('should ignore comment lines', (done) => {
    const es = new EventSource(`${SSE_BASE}/comments`);
    es.onmessage = (event: MessageEvent) => {
      // Only real data should arrive, comments are ignored
      expect(event.data).toBe('after-comment');
      es.close();
      done();
    };
  });

  it('should fire error event when connection closes', (done) => {
    const es = new EventSource(`${SSE_BASE}/immediate-close`);

    es.onerror = () => {
      // readyState should be CONNECTING (reconnecting) or CLOSED
      expect(es.readyState).not.toBe(EventSource.OPEN);
      es.close();
      done();
    };
  });

  it('should fire error when connecting to invalid endpoint', (done) => {
    const es = new EventSource('http://127.0.0.1:1/nonexistent');
    es.onerror = () => {
      es.close();
      done();
    };
  });

  it('should throw SyntaxError for invalid URL scheme', () => {
    expect(() => {
      new EventSource('ftp://example.com/stream');
    }).toThrow();
  });

  it('should not receive events after close()', (done) => {
    const es = new EventSource(`${SSE_BASE}/basic`);
    let receivedAfterClose = false;

    es.onopen = () => {
      es.close();

      es.onmessage = () => {
        receivedAfterClose = true;
      };
    };

    // Wait a bit to ensure no late events arrive
    setTimeout(() => {
      expect(receivedAfterClose).toBe(false);
      done();
    }, 500);
  });
});
