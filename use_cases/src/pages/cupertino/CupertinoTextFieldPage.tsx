import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoInput,
  FlutterCupertinoInputElement,
} from '@openwebf/react-cupertino-ui';
import { WebFSlot } from '../../components/WebFSlot';

export const CupertinoTextFieldPage: React.FC = () => {
  const [basicValue, setBasicValue] = useState('');
  const [boundValue, setBoundValue] = useState('Initial input content');
  const [passwordValue, setPasswordValue] = useState('');
  const [emailValue, setEmailValue] = useState('');
  const [numberValue, setNumberValue] = useState('');
  const [maxValue, setMaxValue] = useState('');
  const [disabledValue] = useState('Disabled input');
  const [readonlyValue] = useState('Read-only value');
  const [eventValue, setEventValue] = useState('');
  const [eventLog, setEventLog] = useState<string[]>([]);

  const imperativeRef = useRef<FlutterCupertinoInputElement>(null);

  const addEventLog = (message: string) => {
    setEventLog((prev) => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">
            Cupertino Text Field
          </h1>
          <p className="text-fg-secondary mb-6">
            iOS-style single-line text input backed by Flutter&apos;s <code>CupertinoTextField</code>.
          </p>

          {/* Quick Start */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
            <p className="text-fg-secondary mb-4">
              Bind <code>val</code> to React state and handle <code>onInput</code> to keep the value in sync.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-4">
                <FlutterCupertinoInput
                  val={basicValue}
                  placeholder="Enter content"
                  onInput={(event) => setBasicValue(event.detail)}
                />
                <div className="text-sm text-fg-secondary">
                  Current value: <span className="font-mono">{basicValue || '(empty)'}</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`import { useState } from 'react';
import { FlutterCupertinoInput } from '@openwebf/react-cupertino-ui';

export function InputExample() {
  const [value, setValue] = useState('Initial input content');

  return (
    <FlutterCupertinoInput
      val={value}
      placeholder="Enter content"
      onInput={(event) => setValue(event.detail)}
    />
  );
}`}</code>
              </pre>
            </div>
          </section>

          {/* Types & Basic Props */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Types & Basic Props</h2>
            <p className="text-fg-secondary mb-4">
              Use the <code>type</code> prop to control keyboard and obfuscation behavior. Other props like{' '}
              <code>disabled</code>, <code>autofocus</code>, <code>clearable</code>, <code>maxlength</code>, and{' '}
              <code>readonly</code> mirror common HTML input attributes.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
              <div>
                <div className="text-sm font-semibold text-fg-primary mb-2">Controlled Value</div>
                <FlutterCupertinoInput
                  val={boundValue}
                  placeholder="Enter content"
                  onInput={(event) => setBoundValue(event.detail)}
                />
                <div className="mt-2 text-xs text-fg-secondary">
                  Bound value: <span className="font-mono">{boundValue}</span>
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <div className="text-sm font-semibold text-fg-primary mb-1">Password</div>
                  <FlutterCupertinoInput
                    type="password"
                    val={passwordValue}
                    placeholder="Enter password"
                    clearable
                    onInput={(event) => setPasswordValue(event.detail)}
                  />
                </div>

                <div>
                  <div className="text-sm font-semibold text-fg-primary mb-1">Email</div>
                  <FlutterCupertinoInput
                    type="email"
                    val={emailValue}
                    placeholder="name@example.com"
                    onInput={(event) => setEmailValue(event.detail)}
                  />
                </div>

                <div>
                  <div className="text-sm font-semibold text-fg-primary mb-1">Number</div>
                  <FlutterCupertinoInput
                    type="number"
                    val={numberValue}
                    placeholder="123"
                    onInput={(event) => setNumberValue(event.detail)}
                  />
                  <div className="mt-1 text-xs text-fg-secondary">
                    Parse <code>val</code> as needed in your app.
                  </div>
                </div>

                <div>
                  <div className="text-sm font-semibold text-fg-primary mb-1">Disabled / Read-only</div>
                  <div className="space-y-2">
                    <FlutterCupertinoInput
                      val={disabledValue}
                      placeholder="Disabled"
                      disabled
                    />
                    <FlutterCupertinoInput
                      val={readonlyValue}
                      placeholder="Read-only"
                      readonly
                    />
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoInput
  val={value}
  placeholder="Enter content"
  type="text"           // 'text' | 'password' | 'number' | 'tel' | 'email' | 'url'
  disabled={false}
  autofocus={false}
  clearable
  maxlength={10}
  readonly={false}
/>`}</code>
              </pre>
            </div>
          </section>

          {/* Prefix & Suffix Slots */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Prefix & Suffix</h2>
            <p className="text-fg-secondary mb-4">
              Add leading or trailing content using <code>prefix</code> and <code>suffix</code> slots—great for currency
              symbols, units, or domains.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
              <div>
                <div className="text-sm font-semibold text-fg-primary mb-1">Amount with Prefix</div>
                <FlutterCupertinoInput placeholder="Amount">
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">$</span>
                  </WebFSlot>
                </FlutterCupertinoInput>
              </div>

              <div>
                <div className="text-sm font-semibold text-fg-primary mb-1">Domain with Suffix</div>
                <FlutterCupertinoInput placeholder="Domain" style={{ marginTop: 12 }}>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-500">https://</span>
                  </WebFSlot>
                  <WebFSlot name="suffix">
                    <span className="text-sm text-gray-500">.com</span>
                  </WebFSlot>
                </FlutterCupertinoInput>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoInput placeholder="Amount">
  <span slotName="prefix">$</span>
</FlutterCupertinoInput>

<FlutterCupertinoInput placeholder="Domain" style={{ marginTop: 12 }}>
  <span slotName="prefix">https://</span>
  <span slotName="suffix">.com</span>
</FlutterCupertinoInput>`}</code>
              </pre>
            </div>
          </section>

          {/* Clearable & Max Length */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Clearable & Max Length</h2>
            <p className="text-fg-secondary mb-4">
              Show a clear button while editing and enforce a maximum number of characters via{' '}
              <code>clearable</code> and <code>maxlength</code>.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
              <div>
                <div className="text-sm font-semibold text-fg-primary mb-1">Clearable Field</div>
                <FlutterCupertinoInput
                  clearable
                  val={eventValue}
                  placeholder="Try typing, then tap clear"
                  onInput={(event) => setEventValue(event.detail)}
                  onClear={() => addEventLog('onClear fired')}
                />
              </div>

              <div>
                <div className="text-sm font-semibold text-fg-primary mb-1">Max Length (10)</div>
                <FlutterCupertinoInput
                  maxlength={10}
                  clearable
                  val={maxValue}
                  placeholder="Max 10 characters"
                  onInput={(event) => setMaxValue(event.detail)}
                />
                <div className="mt-1 text-xs text-fg-secondary">
                  {maxValue.length}/10 characters
                </div>
              </div>
            </div>
          </section>

          {/* Events */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Events</h2>
            <p className="text-fg-secondary mb-4">
              Listen to <code>onInput</code>, <code>onSubmit</code>, <code>onFocus</code>,{' '}
              <code>onBlur</code>, and <code>onClear</code> for full control over user interaction.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4">
                <FlutterCupertinoInput
                  placeholder="Type and press Enter"
                  clearable
                  onInput={(event) => {
                    addEventLog(`input: "${event.detail}"`);
                  }}
                  onSubmit={(event) => addEventLog(`submit: "${event.detail}"`)}
                  onFocus={() => addEventLog('focus')}
                  onBlur={() => addEventLog('blur')}
                  onClear={() => addEventLog('clear')}
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
                <code>{`<FlutterCupertinoInput
  onInput={(event) => {
    // event.detail is the current string value
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
              Use a ref to call <code>focus()</code>, <code>blur()</code>, and <code>clear()</code> on the underlying
              WebF element.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <FlutterCupertinoInput
                  ref={imperativeRef}
                  placeholder="Imperative control"
                  clearable
                />
                <div className="flex flex-wrap gap-2">
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors"
                    onClick={() => {
                      console.log('call focus', imperativeRef.current);
                      imperativeRef.current?.focus();
                    }}
                  >
                    Focus
                  </button>
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors"
                    onClick={() => imperativeRef.current?.blur()}
                  >
                    Blur
                  </button>
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600 transition-colors"
                    onClick={() => imperativeRef.current?.clear()}
                  >
                    Clear
                  </button>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`const inputRef = useRef<FlutterCupertinoInputElement>(null);

// Focus the field
inputRef.current?.focus();

// Blur the field
inputRef.current?.blur();

// Clear the field
inputRef.current?.clear();

<FlutterCupertinoInput ref={inputRef} placeholder="Imperative control" />`}</code>
              </pre>
            </div>
          </section>

          {/* Styling */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Styling</h2>
            <p className="text-fg-secondary mb-4">
              The input respects common CSS properties applied to the host element, such as height, padding,
              border-radius, background color, and text alignment.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-4 space-y-3">
                <FlutterCupertinoInput
                  placeholder="Custom styles"
                  className="custom-cupertino-input-demo"
                />
                <p className="text-xs text-fg-secondary">
                  The <code>custom-cupertino-input-demo</code> class can set height, padding, radius, and text-align.
                </p>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoInput
  placeholder="Custom styles"
  className="custom-input"
/>`}</code>
              </pre>
              <pre className="text-sm overflow-x-auto mt-3">
                <code>{`.custom-input {
  height: 56px;
  border-radius: 20px;
  padding: 0 20px;
  text-align: right;
}`}</code>
              </pre>
            </div>
          </section>

          {/* Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded space-y-2 text-sm text-gray-700">
              <p>
                <code>FlutterCupertinoInput</code> migrates Flutter&apos;s <code>CupertinoTextField</code> into a WebF
                custom element, keeping iOS look-and-feel.
              </p>
              <p>
                For numeric input, keep <code>val</code> as a string and convert to numbers in your application logic as
                needed.
              </p>
              <p>
                When used inside <code>FlutterCupertinoFormRow</code>, place the input as the default child and use row
                slots for labels and helper/error text.
              </p>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
