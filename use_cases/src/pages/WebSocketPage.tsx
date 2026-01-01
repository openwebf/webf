import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const WebSocketPage: React.FC = () => {
  const [endpoint, setEndpoint] = useState('wss://echo.websocket.org');
  const [status, setStatus] = useState<'disconnected'|'connecting'|'connected'>('disconnected');
  const [message, setMessage] = useState('Hello, WebF!');
  const [log, setLog] = useState<string[]>([]);
  const wsRef = useRef<WebSocket | null>(null);

  const appendLog = (line: string) => setLog((prev) => [...prev, `${new Date().toLocaleTimeString()} ${line}`]);

  const connect = () => {
    if (status !== 'disconnected') return;
    setStatus('connecting');
    appendLog(`Connecting to ${endpoint} ...`);
    try {
      const ws = new WebSocket(endpoint);
      wsRef.current = ws;
      ws.onopen = () => { setStatus('connected'); appendLog('Connected'); };
      ws.onmessage = (e) => appendLog(`← ${String(e.data)}`);
      ws.onerror = () => appendLog('Error');
      ws.onclose = () => { setStatus('disconnected'); appendLog('Closed'); };
    } catch (e: any) {
      setStatus('disconnected');
      appendLog(`Connection error: ${e?.message ?? e}`);
    }
  };

  const disconnect = () => {
    wsRef.current?.close();
    wsRef.current = null;
  };

  const send = () => {
    if (status !== 'connected' || !wsRef.current) return;
    wsRef.current.send(message);
    appendLog(`→ ${message}`);
  };

  useEffect(() => () => { wsRef.current?.close(); }, []);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">WebSocket</h1>
          <p className="text-fg-secondary mb-4">Connect to an echo server and exchange messages.</p>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <label className="text-sm text-fg-secondary">Endpoint</label>
            <input className="w-full rounded border border-line px-3 py-2 bg-surface mt-1" value={endpoint} onChange={(e) => setEndpoint(e.target.value)} />
            <div className="mt-3 flex space-x-2">
              {status !== 'connected' && (
                <button className="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700" onClick={connect}>
                  {status === 'connecting' ? 'Connecting...' : 'Connect'}
                </button>
              )}
              {status === 'connected' && (
                <button className="px-4 py-2 rounded border border-line hover:bg-surface-hover" onClick={disconnect}>Disconnect</button>
              )}
              <div className="ml-auto text-sm text-fg-secondary">Status: {status}</div>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Send Message</h2>
            <div className="md:flex md:space-x-3 space-y-3 md:space-y-0">
              <input className="flex-1 rounded border border-line px-3 py-2 bg-surface" value={message} onChange={(e) => setMessage(e.target.value)} />
              <button className="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700" disabled={status !== 'connected'} onClick={send}>Send</button>
            </div>
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Log</h2>
            <div className="text-sm h-64 overflow-auto rounded border border-line p-2 bg-surface">
              {log.length === 0 ? <div className="text-fg-secondary">No messages</div> : log.map((l, i) => (
                <div key={i}>{l}</div>
              ))}
            </div>
          </div>
      </WebFListView>
    </div>
  );
};

