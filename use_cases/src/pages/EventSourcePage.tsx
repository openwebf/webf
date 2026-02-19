import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

interface SSEMessage {
  id: string;
  type: string;
  data: string;
  time: string;
}

export const EventSourcePage: React.FC = () => {
  const [endpoint, setEndpoint] = useState('https://stream.wikimedia.org/v2/stream/recentchange');
  const [status, setStatus] = useState<'disconnected' | 'connecting' | 'connected'>('disconnected');
  const [messages, setMessages] = useState<SSEMessage[]>([]);
  const [messageCount, setMessageCount] = useState(0);
  const esRef = useRef<EventSource | null>(null);
  const countRef = useRef(0);

  const appendMessage = (type: string, data: string) => {
    countRef.current += 1;
    setMessageCount(countRef.current);
    setMessages((prev) => {
      const next = [
        ...prev,
        {
          id: String(countRef.current),
          type,
          data: data.length > 300 ? data.substring(0, 300) + '...' : data,
          time: new Date().toLocaleTimeString(),
        },
      ];
      // Keep last 50 messages to avoid memory growth
      return next.length > 50 ? next.slice(-50) : next;
    });
  };

  const connect = () => {
    if (status !== 'disconnected') return;
    setStatus('connecting');
    setMessages([]);
    countRef.current = 0;
    setMessageCount(0);

    try {
      const es = new EventSource(endpoint);
      esRef.current = es;

      es.onopen = () => {
        setStatus('connected');
        appendMessage('system', 'Connection opened');
      };

      es.onmessage = (e: MessageEvent) => {
        appendMessage('message', String(e.data));
      };

      es.onerror = () => {
        if (es.readyState === EventSource.CLOSED) {
          setStatus('disconnected');
          appendMessage('system', 'Connection closed');
        } else {
          appendMessage('system', 'Connection error, reconnecting...');
        }
      };
    } catch (e: any) {
      setStatus('disconnected');
      appendMessage('system', `Connection error: ${e?.message ?? e}`);
    }
  };

  const disconnect = () => {
    esRef.current?.close();
    esRef.current = null;
    setStatus('disconnected');
    appendMessage('system', 'Disconnected by user');
  };

  useEffect(() => {
    return () => {
      esRef.current?.close();
    };
  }, []);

  // --- Custom Event Demo ---
  const [customEndpoint, setCustomEndpoint] = useState('');
  const [customStatus, setCustomStatus] = useState<'disconnected' | 'connecting' | 'connected'>('disconnected');
  const [customMessages, setCustomMessages] = useState<SSEMessage[]>([]);
  const [customEventName, setCustomEventName] = useState('update');
  const customEsRef = useRef<EventSource | null>(null);
  const customCountRef = useRef(0);

  const appendCustomMessage = (type: string, data: string) => {
    customCountRef.current += 1;
    setCustomMessages((prev) => {
      const next = [
        ...prev,
        {
          id: String(customCountRef.current),
          type,
          data: data.length > 300 ? data.substring(0, 300) + '...' : data,
          time: new Date().toLocaleTimeString(),
        },
      ];
      return next.length > 50 ? next.slice(-50) : next;
    });
  };

  const connectCustom = () => {
    if (customStatus !== 'disconnected' || !customEndpoint) return;
    setCustomStatus('connecting');
    setCustomMessages([]);
    customCountRef.current = 0;

    try {
      const es = new EventSource(customEndpoint);
      customEsRef.current = es;

      es.onopen = () => {
        setCustomStatus('connected');
        appendCustomMessage('system', 'Connection opened');
      };

      es.onmessage = (e: MessageEvent) => {
        appendCustomMessage('message', String(e.data));
      };

      // Listen for the custom named event
      es.addEventListener(customEventName, ((e: MessageEvent) => {
        appendCustomMessage(customEventName, String(e.data));
      }) as EventListener);

      es.onerror = () => {
        if (es.readyState === EventSource.CLOSED) {
          setCustomStatus('disconnected');
          appendCustomMessage('system', 'Connection closed');
        } else {
          appendCustomMessage('system', 'Reconnecting...');
        }
      };
    } catch (e: any) {
      setCustomStatus('disconnected');
      appendCustomMessage('system', `Error: ${e?.message ?? e}`);
    }
  };

  const disconnectCustom = () => {
    customEsRef.current?.close();
    customEsRef.current = null;
    setCustomStatus('disconnected');
    appendCustomMessage('system', 'Disconnected by user');
  };

  useEffect(() => {
    return () => {
      customEsRef.current?.close();
    };
  }, []);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
        <h1 className="text-2xl font-semibold text-fg-primary mb-4">EventSource (SSE)</h1>
        <p className="text-fg-secondary mb-6">
          Server-Sent Events allow a server to push real-time updates to the client over HTTP.
        </p>

        {/* Section 1: Basic SSE */}
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <h2 className="text-lg font-medium text-fg-primary mb-1">Live Stream</h2>
          <p className="text-sm text-fg-secondary mb-3">
            Connect to a public SSE endpoint to receive real-time events.
          </p>

          <label className="text-sm text-fg-secondary">Endpoint</label>
          <input
            className="w-full rounded border border-line px-3 py-2 bg-surface mt-1"
            value={endpoint}
            onChange={(e) => setEndpoint(e.target.value)}
          />

          <div className="mt-3 flex space-x-2">
            {status !== 'connected' && (
              <button
                className="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700"
                onClick={connect}
              >
                {status === 'connecting' ? 'Connecting...' : 'Connect'}
              </button>
            )}
            {status === 'connected' && (
              <button
                className="px-4 py-2 rounded border border-line hover:bg-surface-hover"
                onClick={disconnect}
              >
                Disconnect
              </button>
            )}
            <div className="ml-auto flex items-center gap-3 text-sm text-fg-secondary">
              <span>Messages: {messageCount}</span>
              <span
                className={`inline-block w-2 h-2 rounded-full ${
                  status === 'connected'
                    ? 'bg-emerald-500'
                    : status === 'connecting'
                    ? 'bg-yellow-500'
                    : 'bg-neutral-400'
                }`}
              />
              {status}
            </div>
          </div>
        </div>

        {/* Message log */}
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <h2 className="text-lg font-medium text-fg-primary mb-2">Event Log</h2>
          <WebFListView className="text-sm h-64 overflow-auto rounded border border-line p-2 bg-surface">
            {messages.length === 0 ? (
              <div className="text-fg-secondary">No events received yet. Connect to start streaming.</div>
            ) : (
              messages.map((m, index) => (
                <div key={index} className="mb-1">
                  <span className="text-fg-secondary">{m.time}</span>{' '}
                  <span
                    className={`px-1 rounded text-xs font-semibold ${
                      m.type === 'system'
                        ? 'bg-blue-100 text-blue-700'
                        : 'bg-emerald-100 text-emerald-700'
                    }`}
                  >
                    {m.type}
                  </span>{' '}
                  <span className="text-fg-primary">{m.data}</span>
                </div>
              ))
            )}
          </WebFListView>
        </div>

        {/* Section 2: Custom Event Name */}
        <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
          <h2 className="text-lg font-medium text-fg-primary mb-1">Named Events</h2>
          <p className="text-sm text-fg-secondary mb-3">
            SSE supports named events (e.g. <code>event: update</code>). Enter your own endpoint
            and event name to listen for specific event types.
          </p>

          <label className="text-sm text-fg-secondary">Endpoint</label>
          <input
            className="w-full rounded border border-line px-3 py-2 bg-surface mt-1"
            placeholder="https://your-sse-server.com/events"
            value={customEndpoint}
            onChange={(e) => setCustomEndpoint(e.target.value)}
          />

          <label className="text-sm text-fg-secondary mt-2 block">Event Name</label>
          <input
            className="w-full rounded border border-line px-3 py-2 bg-surface mt-1"
            value={customEventName}
            onChange={(e) => setCustomEventName(e.target.value)}
          />

          <div className="mt-3 flex space-x-2">
            {customStatus !== 'connected' && (
              <button
                className="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60"
                onClick={connectCustom}
                disabled={!customEndpoint}
              >
                {customStatus === 'connecting' ? 'Connecting...' : 'Connect'}
              </button>
            )}
            {customStatus === 'connected' && (
              <button
                className="px-4 py-2 rounded border border-line hover:bg-surface-hover"
                onClick={disconnectCustom}
              >
                Disconnect
              </button>
            )}
            <div className="ml-auto text-sm text-fg-secondary">
              <span
                className={`inline-block w-2 h-2 rounded-full mr-1 ${
                  customStatus === 'connected'
                    ? 'bg-emerald-500'
                    : customStatus === 'connecting'
                    ? 'bg-yellow-500'
                    : 'bg-neutral-400'
                }`}
              />
              {customStatus}
            </div>
          </div>

          <div className="mt-3 text-sm h-48 overflow-auto rounded border border-line p-2 bg-surface">
            {customMessages.length === 0 ? (
              <div className="text-fg-secondary">No events yet.</div>
            ) : (
              customMessages.map((m) => (
                <div key={m.id} className="mb-1">
                  <span className="text-fg-secondary">{m.time}</span>{' '}
                  <span
                    className={`px-1 rounded text-xs font-semibold ${
                      m.type === 'system'
                        ? 'bg-blue-100 text-blue-700'
                        : m.type === 'message'
                        ? 'bg-emerald-100 text-emerald-700'
                        : 'bg-purple-100 text-purple-700'
                    }`}
                  >
                    {m.type}
                  </span>{' '}
                  <span className="text-fg-primary">{m.data}</span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* API Reference */}
        <div className="bg-surface-secondary border border-line rounded-xl p-4">
          <h2 className="text-lg font-medium text-fg-primary mb-2">API Reference</h2>
          <pre className="text-sm bg-surface border border-line rounded p-3 overflow-auto">
{`// Basic usage
const es = new EventSource('https://api.example.com/stream');

es.onopen = () => console.log('Connected');
es.onmessage = (e) => console.log('Data:', e.data);
es.onerror = () => console.log('Error / reconnecting');

// Listen for named events
es.addEventListener('update', (e) => {
  console.log('Update event:', e.data);
});

// Close when done
es.close();

// Read-only properties
es.url;             // The endpoint URL
es.readyState;      // 0=CONNECTING, 1=OPEN, 2=CLOSED
es.withCredentials; // Whether cross-origin credentials are sent`}
          </pre>
        </div>
      </WebFListView>
    </div>
  );
};
