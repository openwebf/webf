import React, { useMemo, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

function tryBtoa(input: string): string {
  try { return btoa(input); } catch (e: any) { return `Error: ${e?.message ?? e}`; }
}
function tryAtob(input: string): string {
  try { return atob(input); } catch (e: any) { return `Error: ${e?.message ?? e}`; }
}

export const UrlEncodingPage: React.FC = () => {
  // URL Builder/Parser
  const [base, setBase] = useState('https://www.example.com');
  const [path, setPath] = useState('/path');
  const [query, setQuery] = useState('foo=bar&wd=Hello👿World');
  const [hash, setHash] = useState('#section');

  const url = useMemo(() => {
    try {
      const u = new URL(base);
      // Force pathname
      u.pathname = path || '/';
      // Apply search
      u.search = '';
      if (query) {
        const usp = new URLSearchParams(query);
        u.search = usp.toString() ? `?${usp.toString()}` : '';
      }
      u.hash = hash || '';
      return u;
    } catch (e) {
      return null;
    }
  }, [base, path, query, hash]);

  // Base64
  const [plain, setPlain] = useState('Hello, WebF!');
  const enc = tryBtoa(plain);
  const [cipher, setCipher] = useState('SGVsbG8sIFdlYkYh');
  const dec = tryAtob(cipher);

  // TextEncoder
  const [text, setText] = useState('🙂 café 你好');
  const encoded = useMemo(() => Array.from(new TextEncoder().encode(text)), [text]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">URL & Encoding</h1>
          <p className="text-fg-secondary mb-4">Demonstrations for URL, Base64 and TextEncoder.</p>

          {/* URL */}
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-3">URL Builder</h2>
            <div className="space-y-3">
              <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={base} onChange={(e) => setBase(e.target.value)} />
              <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={path} onChange={(e) => setPath(e.target.value)} />
              <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={query} onChange={(e) => setQuery(e.target.value)} />
              <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={hash} onChange={(e) => setHash(e.target.value)} />
            </div>
            <div className="mt-4">
              {url ? (
                <div className="text-sm">
                  <div className="mb-2"><span className="font-medium">href:</span> {url.href}</div>
                  <div className="flex flex-wrap -mx-2">
                    <div className="w-full md:w-1/2 px-2 mb-1"><span className="font-medium">origin:</span> {url.origin}</div>
                    <div className="w-full md:w-1/2 px-2 mb-1"><span className="font-medium">host:</span> {url.host}</div>
                    <div className="w-full md:w-1/2 px-2 mb-1"><span className="font-medium">pathname:</span> {url.pathname}</div>
                    <div className="w-full md:w-1/2 px-2 mb-1"><span className="font-medium">search:</span> {url.search}</div>
                    <div className="w-full md:w-1/2 px-2 mb-1"><span className="font-medium">hash:</span> {url.hash}</div>
                  </div>
                </div>
              ) : (
                <div className="text-sm text-red-600">Invalid URL</div>
              )}
            </div>
          </div>

          {/* Base64 */}
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <h2 className="text-lg font-medium text-fg-primary mb-3">Base64</h2>
            <div className="md:flex md:space-x-3 space-y-3 md:space-y-0">
              <div className="flex-1">
                <label className="text-sm text-fg-secondary">Input</label>
                <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={plain} onChange={(e) => setPlain(e.target.value)} />
                <div className="mt-2 text-sm break-all"><span className="font-medium">btoa:</span> {enc}</div>
              </div>
              <div className="flex-1">
                <label className="text-sm text-fg-secondary">Base64</label>
                <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={cipher} onChange={(e) => setCipher(e.target.value)} />
                <div className="mt-2 text-sm break-all"><span className="font-medium">atob:</span> {dec}</div>
              </div>
            </div>
          </div>

          {/* TextEncoder */}
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-3">TextEncoder (UTF-8)</h2>
            <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={text} onChange={(e) => setText(e.target.value)} />
            <div className="mt-3 text-sm break-all">{JSON.stringify(encoded)}</div>
          </div>
      </WebFListView>
    </div>
  );
};
