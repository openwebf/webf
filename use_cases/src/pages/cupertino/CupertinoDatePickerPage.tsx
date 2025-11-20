import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoDatePicker,
  FlutterCupertinoDatePickerElement,
} from '@openwebf/react-cupertino-ui';

export const CupertinoDatePickerPage: React.FC = () => {
  const [dateTimeValue, setDateTimeValue] = useState<string | null>(null);
  const [dateValue, setDateValue] = useState<string | null>(null);
  const [timeValue, setTimeValue] = useState<string | null>(null);
  const [monthYearValue, setMonthYearValue] = useState<string | null>(null);
  const [eventLog, setEventLog] = useState<string[]>([]);

  const pickerRef = useRef<FlutterCupertinoDatePickerElement>(null);

  const formatDisplay = (value: string | null) => value ?? '(none)';

  const today = new Date();
  const minDate = new Date(today.getFullYear() - 1, 0, 1);
  const maxDate = new Date(today.getFullYear() + 1, 11, 31);

  const addEventLog = (message: string) => {
    setEventLog((prev) => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Date Picker</h1>
        <p className="text-fg-secondary mb-6">
          iOS-style date &amp; time picker backed by Flutter&apos;s <code>CupertinoDatePicker</code>.
        </p>

        {/* Quick Start (Date & Time) */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
          <p className="text-fg-secondary mb-4">
            Use <code>FlutterCupertinoDatePicker</code> with <code>mode=&quot;dateAndTime&quot;</code> and bind{' '}
            <code>value</code> to an ISO8601 string (for example, <code>Date.toISOString()</code>).
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
            <div className="bg-white rounded-2xl overflow-hidden p-4">
              <FlutterCupertinoDatePicker
                mode="dateAndTime"
                style={{ height: 220 }}
                value={dateTimeValue ?? new Date().toISOString()}
                onChange={(event) => setDateTimeValue(event.detail)}
              />
            </div>
            <div className="mt-3 text-sm text-fg-secondary">
              Selected:{' '}
              <span className="font-mono break-all">{formatDisplay(dateTimeValue)}</span>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
            <pre className="text-sm overflow-x-auto">
              <code>{`import { useState } from 'react';
import { FlutterCupertinoDatePicker } from '@openwebf/react-cupertino-ui';

export function DatePickerExample() {
  const [value, setValue] = useState<string | null>(null);

  return (
    <div>
      <FlutterCupertinoDatePicker
        mode="dateAndTime"
        value={value ?? new Date().toISOString()}
        onChange={(event) => setValue(event.detail)}
      />
      <div className="mt-2 text-sm text-gray-700">
        Selected: <code>{value ?? '(none)'}</code>
      </div>
    </div>
  );
}`}</code>
            </pre>
          </div>
        </section>

        {/* Modes & Constraints */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Modes &amp; Constraints</h2>
          <p className="text-fg-secondary mb-4">
            Configure the picker with different <code>mode</code> values, minimum/maximum dates, year bounds, and
            minute intervals.
          </p>

          {/* Date Only */}
          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
            <h3 className="text-sm font-semibold text-fg-primary mb-2">Date Only</h3>
            <p className="text-xs text-fg-secondary mb-3">
              Use <code>mode=&quot;date&quot;</code> together with <code>minimumDate</code>,{' '}
              <code>maximumDate</code>, <code>minimumYear</code>, <code>maximumYear</code>, and{' '}
              <code>showDayOfWeek</code>.
            </p>

            <div className="bg-white rounded-2xl overflow-hidden p-4">
              <FlutterCupertinoDatePicker
                mode="date"
                minimumDate={minDate.toISOString()}
                maximumDate={maxDate.toISOString()}
                minimumYear={2000}
                maximumYear={2030}
                showDayOfWeek
                style={{ height: 220 }}
                value={dateValue ?? today.toISOString()}
                onChange={(event) => setDateValue(event.detail)}
              />
            </div>
            <div className="mt-3 text-sm text-fg-secondary">
              Selected date:{' '}
              <span className="font-mono break-all">{formatDisplay(dateValue)}</span>
            </div>
          </div>

          {/*/!* Time Only *!/*/}
          {/*<div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">*/}
          {/*  <h3 className="text-sm font-semibold text-fg-primary mb-2">Time Only</h3>*/}
          {/*  <p className="text-xs text-fg-secondary mb-3">*/}
          {/*    Use <code>mode=&quot;time&quot;</code> with <code>minuteInterval</code> and{' '}*/}
          {/*    <code>use24H</code> for time-only pickers.*/}
          {/*  </p>*/}

          {/*  <div className="bg-white rounded-2xl overflow-hidden p-4">*/}
          {/*    <FlutterCupertinoDatePicker*/}
          {/*      mode="time"*/}
          {/*      minuteInterval={5}*/}
          {/*      use24H*/}
          {/*      style={{ height: 220 }}*/}
          {/*      value={timeValue ?? today.toISOString()}*/}
          {/*      onChange={(event) => setTimeValue(event.detail)}*/}
          {/*    />*/}
          {/*  </div>*/}
          {/*  <div className="mt-3 text-sm text-fg-secondary">*/}
          {/*    Selected time:{' '}*/}
          {/*    <span className="font-mono break-all">{formatDisplay(timeValue)}</span>*/}
          {/*  </div>*/}
          {/*</div>*/}

          {/*/!* Month & Year *!/*/}
          {/*<div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">*/}
          {/*  <h3 className="text-sm font-semibold text-fg-primary mb-2">Month &amp; Year</h3>*/}
          {/*  <p className="text-xs text-fg-secondary mb-3">*/}
          {/*    Use <code>mode=&quot;monthYear&quot;</code> to let users pick just month and year, with optional year*/}
          {/*    bounds.*/}
          {/*  </p>*/}

          {/*  <div className="bg-white rounded-2xl overflow-hidden p-4">*/}
          {/*    <FlutterCupertinoDatePicker*/}
          {/*      mode="monthYear"*/}
          {/*      minimumYear={2000}*/}
          {/*      maximumYear={2030}*/}
          {/*      style={{ height: 220 }}*/}
          {/*      value={monthYearValue ?? today.toISOString()}*/}
          {/*      onChange={(event) => setMonthYearValue(event.detail)}*/}
          {/*    />*/}
          {/*  </div>*/}
          {/*  <div className="mt-3 text-sm text-fg-secondary">*/}
          {/*    Selected month/year:{' '}*/}
          {/*    <span className="font-mono break-all">{formatDisplay(monthYearValue)}</span>*/}
          {/*  </div>*/}
          {/*</div>*/}

{/*          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">*/}
{/*            <pre className="text-sm overflow-x-auto">*/}
{/*              <code>{`<FlutterCupertinoDatePicker*/}
{/*  mode="dateAndTime"  // 'time' | 'date' | 'dateAndTime' | 'monthYear'*/}
{/*  minimumDate="2024-01-01T00:00:00.000Z"*/}
{/*  maximumDate="2025-12-31T23:59:59.000Z"*/}
{/*  minimumYear={2000}*/}
{/*  maximumYear={2030}*/}
{/*  minuteInterval={5}*/}
{/*  use24H*/}
{/*  showDayOfWeek*/}
{/*  value={currentIsoString}*/}
{/*/>`}</code>*/}
{/*            </pre>*/}
{/*          </div>*/}
        </section>

{/*        /!* Events *!/*/}
{/*        <section className="mb-8">*/}
{/*          <h2 className="text-xl font-semibold text-fg-primary mb-3">Events</h2>*/}
{/*          <p className="text-fg-secondary mb-4">*/}
{/*            Listen to <code>onChange</code> to react whenever the selected date or time changes. The{' '}*/}
{/*            <code>event.detail</code> is always an ISO8601 string.*/}
{/*          </p>*/}

{/*          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">*/}
{/*            <div className="bg-white rounded-2xl overflow-hidden p-4 space-y-3">*/}
{/*              <FlutterCupertinoDatePicker*/}
{/*                mode="dateAndTime"*/}
{/*                style={{ height: 220 }}*/}
{/*                value={dateTimeValue ?? today.toISOString()}*/}
{/*                onChange={(event) => {*/}
{/*                  setDateTimeValue(event.detail);*/}
{/*                  addEventLog(`change: ${event.detail}`);*/}
{/*                }}*/}
{/*              />*/}

{/*              {eventLog.length > 0 && (*/}
{/*                <div className="mt-3 p-3 bg-gray-50 rounded-lg">*/}
{/*                  <div className="text-sm font-semibold mb-2">Event Log (last 5 events):</div>*/}
{/*                  <div className="space-y-1">*/}
{/*                    {eventLog.map((log, idx) => (*/}
{/*                      <div key={idx} className="text-xs font-mono text-gray-700 break-all">*/}
{/*                        {log}*/}
{/*                      </div>*/}
{/*                    ))}*/}
{/*                  </div>*/}
{/*                </div>*/}
{/*              )}*/}
{/*            </div>*/}
{/*          </div>*/}

{/*          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">*/}
{/*            <pre className="text-sm overflow-x-auto">*/}
{/*              <code>{`<FlutterCupertinoDatePicker*/}
{/*  onChange={(event) => {*/}
{/*    // event.detail is an ISO8601 DateTime string*/}
{/*    console.log('change', event.detail);*/}
{/*  }}*/}
{/*/>`}</code>*/}
{/*            </pre>*/}
{/*          </div>*/}
{/*        </section>*/}

{/*        /!* Imperative API *!/*/}
{/*        <section className="mb-8">*/}
{/*          <h2 className="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>*/}
{/*          <p className="text-fg-secondary mb-4">*/}
{/*            Use a ref to call <code>setValue(isoString)</code> and update the picker programmatically.*/}
{/*          </p>*/}

{/*          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">*/}
{/*            <div className="bg-white rounded-2xl overflow-hidden p-4 space-y-3">*/}
{/*              <FlutterCupertinoDatePicker*/}
{/*                ref={pickerRef}*/}
{/*                mode="dateAndTime"*/}
{/*                style={{ height: 220 }}*/}
{/*                value={dateTimeValue ?? today.toISOString()}*/}
{/*                onChange={(event) => setDateTimeValue(event.detail)}*/}
{/*              />*/}

{/*              <div className="flex flex-wrap gap-2">*/}
{/*                <button*/}
{/*                  className="px-3 py-1.5 text-sm rounded-lg bg-blue-500 text-white hover:bg-blue-600 transition-colors"*/}
{/*                  onClick={() => {*/}
{/*                    const nextYear = new Date(today.getFullYear() + 1, 0, 1).toISOString();*/}
{/*                    pickerRef.current?.setValue(nextYear);*/}
{/*                    setDateTimeValue(nextYear);*/}
{/*                  }}*/}
{/*                >*/}
{/*                  Jump to Jan 1 next year*/}
{/*                </button>*/}
{/*                <button*/}
{/*                  className="px-3 py-1.5 text-sm rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors"*/}
{/*                  onClick={() => {*/}
{/*                    const now = new Date().toISOString();*/}
{/*                    pickerRef.current?.setValue(now);*/}
{/*                    setDateTimeValue(now);*/}
{/*                  }}*/}
{/*                >*/}
{/*                  Reset to now*/}
{/*                </button>*/}
{/*              </div>*/}
{/*            </div>*/}
{/*          </div>*/}

{/*          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">*/}
{/*            <pre className="text-sm overflow-x-auto">*/}
{/*              <code>{`const pickerRef = useRef<FlutterCupertinoDatePickerElement | null>(null);*/}

{/*// Set the current value programmatically*/}
{/*pickerRef.current?.setValue(new Date(2025, 0, 1).toISOString());*/}

{/*<FlutterCupertinoDatePicker ref={pickerRef} />`}</code>*/}
{/*            </pre>*/}
{/*          </div>*/}
{/*        </section>*/}

{/*        /!* Styling *!/*/}
{/*        <section className="mb-8">*/}
{/*          <h2 className="text-xl font-semibold text-fg-primary mb-3">Styling</h2>*/}
{/*          <p className="text-fg-secondary mb-4">*/}
{/*            Control the overall picker size by applying <code>width</code> / <code>height</code> via{' '}*/}
{/*            <code>style</code> or <code>className</code>. If omitted, the intrinsic Cupertino height is used.*/}
{/*          </p>*/}

{/*          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">*/}
{/*            <div className="bg-white rounded-2xl overflow-hidden p-4">*/}
{/*              <FlutterCupertinoDatePicker*/}
{/*                mode="date"*/}
{/*                style={{ height: 220 }}*/}
{/*                value={dateValue ?? today.toISOString()}*/}
{/*                onChange={(event) => setDateValue(event.detail)}*/}
{/*              />*/}
{/*            </div>*/}
{/*            <div className="mt-3 text-sm text-fg-secondary">*/}
{/*              This example constrains the picker height to <code>220</code> logical pixels.*/}
{/*            </div>*/}
{/*          </div>*/}

{/*          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">*/}
{/*            <pre className="text-sm overflow-x-auto">*/}
{/*              <code>{`<FlutterCupertinoDatePicker*/}
{/*  mode="date"*/}
{/*  style={{*/}
{/*    height: 220,*/}
{/*  }}*/}
{/*/>`}</code>*/}
{/*            </pre>*/}
{/*          </div>*/}
{/*        </section>*/}

{/*        /!* Notes *!/*/}
{/*        <section className="mb-8">*/}
{/*          <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes</h2>*/}
{/*          <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded space-y-2 text-sm text-gray-700">*/}
{/*            <p>*/}
{/*              <code>FlutterCupertinoDatePicker</code> migrates Flutter&apos;s <code>CupertinoDatePicker</code> into a*/}
{/*              WebF custom element that always works with ISO8601 string values.*/}
{/*            </p>*/}
{/*            <p>*/}
{/*              For time-only pickers, use <code>mode=&quot;time&quot;</code> and parse <code>event.detail</code> in your*/}
{/*              application logic as needed.*/}
{/*            </p>*/}
{/*            <p>*/}
{/*              Use <code>minuteInterval</code> to limit selections to specific steps (e.g., 5 minutes) and specify{' '}*/}
{/*              <code>minimumDate</code> / <code>maximumDate</code> when you need bounded ranges.*/}
{/*            </p>*/}
{/*          </div>*/}
{/*        </section>*/}
      </WebFListView>
    </div>
  );
};
