import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoTextFormFieldRow,
  FlutterCupertinoTextFormFieldRowElement,
  FlutterCupertinoFormSection,
} from '@openwebf/react-cupertino-ui';
import { WebFSlot } from '../../components/WebFSlot';

export const CupertinoTextFormFieldRowPage: React.FC = () => {
  const [accountName, setAccountName] = useState('');
  const [boundValue, setBoundValue] = useState('Initial row value');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [numberValue, setNumberValue] = useState('');
  const [maxValue, setMaxValue] = useState('');
  const [profileName, setProfileName] = useState('');
  const [profileEmail, setProfileEmail] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [eventLog, setEventLog] = useState<string[]>([]);

  const rowRef = useRef<FlutterCupertinoTextFormFieldRowElement>(null);

  const addEventLog = (message: string) => {
    setEventLog((prev) => [message, ...prev].slice(0, 5));
  };

  const handleEmailBlur = () => {
    if (profileEmail && !profileEmail.includes('@')) {
      setEmailError('Invalid email address');
    } else {
      setEmailError(null);
    }
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">
            Cupertino TextFormFieldRow
          </h1>
          <p className="text-fg-secondary mb-6">
            Inline, borderless Cupertino text field embedded inside a form row.
          </p>

          {/* Quick Start */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
            <p className="text-fg-secondary mb-4">
              Use <code>FlutterCupertinoTextFormFieldRow</code> to render a single-line borderless text field as part of
              an iOS-style form row.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-2xl overflow-hidden">
                <FlutterCupertinoTextFormFieldRow
                  val={accountName}
                  placeholder="Enter account name"
                  onInput={(event) => setAccountName(event.detail)}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Account</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>
              </div>
              <div className="mt-3 text-sm text-fg-secondary">
                Current name: <span className="font-mono">{accountName || '(empty)'}</span>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`import { useState } from 'react';
import { FlutterCupertinoTextFormFieldRow } from '@openwebf/react-cupertino-ui';

export function AccountNameRow() {
  const [name, setName] = useState('');

  return (
    <FlutterCupertinoTextFormFieldRow
      val={name}
      placeholder="Enter account name"
      onInput={(event) => setName(event.detail)}
    >
      <span slotName="prefix">Account</span>
    </FlutterCupertinoTextFormFieldRow>
  );
}`}</code>
              </pre>
            </div>
          </section>

          {/* Props & Types */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Props & Types</h2>
            <p className="text-fg-secondary mb-4">
              Configure the inline text field via <code>val</code>, <code>placeholder</code>, <code>type</code>,{' '}
              <code>maxlength</code>, <code>disabled</code>, <code>autofocus</code>, <code>clearable</code>, and{' '}
              <code>readonly</code>.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
              <div className="bg-white rounded-2xl overflow-hidden divide-y divide-gray-200">
                <FlutterCupertinoTextFormFieldRow
                  val={boundValue}
                  placeholder="Bound value"
                  onInput={(event) => setBoundValue(event.detail)}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Bound</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <FlutterCupertinoTextFormFieldRow
                  type="email"
                  val={email}
                  placeholder="name@example.com"
                  onInput={(event) => setEmail(event.detail)}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Email</span>
                  </WebFSlot>
                  <WebFSlot name="helper">
                    <span className="block mt-1 text-xs text-gray-500">
                      We will send a confirmation link.
                    </span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <FlutterCupertinoTextFormFieldRow
                  type="password"
                  val={password}
                  placeholder="Password"
                  onInput={(event) => setPassword(event.detail)}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Password</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <FlutterCupertinoTextFormFieldRow
                  type="number"
                  val={numberValue}
                  placeholder="123"
                  onInput={(event) => setNumberValue(event.detail)}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Number</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <FlutterCupertinoTextFormFieldRow
                  maxlength={50}
                  val={maxValue}
                  placeholder="Max 50 characters"
                  onInput={(event) => setMaxValue(event.detail)}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">MaxLen</span>
                  </WebFSlot>
                  <WebFSlot name="helper">
                    <span className="block mt-1 text-xs text-gray-500">
                      {maxValue.length}/50 characters
                    </span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <FlutterCupertinoTextFormFieldRow
                  val="Disabled row"
                  placeholder="Disabled"
                  disabled
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Disabled</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <FlutterCupertinoTextFormFieldRow
                  val="Read-only value"
                  placeholder="Read-only"
                  readonly
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Read-only</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>
              </div>

              <div className="text-xs text-fg-secondary">
                Bound value: <span className="font-mono">{boundValue}</span>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoTextFormFieldRow
  val={value}
  placeholder="Enter value"
  type="text"        // 'text' | 'password' | 'number' | 'tel' | 'email' | 'url'
  disabled={false}
  autofocus={false}
  maxlength={50}
  readonly={false}
>
  <span slotName="prefix">Label</span>
  <span slotName="helper">Helper text below the field.</span>
  <span slotName="error">Error message when invalid.</span>
</FlutterCupertinoTextFormFieldRow>`}</code>
              </pre>
            </div>
          </section>

          {/* Slots */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Slots</h2>
            <p className="text-fg-secondary mb-4">
              Use <code>prefix</code>, <code>helper</code>, and <code>error</code> slots to add labels and supporting
              text around the inline field.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-2xl overflow-hidden">
                <FlutterCupertinoTextFormFieldRow placeholder="Email">
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Email</span>
                  </WebFSlot>
                  <WebFSlot name="helper">
                    <span className="block mt-1 text-xs text-gray-500">
                      We will send a confirmation link.
                    </span>
                  </WebFSlot>
                  <WebFSlot name="error">
                    <span className="block mt-1 text-xs text-red-600">
                      Invalid email address
                    </span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoTextFormFieldRow placeholder="Email">
  <span slotName="prefix">Email</span>
  <span slotName="helper">We will send a confirmation link.</span>
  <span slotName="error">Invalid email address</span>
</FlutterCupertinoTextFormFieldRow>`}</code>
              </pre>
            </div>
          </section>

          {/* Events */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Events</h2>
            <p className="text-fg-secondary mb-4">
              The row exposes the same event hooks as <code>FlutterCupertinoInput</code> for text changes and focus.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-2xl overflow-hidden">
                <FlutterCupertinoTextFormFieldRow
                  placeholder="Username"
                  clearable
                  onInput={(event) => addEventLog(`input: "${event.detail}"`)}
                  onSubmit={(event) => addEventLog(`submit: "${event.detail}"`)}
                  onFocus={() => addEventLog('focus')}
                  onBlur={() => addEventLog('blur')}
                  onClear={() => addEventLog('clear')}
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Username</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>
              </div>

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

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoTextFormFieldRow
  onInput={(event) => {
    console.log('input', event.detail);
  }}
  onSubmit={(event) => {
    console.log('submit', event.detail);
  }}
  onFocus={() => console.log('focus')}
  onBlur={() => console.log('blur')}
  onClear={() => console.log('cleared')}
>
  <span slotName="prefix">Username</span>
</FlutterCupertinoTextFormFieldRow>`}</code>
              </pre>
            </div>
          </section>

          {/* Imperative API */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>
            <p className="text-fg-secondary mb-4">
              Obtain a ref to the row element to programmatically <code>focus()</code>, <code>blur()</code>, or{' '}
              <code>clear()</code> the inner text field.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-2xl overflow-hidden p-4 space-y-3">
                <FlutterCupertinoTextFormFieldRow
                  ref={rowRef}
                  placeholder="Imperative control"
                >
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Name</span>
                  </WebFSlot>
                </FlutterCupertinoTextFormFieldRow>

                <div className="flex flex-wrap gap-2">
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors"
                    onClick={() => rowRef.current?.focus()}
                  >
                    Focus
                  </button>
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors"
                    onClick={() => rowRef.current?.blur()}
                  >
                    Blur
                  </button>
                  <button
                    className="px-3 py-1.5 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600 transition-colors"
                    onClick={() => rowRef.current?.clear()}
                  >
                    Clear
                  </button>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`const rowRef = useRef<FlutterCupertinoTextFormFieldRowElement>(null);

// Focus the field in the row
rowRef.current?.focus();

// Blur the field
rowRef.current?.blur();

// Clear the field
rowRef.current?.clear();

<FlutterCupertinoTextFormFieldRow
  ref={rowRef}
  placeholder="Imperative control"
>
  <span slotName="prefix">Name</span>
</FlutterCupertinoTextFormFieldRow>`}</code>
              </pre>
            </div>
          </section>

          {/* Usage with Form Sections */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage with Form Sections</h2>
            <p className="text-fg-secondary mb-4">
              Combine <code>FlutterCupertinoTextFormFieldRow</code> with <code>FlutterCupertinoFormSection</code> to
              build fully Cupertino-style forms.
            </p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-2xl overflow-hidden">
                <FlutterCupertinoFormSection insetGrouped>
                  <WebFSlot name="header">
                    <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase">
                      Profile
                    </div>
                  </WebFSlot>

                  <FlutterCupertinoTextFormFieldRow
                    placeholder="Full name"
                    val={profileName}
                    onInput={(event) => setProfileName(event.detail)}
                  >
                    <WebFSlot name="prefix">
                      <span className="text-sm text-gray-700">Name</span>
                    </WebFSlot>
                  </FlutterCupertinoTextFormFieldRow>

                  <FlutterCupertinoTextFormFieldRow
                    placeholder="Email"
                    val={profileEmail}
                    onInput={(event) => setProfileEmail(event.detail)}
                    onBlur={handleEmailBlur}
                  >
                    <WebFSlot name="prefix">
                      <span className="text-sm text-gray-700">Email</span>
                    </WebFSlot>
                    <WebFSlot name="helper">
                      <span className="block mt-1 text-xs text-gray-500">
                        We will send a confirmation link.
                      </span>
                    </WebFSlot>
                    {emailError && (
                      <WebFSlot name="error">
                        <span className="block mt-1 text-xs text-red-600">{emailError}</span>
                      </WebFSlot>
                    )}
                  </FlutterCupertinoTextFormFieldRow>
                </FlutterCupertinoFormSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoFormSection insetGrouped>
  <span slotName="header">Profile</span>

  <FlutterCupertinoTextFormFieldRow placeholder="Full name">
    <span slotName="prefix">Name</span>
  </FlutterCupertinoTextFormFieldRow>

  <FlutterCupertinoTextFormFieldRow placeholder="Email">
    <span slotName="prefix">Email</span>
  </FlutterCupertinoTextFormFieldRow>
</FlutterCupertinoFormSection>`}</code>
              </pre>
            </div>
          </section>

          {/* Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded space-y-2 text-sm text-gray-700">
              <p>
                <code>FlutterCupertinoTextFormFieldRow</code> migrates Flutter&apos;s{' '}
                <code>CupertinoTextFormFieldRow</code> into a single WebF custom element, combining form row layout and
                a borderless <code>CupertinoTextField</code>.
              </p>
              <p>
                For more advanced validation or mixed content, you can still use{' '}
                <code>FlutterCupertinoFormRow</code> with <code>FlutterCupertinoInput</code> and manage validation in
                your own application logic.
              </p>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
