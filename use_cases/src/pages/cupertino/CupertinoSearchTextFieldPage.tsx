import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoSearchTextField,
  FlutterCupertinoSearchTextFieldElement,
} from '@openwebf/react-cupertino-ui';

export const CupertinoSearchTextFieldPage: React.FC = () => {
  const [query, setQuery] = useState('');
  const [settingsQuery, setSettingsQuery] = useState('');
  const [disabledQuery] = useState('Disabled search');
  const [logQuery, setLogQuery] = useState('');
  const [eventLog, setEventLog] = useState<string[]>([]);

  const searchRef = useRef<FlutterCupertinoSearchTextFieldElement>(null);

  const settingsItems = [
    'Wi‑Fi',
    'Bluetooth',
    'Mobile Data',
    'Personal Hotspot',
    'Notifications',
    'Sounds & Haptics',
    'Focus',
    'Screen Time',
    'General',
    'Control Center',
    'Display & Brightness',
    'Home Screen',
  ];

  const filteredSettings = settingsItems.filter((item) =>
    item.toLowerCase().includes(settingsQuery.toLowerCase()),
  );

  const addEventLog = (message: string) => {
    setEventLog((prev) => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">
            Cupertino Search Text Field
          </h1>
          <p className="text-fg-secondary mb-6">
            iOS-style search field backed by Flutter&apos;s <code>CupertinoSearchTextField</code>.
          </p>

          {/* Quick Start */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
            <p className="text-fg-secondary mb-4">
              Bind <code>val</code> to React state and handle <code>onInput</code> for search queries.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <FlutterCupertinoSearchTextField
                  val={query}
                  placeholder="Search"
                  onInput={(event) => setQuery(event.detail)}
                />
                <div className="text-sm text-fg-secondary">
                  Current query: <span className="font-mono">{query || '(empty)'}</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`import { useState } from 'react';
import { FlutterCupertinoSearchTextField } from '@openwebf/react-cupertino-ui';

export function SearchExample() {
  const [query, setQuery] = useState('');

  return (
    <FlutterCupertinoSearchTextField
      val={query}
      placeholder="Search"
      onInput={(event) => setQuery(event.detail)}
    />
  );
}`}</code>
              </pre>
            </div>
          </section>

          {/* Props & Basic Usage */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Props & Basic Usage</h2>
            <p className="text-fg-secondary mb-4">
              Use <code>val</code>, <code>placeholder</code>, <code>disabled</code>, and <code>autofocus</code> to
              control the search field behavior.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <div className="text-sm font-semibold text-fg-primary">Enabled</div>
                <FlutterCupertinoSearchTextField
                  val={settingsQuery}
                  placeholder="Search settings"
                  onInput={(event) => setSettingsQuery(event.detail)}
                />
                <div className="text-xs text-fg-secondary">
                  Showing results for: <span className="font-mono">{settingsQuery || '(all)'}</span>
                </div>

                <div className="mt-2 border-t border-line pt-3 space-y-1 max-h-52 overflow-y-auto">
                  {filteredSettings.length ? (
                    filteredSettings.map((item) => (
                      <div
                        key={item}
                        className="text-sm text-fg-primary px-2 py-1 rounded hover:bg-surface-hover cursor-pointer"
                      >
                        {item}
                      </div>
                    ))
                  ) : (
                    <div className="text-xs text-fg-secondary px-2 py-1">No results found</div>
                  )}
                </div>
              </div>

              <div className="bg-white rounded-lg p-4 space-y-3">
                <div className="text-sm font-semibold text-fg-primary">Disabled & Autofocus</div>
                <FlutterCupertinoSearchTextField
                  val={disabledQuery}
                  placeholder="Disabled search"
                  disabled
                />
                <FlutterCupertinoSearchTextField
                  placeholder="Autofocus example"
                  autofocus={false}
                />
                <div className="text-xs text-fg-secondary">
                  When <code>placeholder</code> is omitted, a localized &quot;Search&quot; label is used.
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoSearchTextField
  val={value}
  placeholder="Search"
  disabled={false}
  autofocus={false}
/>`}</code>
              </pre>
            </div>
          </section>

          {/* Events */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Events</h2>
            <p className="text-fg-secondary mb-4">
              Listen to <code>onInput</code>, <code>onSubmit</code>, <code>onFocus</code>,{' '}
              <code>onBlur</code>, and <code>onClear</code> to react to user interactions.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <FlutterCupertinoSearchTextField
                  val={logQuery}
                  placeholder="Type and press Enter / clear"
                  onInput={(event) => {
                    setLogQuery(event.detail);
                    addEventLog(`input: "${event.detail}"`);
                  }}
                  onSubmit={(event) => addEventLog(`submit: "${event.detail}"`)}
                  onFocus={() => addEventLog('focus')}
                  onBlur={() => addEventLog('blur')}
                  onClear={() => {
                    setLogQuery('');
                    addEventLog('clear');
                  }}
                />

                {eventLog.length > 0 && (
                  <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                    <div className="text-sm font-semibold mb-2">Event Log (last 5 events):</div>
                    <div className="space-y-1">
                      {eventLog.map((log, idx) => (
                        <div key={idx} className="text-xs font-mono text-gray-700">
                          {log}
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoSearchTextField
  onInput={(event) => {
    console.log('input', event.detail);
  }}
  onSubmit={(event) => {
    console.log('submit', event.detail);
  }}
  onFocus={() => console.log('focus')}
  onBlur={() => console.log('blur')}
  onClear={() => console.log('cleared')}
/>`}</code>
              </pre>
            </div>
          </section>

          {/* Imperative API */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>
            <p className="text-fg-secondary mb-4">
              Use a ref to programmatically <code>focus()</code>, <code>blur()</code>, or <code>clear()</code> the
              search field.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <FlutterCupertinoSearchTextField
                  ref={searchRef}
                  placeholder="Imperative control"
                />
                <div className="flex flex-wrap gap-2">
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors"
                    onClick={() => searchRef.current?.focus()}
                  >
                    Focus
                  </button>
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors"
                    onClick={() => searchRef.current?.blur()}
                  >
                    Blur
                  </button>
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600 transition-colors"
                    onClick={() => searchRef.current?.clear()}
                  >
                    Clear
                  </button>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`const searchRef = useRef<FlutterCupertinoSearchTextFieldElement | null>(null);

// Focus the search field
searchRef.current?.focus();

// Blur the search field
searchRef.current?.blur();

// Clear the search field
searchRef.current?.clear();

<FlutterCupertinoSearchTextField ref={searchRef} placeholder="Search..." />`}</code>
              </pre>
            </div>
          </section>

          {/* Styling */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Styling</h2>
            <p className="text-fg-secondary mb-4">
              The search field respects CSS properties applied to the host element, such as padding, background color,
              border radius, and text alignment.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <FlutterCupertinoSearchTextField
                  placeholder="Search settings"
                  style={{
                    margin: 12,
                    backgroundColor: '#f2f3f5',
                    borderRadius: 16,
                  }}
                />
                <p className="text-xs text-fg-secondary">
                  Customize the pill shape and background with <code>style</code> or <code>className</code>.
                </p>
              </div>
            </div>
          </section>

          {/* Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded space-y-2 text-sm text-gray-700">
              <p>
                <code>FlutterCupertinoSearchTextField</code> migrates Flutter&apos;s{' '}
                <code>CupertinoSearchTextField</code> into a WebF custom element with native iOS look and feel.
              </p>
              <p>
                For advanced behaviors (e.g., custom suffix actions), combine this element with your own UI logic and
                clear or update the value via the imperative API.
              </p>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
