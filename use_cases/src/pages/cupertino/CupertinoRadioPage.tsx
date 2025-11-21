import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoRadio, FlutterCupertinoIcon, CupertinoIcons } from '@openwebf/react-cupertino-ui';

type BasicOption = 'one' | 'two' | 'three';
type SizeOption = 'small' | 'medium' | 'large';
type PaymentOption = 'credit' | 'debit' | 'paypal';
type ThemeOption = 'light' | 'dark' | 'auto';

export const CupertinoRadioPage: React.FC = () => {
  const [basicValue, setBasicValue] = useState<BasicOption>('one');
  const [sizeValue, setSizeValue] = useState<SizeOption>('medium');
  const [paymentValue, setPaymentValue] = useState<PaymentOption>('credit');
  const [themeValue, setThemeValue] = useState<ThemeOption>('auto');
  const [toggleableValue, setToggleableValue] = useState<string>('option1');
  const [checkmarkValue, setCheckmarkValue] = useState<string>('check1');
  const [eventValue, setEventValue] = useState<string>('event1');
  const [eventLog, setEventLog] = useState<string[]>([]);

  const addEventLog = (message: string) => {
    setEventLog(prev => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Radio</h1>
          <p className="text-fg-secondary mb-6">macOS-style radio buttons for mutually exclusive selections.</p>

          {/* Basic Radio Group */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Radio Group</h2>
            <p className="text-fg-secondary mb-4">Radio buttons work in groups by sharing the same groupValue.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="space-y-3 mb-4">
                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="one"
                      groupValue={basicValue}
                      onChange={(e) => setBasicValue(e.detail as BasicOption)}
                    />
                    <span className="text-lg">Option One</span>
                  </div>

                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="two"
                      groupValue={basicValue}
                      onChange={(e) => setBasicValue(e.detail as BasicOption)}
                    />
                    <span className="text-lg">Option Two</span>
                  </div>

                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="three"
                      groupValue={basicValue}
                      onChange={(e) => setBasicValue(e.detail as BasicOption)}
                    />
                    <span className="text-lg">Option Three</span>
                  </div>
                </div>
                <div className="text-sm text-gray-600 text-center">
                  Selected: <span className="font-semibold">{basicValue}</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`type Option = 'one' | 'two' | 'three';
const [value, setValue] = useState<Option>('one');

<FlutterCupertinoRadio
  val="one"
  groupValue={value}
  onChange={(e) => setValue(e.detail as Option)}
/>
<FlutterCupertinoRadio
  val="two"
  groupValue={value}
  onChange={(e) => setValue(e.detail as Option)}
/>
<FlutterCupertinoRadio
  val="three"
  groupValue={value}
  onChange={(e) => setValue(e.detail as Option)}
/>`}</code></pre>
            </div>
          </section>

          {/* Disabled State */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
            <p className="text-fg-secondary mb-4">Radio buttons can be disabled to prevent user interaction.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6 space-y-4">
                <div className="flex items-center gap-3">
                  <FlutterCupertinoRadio
                    val="disabled1"
                    groupValue="disabled1"
                    disabled={true}
                  />
                  <span className="text-gray-400">Disabled (Selected)</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoRadio
                    val="disabled2"
                    groupValue="disabled1"
                    disabled={true}
                  />
                  <span className="text-gray-400">Disabled (Unselected)</span>
                </div>

                <div className="text-sm text-gray-600 text-center mt-4">
                  Disabled radio buttons are non-interactive
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoRadio
  val="option"
  groupValue={value}
  disabled={true}
  onChange={(e) => {
    // This will not fire when disabled
    setValue(e.detail);
  }}
/>`}</code></pre>
            </div>
          </section>

          {/* Toggleable Radio */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Toggleable Radio</h2>
            <p className="text-fg-secondary mb-4">When toggleable is true, tapping a selected radio can clear the selection.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="space-y-3 mb-4">
                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="option1"
                      groupValue={toggleableValue}
                      toggleable={true}
                      onChange={(e) => setToggleableValue(e.detail)}
                    />
                    <span className="text-lg">Toggleable Option 1</span>
                  </div>

                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="option2"
                      groupValue={toggleableValue}
                      toggleable={true}
                      onChange={(e) => setToggleableValue(e.detail)}
                    />
                    <span className="text-lg">Toggleable Option 2</span>
                  </div>
                </div>
                <div className="text-sm text-gray-600 text-center">
                  Selected: <span className="font-semibold">{toggleableValue || '(none)'}</span>
                  <div className="text-xs mt-1">Click the selected radio to deselect it</div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [value, setValue] = useState<string>('option1');

<FlutterCupertinoRadio
  val="option1"
  groupValue={value}
  toggleable={true}
  onChange={(e) => {
    // e.detail will be '' (empty string) when deselected
    setValue(e.detail || '');
  }}
/>`}</code></pre>
            </div>
          </section>

          {/* Checkmark Style */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Checkmark Style</h2>
            <p className="text-fg-secondary mb-4">Use checkmark style instead of the default radio UI.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="space-y-3 mb-4">
                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="check1"
                      groupValue={checkmarkValue}
                      useCheckmarkStyle={true}
                      onChange={(e) => setCheckmarkValue(e.detail)}
                    />
                    <span className="text-lg">Checkmark Option 1</span>
                  </div>

                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="check2"
                      groupValue={checkmarkValue}
                      useCheckmarkStyle={true}
                      onChange={(e) => setCheckmarkValue(e.detail)}
                    />
                    <span className="text-lg">Checkmark Option 2</span>
                  </div>

                  <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="check3"
                      groupValue={checkmarkValue}
                      useCheckmarkStyle={true}
                      onChange={(e) => setCheckmarkValue(e.detail)}
                    />
                    <span className="text-lg">Checkmark Option 3</span>
                  </div>
                </div>
                <div className="text-sm text-gray-600 text-center">
                  Selected: <span className="font-semibold">{checkmarkValue}</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoRadio
  val="option1"
  groupValue={value}
  useCheckmarkStyle={true}
  onChange={(e) => setValue(e.detail)}
/>`}</code></pre>
            </div>
          </section>

          {/* Custom Colors */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
            <p className="text-fg-secondary mb-4">Customize radio button colors to match your design system.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6 space-y-4">
                <div className="flex items-center gap-3">
                  <FlutterCupertinoRadio
                    val="red"
                    groupValue="red"
                    activeColor="#FF3B30"
                    fillColor="#FFFFFF"
                  />
                  <span>Red Theme</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoRadio
                    val="green"
                    groupValue="green"
                    activeColor="#34C759"
                    fillColor="#FFFFFF"
                  />
                  <span>Green Theme</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoRadio
                    val="purple"
                    groupValue="purple"
                    activeColor="#5856D6"
                    fillColor="#FFFFFF"
                  />
                  <span>Purple Theme</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoRadio
                    val="orange"
                    groupValue="orange"
                    activeColor="#FF9500"
                    fillColor="#000000"
                  />
                  <span>Orange Theme (Black Fill)</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoRadio
  val="option"
  groupValue={value}
  activeColor="#FF3B30"
  fillColor="#FFFFFF"
  onChange={(e) => setValue(e.detail)}
/>`}</code></pre>
            </div>
          </section>

          {/* Practical Examples */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Practical Examples</h2>
            <p className="text-fg-secondary mb-4">Common use cases for radio buttons in macOS-style interfaces.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden divide-y divide-gray-200">
                {/* Size Selection */}
                <div className="p-4">
                  <div className="font-semibold mb-3">Size Selection</div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="small"
                        groupValue={sizeValue}
                        onChange={(e) => setSizeValue(e.detail as SizeOption)}
                      />
                      <div className="flex-1">
                        <div className="font-medium">Small</div>
                        <div className="text-sm text-gray-600">For compact displays</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="medium"
                        groupValue={sizeValue}
                        onChange={(e) => setSizeValue(e.detail as SizeOption)}
                      />
                      <div className="flex-1">
                        <div className="font-medium">Medium</div>
                        <div className="text-sm text-gray-600">Recommended size</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="large"
                        groupValue={sizeValue}
                        onChange={(e) => setSizeValue(e.detail as SizeOption)}
                      />
                      <div className="flex-1">
                        <div className="font-medium">Large</div>
                        <div className="text-sm text-gray-600">For large displays</div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Payment Method */}
                <div className="p-4">
                  <div className="font-semibold mb-3">Payment Method</div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="credit"
                      groupValue={paymentValue}
                      onChange={(e) => setPaymentValue(e.detail as PaymentOption)}
                    />
                    <div className="flex-1">
                      <div className="font-medium flex items-center gap-2">
                        <FlutterCupertinoIcon type={CupertinoIcons.creditcard_fill} />
                        <span>Credit Card</span>
                      </div>
                        <div className="text-sm text-gray-600">Visa, Mastercard, Amex</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="debit"
                      groupValue={paymentValue}
                      onChange={(e) => setPaymentValue(e.detail as PaymentOption)}
                    />
                    <div className="flex-1">
                      <div className="font-medium flex items-center gap-2">
                        <FlutterCupertinoIcon type={CupertinoIcons.creditcard_fill} />
                        <span>Debit Card</span>
                      </div>
                        <div className="text-sm text-gray-600">Direct bank payment</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                    <FlutterCupertinoRadio
                      val="paypal"
                      groupValue={paymentValue}
                      onChange={(e) => setPaymentValue(e.detail as PaymentOption)}
                    />
                    <div className="flex-1">
                      <div className="font-medium flex items-center gap-2">
                        <FlutterCupertinoIcon type={CupertinoIcons.money_dollar_circle_fill} />
                        <span>PayPal</span>
                      </div>
                        <div className="text-sm text-gray-600">Fast and secure</div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Theme Selection */}
                <div className="p-4">
                  <div className="font-semibold mb-3">Theme Preference</div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="light"
                        groupValue={themeValue}
                        onChange={(e) => setThemeValue(e.detail as ThemeOption)}
                      />
                      <span className="font-medium flex items-center gap-2">
                        <FlutterCupertinoIcon type={CupertinoIcons.sun_max_fill} />
                        <span>Light Mode</span>
                      </span>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="dark"
                        groupValue={themeValue}
                        onChange={(e) => setThemeValue(e.detail as ThemeOption)}
                      />
                      <span className="font-medium flex items-center gap-2">
                        <FlutterCupertinoIcon type={CupertinoIcons.moon_fill} />
                        <span>Dark Mode</span>
                      </span>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="auto"
                        groupValue={themeValue}
                        onChange={(e) => setThemeValue(e.detail as ThemeOption)}
                      />
                      <span className="font-medium flex items-center gap-2">
                        <FlutterCupertinoIcon type={CupertinoIcons.arrow_2_circlepath} />
                        <span>Auto (System)</span>
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`type Size = 'small' | 'medium' | 'large';
const [size, setSize] = useState<Size>('medium');

<FlutterCupertinoRadio
  val="small"
  groupValue={size}
  onChange={(e) => setSize(e.detail as Size)}
/>
<FlutterCupertinoRadio
  val="medium"
  groupValue={size}
  onChange={(e) => setSize(e.detail as Size)}
/>
<FlutterCupertinoRadio
  val="large"
  groupValue={size}
  onChange={(e) => setSize(e.detail as Size)}
/>`}</code></pre>
            </div>
          </section>

          {/* Event Handling */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Event Handling</h2>
            <p className="text-fg-secondary mb-4">Radio buttons fire onChange when selection changes.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="mb-4">
                  <div className="space-y-3 mb-3">
                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="event1"
                        groupValue={eventValue}
                        onChange={(e) => {
                          setEventValue(e.detail);
                          addEventLog(`onChange: selected "${e.detail}"`);
                        }}
                      />
                      <span className="font-semibold">Event Option 1</span>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="event2"
                        groupValue={eventValue}
                        onChange={(e) => {
                          setEventValue(e.detail);
                          addEventLog(`onChange: selected "${e.detail}"`);
                        }}
                      />
                      <span className="font-semibold">Event Option 2</span>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoRadio
                        val="event3"
                        groupValue={eventValue}
                        onChange={(e) => {
                          setEventValue(e.detail);
                          addEventLog(`onChange: selected "${e.detail}"`);
                        }}
                      />
                      <span className="font-semibold">Event Option 3</span>
                    </div>
                  </div>
                  <div className="text-sm text-gray-600 text-center">
                    Click different options to see events below
                  </div>
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
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoRadio
  val="option1"
  groupValue={value}
  onChange={(e) => {
    // e.detail is the new value (string)
    console.log('Selected:', e.detail);
    setValue(e.detail);
  }}
/>`}</code></pre>
            </div>
          </section>

          {/* API Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">API Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">val</code> — Value represented by this radio (string, required)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">groupValue</code> — Current group value controlling which radio is selected (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">disabled</code> — Disables interaction when true (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">toggleable</code> — Allows deselection by tapping selected radio (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">useCheckmarkStyle</code> — Renders in checkmark style instead of radio (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">activeColor</code> — Color when selected (string, default: "#0A84FF")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">inactiveColor</code> — Color when not selected (string, default: "#FFFFFF")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">fillColor</code> — Inner fill color when selected (string, default: "#FFFFFF")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">focusColor</code> — Focus highlight color (string, default: "rgba(10,132,255,0.3)")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">autofocus</code> — Auto-focus on mount (boolean, default: false)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Events</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Fired when selection changes (event: CustomEvent{'<string>'})</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange: e.detail</code> — String value of the new selection, or '' (empty string) when toggleable is true and selection is cleared</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Clear Labels:</strong> Always provide descriptive labels next to radio buttons</li>
                <li><strong>Group Related Options:</strong> Keep radio buttons in logical groups with a shared groupValue</li>
                <li><strong>Limited Options:</strong> Use radio buttons for 2-7 options; consider dropdowns for more</li>
                <li><strong>Default Selection:</strong> Pre-select the most common or recommended option</li>
                <li><strong>Visual Feedback:</strong> Ensure selected state is clearly visible</li>
                <li><strong>Disabled State:</strong> Use disabled state to indicate unavailable options</li>
                <li><strong>Toggleable Use:</strong> Only use toggleable when optional selection makes sense</li>
                <li><strong>Consistent Styling:</strong> Maintain consistent colors and spacing across radio groups</li>
                <li><strong>Touch Targets:</strong> Ensure adequate spacing for easy interaction</li>
                <li><strong>Type Safety:</strong> Use TypeScript union types for radio values</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Group Behavior</h4>
                <p className="text-sm text-fg-secondary">
                  Radio buttons work in groups by sharing the same groupValue. Only the radio whose val matches groupValue will appear selected. All radios in a group should have the same onChange handler that updates the shared groupValue.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Toggleable Behavior</h4>
                <p className="text-sm text-fg-secondary">
                  When toggleable is true, tapping an already selected radio will clear the selection. The onChange event will fire with event.detail === '' (empty string). Use this for optional selections.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Checkmark Style</h4>
                <p className="text-sm text-fg-secondary">
                  When useCheckmarkStyle is true, the radio renders with a checkmark icon instead of the traditional radio dot. This can be useful for iOS-style list selections.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Color Customization</h4>
                <p className="text-sm text-fg-secondary">
                  All color props accept any CSS color format (hex, rgb, rgba, named colors). Use activeColor for the outer ring and fillColor for the inner dot when selected.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Native Styling</h4>
                <p className="text-sm text-fg-secondary">
                  The radio uses native macOS Cupertino styling rendered by Flutter. Animations and interactions match macOS design guidelines.
                </p>
              </div>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Type-Safe Radio Group</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`type Size = 'small' | 'medium' | 'large';
const [size, setSize] = useState<Size>('medium');

const options: Array<{ value: Size; label: string }> = [
  { value: 'small', label: 'Small' },
  { value: 'medium', label: 'Medium' },
  { value: 'large', label: 'Large' }
];

{options.map(opt => (
  <FlutterCupertinoRadio
    key={opt.value}
    val={opt.value}
    groupValue={size}
    onChange={(e) => setSize(e.detail as Size)}
  />
))}`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Form Integration</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [shipping, setShipping] = useState<'standard' | 'express'>('standard');

const handleSubmit = () => {
  const formData = {
    shipping,
    // ... other form fields
  };
  // Submit form
};

<FlutterCupertinoRadio
  val="standard"
  groupValue={shipping}
  onChange={(e) => setShipping(e.detail as 'standard' | 'express')}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Conditional Options</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [method, setMethod] = useState('email');
const isPremiumUser = true;

<FlutterCupertinoRadio
  val="email"
  groupValue={method}
  onChange={(e) => setMethod(e.detail)}
/>

<FlutterCupertinoRadio
  val="sms"
  groupValue={method}
  disabled={!isPremiumUser}
  onChange={(e) => setMethod(e.detail)}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Radio with Description</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div className="flex items-center gap-3">
  <FlutterCupertinoRadio
    val="premium"
    groupValue={plan}
    onChange={(e) => setPlan(e.detail)}
  />
  <div className="flex-1">
    <div className="font-medium">Premium Plan</div>
    <div className="text-sm text-gray-600">
      Unlimited access to all features
    </div>
  </div>
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Toggleable for Optional Selection</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [filter, setFilter] = useState<string>('');

<FlutterCupertinoRadio
  val="active"
  groupValue={filter}
  toggleable={true}
  onChange={(e) => {
    // Clear filter when empty string is returned
    setFilter(e.detail || '');
  }}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Custom Colored Radio Group</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const theme = {
  active: '#FF3B30',
  fill: '#FFFFFF'
};

<FlutterCupertinoRadio
  val="option1"
  groupValue={value}
  activeColor={theme.active}
  fillColor={theme.fill}
  onChange={(e) => setValue(e.detail)}
/>`}</code></pre>
              </div>
            </div>
          </section>

          {/* Accessibility */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Accessibility</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Keyboard Navigation</h4>
                <p className="text-sm text-fg-secondary">
                  Radio buttons support keyboard navigation. Use Tab to move between radio groups and Arrow keys to change selection within a group.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Labels and Descriptions</h4>
                <p className="text-sm text-fg-secondary mb-2">
                  Always provide visible labels next to radio buttons. For complex options, include descriptions to clarify the choice:
                </p>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<label className="flex items-center gap-3 cursor-pointer">
  <FlutterCupertinoRadio
    val="option"
    groupValue={value}
    onChange={(e) => setValue(e.detail)}
  />
  <div>
    <div className="font-medium">Option Name</div>
    <div className="text-sm text-gray-600">Option description</div>
  </div>
</label>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Focus Management</h4>
                <p className="text-sm text-fg-secondary">
                  Use autofocus carefully to improve user experience. Only auto-focus when it makes sense for the user flow.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Color Contrast</h4>
                <p className="text-sm text-fg-secondary">
                  Ensure sufficient color contrast between radio colors and backgrounds. Test with users who have visual impairments.
                </p>
              </div>
            </div>
          </section>

          {/* Radio vs Checkbox */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Radio vs Checkbox</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <h4 className="font-semibold text-fg-primary mb-2">Use Radio When:</h4>
                  <ul className="space-y-2 text-sm text-fg-secondary">
                    <li>User must select exactly one option</li>
                    <li>Options are mutually exclusive</li>
                    <li>Showing all options helps decision</li>
                    <li>2-7 options are available</li>
                    <li>Selection is required</li>
                  </ul>
                </div>
                <div>
                  <h4 className="mt-2 font-semibold text-fg-primary mb-2">Use Checkbox When:</h4>
                  <ul className="space-y-2 text-fg-secondary text-sm">
                    <li>User can select multiple options</li>
                    <li>Each option is independent</li>
                    <li>Selection is optional (on/off state)</li>
                    <li>Acknowledging terms/agreements</li>
                    <li>Toggling features on/off</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
