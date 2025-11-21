import React, { useMemo, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

function setCookie(name: string, value: string, days?: number, path: string = '/') {
  let cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)}; path=${path}`;
  if (typeof days === 'number') {
    const d = new Date();
    d.setTime(d.getTime() + days * 24 * 60 * 60 * 1000);
    cookie += `; expires=${d.toUTCString()}`;
  }
  document.cookie = cookie;
}

function deleteCookie(name: string, path: string = '/') {
  document.cookie = `${encodeURIComponent(name)}=; path=${path}; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
}

function parseCookies(): Record<string, string> {
  return document.cookie
    .split(';')
    .map((c) => c.trim())
    .filter(Boolean)
    .reduce((acc, part) => {
      const eq = part.indexOf('=');
      if (eq >= 0) {
        const k = decodeURIComponent(part.slice(0, eq));
        const v = decodeURIComponent(part.slice(eq + 1));
        acc[k] = v;
      }
      return acc;
    }, {} as Record<string, string>);
}

export const CookiesPage: React.FC = () => {
  const [name, setName] = useState('name');
  const [value, setValue] = useState('webf');
  const [days, setDays] = useState<string>('');
  const [path, setPath] = useState<string>('/');
  const [message, setMessage] = useState<string>('');

  const cookies = useMemo(() => parseCookies(), [message]);

  const onSet = () => {
    const n = name.trim();
    const v = value;
    const d = days.trim() ? Number(days) : undefined;
    if (!n) return;
    setCookie(n, v, d, path || '/');
    setMessage(`Set cookie ${n}`);
  };

  const onDelete = () => {
    const n = name.trim();
    if (!n) return;
    deleteCookie(n, path || '/');
    setMessage(`Deleted cookie ${n}`);
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Cookies</h1>
          <p className="text-fg-secondary mb-4">Read and write cookies via <code>document.cookie</code>.</p>

          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="flex flex-col md:flex-row md:space-x-3 space-y-3 md:space-y-0">
              <input
                className="flex-1 rounded border border-line px-3 py-2 bg-surface"
                placeholder="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
              <input
                className="flex-1 rounded border border-line px-3 py-2 bg-surface"
                placeholder="value"
                value={value}
                onChange={(e) => setValue(e.target.value)}
              />
            </div>
            <div className="mt-3 flex flex-col md:flex-row md:space-x-3 space-y-3 md:space-y-0">
              <input
                className="w-full md:w-40 rounded border border-line px-3 py-2 bg-surface"
                placeholder="days (optional)"
                value={days}
                onChange={(e) => setDays(e.target.value)}
              />
              <input
                className="w-full md:w-40 rounded border border-line px-3 py-2 bg-surface"
                placeholder="path"
                value={path}
                onChange={(e) => setPath(e.target.value)}
              />
            </div>
            <div className="mt-4 flex space-x-2">
              <button className="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700" onClick={onSet}>Set</button>
              <button className="px-4 py-2 rounded border border-line hover:bg-surface-hover" onClick={onDelete}>Delete</button>
            </div>
            {message && <div className="mt-3 text-sm text-fg-secondary">{message}</div>}
          </div>

          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <h2 className="text-lg font-medium text-fg-primary mb-2">Current Cookies</h2>
            <div className="text-sm text-fg-secondary break-all mb-3">{document.cookie || '(empty)'}</div>
            <div className="overflow-auto rounded border border-line">
              <table className="w-full text-sm">
                <thead className="bg-surface-tertiary">
                  <tr>
                    <th className="text-left px-3 py-2 border-b border-line">Name</th>
                    <th className="text-left px-3 py-2 border-b border-line">Value</th>
                  </tr>
                </thead>
                <tbody>
                  {Object.keys(cookies).length === 0 && (
                    <tr>
                      <td className="px-3 py-2" colSpan={2}>No cookies</td>
                    </tr>
                  )}
                  {Object.entries(cookies).map(([k, v]) => (
                    <tr key={k} className="odd:bg-surface">
                      <td className="px-3 py-2 border-b border-line align-top">{k}</td>
                      <td className="px-3 py-2 border-b border-line align-top">{v}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};

