import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoCheckbox } from '@openwebf/react-cupertino-ui';

export const CupertinoCheckBoxPage: React.FC = () => {
  const [basicChecked, setBasicChecked] = useState(false);
  const [termsChecked, setTermsChecked] = useState(false);
  const [privacyChecked, setPrivacyChecked] = useState(false);
  const [notificationsChecked, setNotificationsChecked] = useState(true);
  const [emailChecked, setEmailChecked] = useState(false);
  const [smsChecked, setSmsChecked] = useState(true);
  const [pushChecked, setPushChecked] = useState(false);
  const [tristateValue, setTristateValue] = useState<boolean | null>(false);
  const [eventLog, setEventLog] = useState<string[]>([]);
  const [task1, setTask1] = useState(false);
  const [task2, setTask2] = useState(true);
  const [task3, setTask3] = useState(false);

  const addEventLog = (message: string) => {
    setEventLog(prev => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino CheckBox</h1>
          <p className="text-fg-secondary mb-6">iOS-style checkbox for binary or three-state selections.</p>

          {/* Basic Checkbox */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Checkbox</h2>
            <p className="text-fg-secondary mb-4">Simple checkbox with checked/unchecked states.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex items-center gap-3 mb-4">
                  <FlutterCupertinoCheckbox
                    checked={basicChecked}
                    onChange={(e) => setBasicChecked(e.detail)}
                  />
                  <span className="text-lg">
                    {basicChecked ? 'Checked' : 'Unchecked'}
                  </span>
                </div>
                <div className="text-sm text-gray-600 text-center">
                  Click the checkbox to toggle its state
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [checked, setChecked] = useState(false);

<FlutterCupertinoCheckbox
  checked={checked}
  onChange={(e) => setChecked(e.detail)}
/>`}</code></pre>
            </div>
          </section>

          {/* Disabled State */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
            <p className="text-fg-secondary mb-4">Checkboxes can be disabled to prevent user interaction.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6 space-y-4">
                <div className="flex items-center gap-3">
                  <FlutterCupertinoCheckbox
                    checked={false}
                    disabled={true}
                  />
                  <span className="text-gray-400">Disabled (Unchecked)</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoCheckbox
                    checked={true}
                    disabled={true}
                  />
                  <span className="text-gray-400">Disabled (Checked)</span>
                </div>

                <div className="text-sm text-gray-600 text-center mt-4">
                  Disabled checkboxes are non-interactive
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoCheckbox
  checked={true}
  disabled={true}
  onChange={(e) => {
    // This will not fire when disabled
    console.log(e.detail);
  }}
/>`}</code></pre>
            </div>
          </section>

          {/* Tristate Checkbox */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Tristate Checkbox</h2>
            <p className="text-fg-secondary mb-4">Three-state checkbox supporting unchecked, checked, and mixed states.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex items-center gap-3 mb-4">
                  <FlutterCupertinoCheckbox
                    checked={tristateValue}
                    tristate={true}
                    onStatechange={(e) => {
                      const state = e.detail;
                      if (state === 'unchecked') setTristateValue(false);
                      else if (state === 'checked') setTristateValue(true);
                      else if (state === 'mixed') setTristateValue(null);
                    }}
                  />
                  <span className="text-lg font-semibold">
                    State: {tristateValue === null ? 'Mixed' : tristateValue ? 'Checked' : 'Unchecked'}
                  </span>
                </div>
                <div className="text-sm text-gray-600">
                  Click to cycle through: Unchecked → Checked → Mixed → Unchecked
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [value, setValue] = useState<boolean | null>(false);

<FlutterCupertinoCheckbox
  checked={value}
  tristate={true}
  onStatechange={(e) => {
    const state = e.detail;
    if (state === 'unchecked') setValue(false);
    else if (state === 'checked') setValue(true);
    else if (state === 'mixed') setValue(null);
  }}
/>`}</code></pre>
            </div>
          </section>

          {/* Custom Colors */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
            <p className="text-fg-secondary mb-4">Customize checkbox colors to match your design system.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6 space-y-4">
                <div className="flex items-center gap-3">
                  <FlutterCupertinoCheckbox
                    checked={true}
                    activeColor="#FF3B30"
                    checkColor="#FFFFFF"
                  />
                  <span>Red Theme</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoCheckbox
                    checked={true}
                    activeColor="#34C759"
                    checkColor="#FFFFFF"
                  />
                  <span>Green Theme</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoCheckbox
                    checked={true}
                    activeColor="#5856D6"
                    checkColor="#FFFFFF"
                  />
                  <span>Purple Theme</span>
                </div>

                <div className="flex items-center gap-3">
                  <FlutterCupertinoCheckbox
                    checked={true}
                    activeColor="#FF9500"
                    checkColor="#000000"
                  />
                  <span>Orange Theme (Black Check)</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoCheckbox
  checked={true}
  activeColor="#FF3B30"
  checkColor="#FFFFFF"
  fillColorSelected="#FF3B30"
/>

<FlutterCupertinoCheckbox
  checked={true}
  activeColor="#34C759"
  checkColor="#FFFFFF"
/>`}</code></pre>
            </div>
          </section>

          {/* Practical Examples */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Practical Examples</h2>
            <p className="text-fg-secondary mb-4">Common use cases for checkboxes in iOS-style interfaces.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden divide-y divide-gray-200">
                {/* Terms and Conditions */}
                <div className="p-4">
                  <div className="font-semibold mb-3">Agreement Form</div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-3">
                      <FlutterCupertinoCheckbox
                        checked={termsChecked}
                        onChange={(e) => setTermsChecked(!!e.detail)}
                        semanticLabel="Accept terms and conditions"
                      />
                      <div className="flex-1">
                        <div className="font-medium">I accept the Terms and Conditions</div>
                        <div className="text-sm text-gray-600">Required to continue</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoCheckbox
                        checked={privacyChecked}
                        onChange={(e) => setPrivacyChecked(!!e.detail)}
                        semanticLabel="Accept privacy policy"
                      />
                      <div className="flex-1">
                        <div className="font-medium">I accept the Privacy Policy</div>
                        <div className="text-sm text-gray-600">Required to continue</div>
                      </div>
                    </div>

                    <button
                      className={`w-full py-3 rounded-lg font-semibold text-center transition-all duration-200 ${
                        termsChecked && privacyChecked
                          ? 'bg-blue-500 hover:bg-blue-600 text-white shadow-sm hover:shadow-md active:scale-98'
                          : 'bg-gray-200 text-gray-400 cursor-not-allowed opacity-60'
                      }`}
                      disabled={!termsChecked || !privacyChecked}
                    >
                      Continue
                    </button>
                  </div>
                </div>

                {/* Settings */}
                <div className="p-4">
                  <div className="font-semibold mb-3">Notification Settings</div>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-medium">Email Notifications</div>
                        <div className="text-sm text-gray-600">Receive updates via email</div>
                      </div>
                      <FlutterCupertinoCheckbox
                        checked={emailChecked}
                        onChange={(e) => setEmailChecked(e.detail)}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-medium">SMS Notifications</div>
                        <div className="text-sm text-gray-600">Receive updates via SMS</div>
                      </div>
                      <FlutterCupertinoCheckbox
                        checked={smsChecked}
                        onChange={(e) => setSmsChecked(e.detail)}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-medium">Push Notifications</div>
                        <div className="text-sm text-gray-600">Receive push notifications</div>
                      </div>
                      <FlutterCupertinoCheckbox
                        checked={pushChecked}
                        onChange={(e) => setPushChecked(e.detail)}
                      />
                    </div>
                  </div>
                </div>

                {/* Task List */}
                <div className="p-4">
                  <div className="font-semibold mb-3">Task List</div>
                  <div className="space-y-2">
                    <div className="flex items-center gap-3">
                      <FlutterCupertinoCheckbox
                        checked={task1}
                        onChange={(e) => setTask1(e.detail)}
                      />
                      <span className={task1 ? 'line-through text-gray-500' : ''}>
                        Review project documentation
                      </span>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoCheckbox
                        checked={task2}
                        onChange={(e) => setTask2(e.detail)}
                      />
                      <span className={task2 ? 'line-through text-gray-500' : ''}>
                        Complete code review
                      </span>
                    </div>

                    <div className="flex items-center gap-3">
                      <FlutterCupertinoCheckbox
                        checked={task3}
                        onChange={(e) => setTask3(e.detail)}
                      />
                      <span className={task3 ? 'line-through text-gray-500' : ''}>
                        Update test cases
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Terms acceptance
<FlutterCupertinoCheckbox
  checked={termsChecked}
  onChange={(e) => setTermsChecked(e.detail)}
  semanticLabel="Accept terms and conditions"
/>

// Settings toggle
<FlutterCupertinoCheckbox
  checked={emailNotifications}
  onChange={(e) => setEmailNotifications(e.detail)}
/>

// Task list item
<FlutterCupertinoCheckbox
  checked={taskCompleted}
  onChange={(e) => setTaskCompleted(e.detail)}
/>`}</code></pre>
            </div>
          </section>

          {/* Event Handling */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Event Handling</h2>
            <p className="text-fg-secondary mb-4">Checkboxes fire onChange for boolean changes and onStatechange for tristate transitions.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="mb-4">
                  <div className="flex items-center gap-3 mb-2">
                    <FlutterCupertinoCheckbox
                      checked={notificationsChecked}
                      onChange={(e) => {
                        setNotificationsChecked(e.detail);
                        addEventLog(`onChange: ${e.detail}`);
                      }}
                      onStatechange={(e) => {
                        addEventLog(`onStatechange: ${e.detail}`);
                      }}
                    />
                    <span className="font-semibold">
                      Interactive Checkbox
                    </span>
                  </div>
                  <div className="text-sm text-gray-600">
                    Click the checkbox to see events in the log below
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
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoCheckbox
  checked={checked}
  onChange={(e) => {
    // Fired when checked state changes
    console.log('checked:', e.detail);
  }}
  onStatechange={(e) => {
    // Fired on every change, including tristate
    // e.detail: 'checked' | 'unchecked' | 'mixed'
    console.log('state:', e.detail);
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
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">checked</code> — Current checked state (boolean | null, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">disabled</code> — Disables interaction when true (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">tristate</code> — Enables three-state behavior (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">activeColor</code> — Checkbox color when selected (string, default: "#0A84FF")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">checkColor</code> — Color of the check icon (string, default: "#FFFFFF")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">focusColor</code> — Focus highlight color (string, default: "rgba(10,132,255,0.3)")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">fillColorSelected</code> — Fill color when selected (string, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">fillColorDisabled</code> — Fill color when disabled (string, default: "#D1D1D6")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">autofocus</code> — Auto-focus on mount (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">semanticLabel</code> — Accessibility label for screen readers (string, optional)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Events</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Fired when checked state changes (event: CustomEvent{'<boolean>'})</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onStatechange</code> — Fired on every change, including tristate (event: CustomEvent{'<"checked"|"unchecked"|"mixed">'})</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange: e.detail</code> — Boolean value representing checked state</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onStatechange: e.detail</code> — String value: 'checked' | 'unchecked' | 'mixed'</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Clear Labels:</strong> Always provide descriptive labels next to checkboxes</li>
                <li><strong>Semantic Labels:</strong> Use semanticLabel prop for accessibility with screen readers</li>
                <li><strong>Touch Targets:</strong> Ensure adequate spacing around checkboxes for easy interaction</li>
                <li><strong>Tristate Use:</strong> Use tristate for parent-child relationships (e.g., "Select All")</li>
                <li><strong>Visual Feedback:</strong> Provide immediate visual feedback when state changes</li>
                <li><strong>Disabled State:</strong> Clearly indicate when checkboxes cannot be changed</li>
                <li><strong>Group Related Items:</strong> Group related checkboxes together visually</li>
                <li><strong>Color Consistency:</strong> Use consistent colors across your application</li>
                <li><strong>State Indication:</strong> For task lists, consider visual changes (strikethrough) for completed items</li>
                <li><strong>Event Choice:</strong> Use onChange for boolean changes, onStatechange for tristate</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Disabled Behavior</h4>
                <p className="text-sm text-fg-secondary">
                  When disabled is true, the checkbox becomes non-interactive and appears dimmed. No events will fire in this state.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Tristate vs Binary</h4>
                <p className="text-sm text-fg-secondary">
                  Binary checkboxes toggle between false and true. Tristate checkboxes cycle through false → true → null. Use onStatechange to detect the mixed (null) state reliably.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Color Customization</h4>
                <p className="text-sm text-fg-secondary">
                  All color props accept any CSS color format (hex, rgb, rgba, named colors). If fillColorSelected is omitted, it defaults to activeColor.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Layout Neutrality</h4>
                <p className="text-sm text-fg-secondary">
                  The checkbox itself has minimal layout impact. Use className or style props on a wrapper div for spacing and alignment.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Native Styling</h4>
                <p className="text-sm text-fg-secondary">
                  The checkbox uses native iOS Cupertino styling rendered by Flutter. Animations and interactions match iOS design guidelines.
                </p>
              </div>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Select All / Parent-Child</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [items, setItems] = useState([
  { id: 1, checked: false },
  { id: 2, checked: true },
  { id: 3, checked: false }
]);

const allChecked = items.every(item => item.checked);
const someChecked = items.some(item => item.checked);
const selectAllState = allChecked ? true : (someChecked ? null : false);

<FlutterCupertinoCheckbox
  checked={selectAllState}
  tristate={true}
  onStatechange={(e) => {
    if (e.detail === 'checked') {
      setItems(items.map(item => ({ ...item, checked: true })));
    } else {
      setItems(items.map(item => ({ ...item, checked: false })));
    }
  }}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Form Validation with Checkbox</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [agreed, setAgreed] = useState(false);
const [error, setError] = useState('');

const handleSubmit = () => {
  if (!agreed) {
    setError('You must accept the terms to continue');
    return;
  }
  // Proceed with submission
};

<FlutterCupertinoCheckbox
  checked={agreed}
  onChange={(e) => {
    setAgreed(e.detail);
    if (e.detail) setError('');
  }}
/>
{error && <div className="text-red-500">{error}</div>}`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Settings Row with Description</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div className="flex items-center justify-between">
  <div className="flex-1">
    <div className="font-medium">Email Notifications</div>
    <div className="text-sm text-gray-600">
      Receive updates via email
    </div>
  </div>
  <FlutterCupertinoCheckbox
    checked={emailEnabled}
    onChange={(e) => setEmailEnabled(e.detail)}
  />
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Task List with Strikethrough</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div className="flex items-center gap-3">
  <FlutterCupertinoCheckbox
    checked={task.completed}
    onChange={(e) => updateTask(task.id, e.detail)}
  />
  <span className={task.completed ? 'line-through text-gray-500' : ''}>
    {task.title}
  </span>
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Accessible Checkbox with Label</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<label className="flex items-center gap-3 cursor-pointer">
  <FlutterCupertinoCheckbox
    checked={checked}
    onChange={(e) => setChecked(e.detail)}
    semanticLabel="Accept marketing emails"
  />
  <span>I want to receive marketing emails</span>
</label>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Custom Colored Checkbox for Themes</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const theme = {
  primary: '#FF3B30',
  checkmark: '#FFFFFF'
};

<FlutterCupertinoCheckbox
  checked={checked}
  onChange={(e) => setChecked(e.detail)}
  activeColor={theme.primary}
  checkColor={theme.checkmark}
  fillColorSelected={theme.primary}
/>`}</code></pre>
              </div>
            </div>
          </section>

          {/* Accessibility */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Accessibility</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Semantic Labels</h4>
                <p className="text-sm text-fg-secondary mb-2">
                  Always provide semantic labels for screen readers using the semanticLabel prop:
                </p>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<FlutterCupertinoCheckbox
  checked={agreed}
  onChange={(e) => setAgreed(e.detail)}
  semanticLabel="I agree to the terms and conditions"
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Keyboard Navigation</h4>
                <p className="text-sm text-fg-secondary">
                  Checkboxes support keyboard navigation. Use autofocus to focus a checkbox on mount when appropriate.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Color Contrast</h4>
                <p className="text-sm text-fg-secondary">
                  Ensure sufficient color contrast between checkbox colors and backgrounds for users with visual impairments.
                </p>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};

