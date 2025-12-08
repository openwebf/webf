import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoAlert, FlutterCupertinoAlertElement } from '@openwebf/react-cupertino-ui';

export const CupertinoAlertPage: React.FC = () => {
  const [lastAction, setLastAction] = useState('');
  const imperativeRef = useRef<FlutterCupertinoAlertElement>(null);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Alert Dialog</h1>
          <p className="text-fg-secondary mb-6">iOS-style alert and confirmation dialogs with native appearance.</p>

          {/* Basic Alert - Confirm Only */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Alert</h2>
            <p className="text-fg-secondary mb-4">Simple alert with title, message, and a single confirm button.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoAlert
                title="Welcome"
                message="This is a basic iOS-style alert dialog."
                confirmText="OK"
                onConfirm={() => setLastAction('Confirmed basic alert')}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  const alert = document.querySelector('flutter-cupertino-alert') as any;
                  alert?.show();
                }}
              >
                Show Basic Alert
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoAlert
  title="Welcome"
  message="This is a basic iOS-style alert dialog."
  confirmText="OK"
  onConfirm={() => console.log('Confirmed')}
/>`}</code></pre>
            </div>
          </section>

          {/* Alert with Cancel and Confirm */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Alert with Cancel & Confirm</h2>
            <p className="text-fg-secondary mb-4">Two-button alert for user confirmation.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoAlert
                title="Delete Item?"
                message="This action cannot be undone. Are you sure you want to proceed?"
                cancelText="Cancel"
                confirmText="Delete"
                onCancel={() => setLastAction('Cancelled deletion')}
                onConfirm={() => setLastAction('Confirmed deletion')}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  const alerts = document.querySelectorAll('flutter-cupertino-alert');
                  (alerts[1] as any)?.show();
                }}
              >
                Show Confirmation Alert
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoAlert
  title="Delete Item?"
  message="This action cannot be undone."
  cancelText="Cancel"
  confirmText="Delete"
  onCancel={() => console.log('Cancelled')}
  onConfirm={() => console.log('Confirmed')}
/>`}</code></pre>
            </div>
          </section>

          {/* Destructive Alert */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Destructive Actions</h2>
            <p className="text-fg-secondary mb-4">Use red destructive styling to warn users about irreversible actions.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoAlert
                title="Clear All Data?"
                message="All your settings and data will be permanently deleted from this device."
                cancelText="Keep Data"
                cancelDefault={true}
                confirmText="Clear Everything"
                confirmDestructive={true}
                onCancel={() => setLastAction('Kept data (safe choice)')}
                onConfirm={() => setLastAction('Cleared all data (destructive)')}
              />
              <button
                className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                onClick={() => {
                  const alerts = document.querySelectorAll('flutter-cupertino-alert');
                  (alerts[2] as any)?.show();
                }}
              >
                Show Destructive Alert
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoAlert
  title="Clear All Data?"
  message="All your settings will be permanently deleted."
  cancelText="Keep Data"
  cancelDefault={true}
  confirmText="Clear Everything"
  confirmDestructive={true}
  onCancel={() => console.log('Safe choice')}
  onConfirm={() => console.log('Destructive action')}
/>`}</code></pre>
            </div>
          </section>

          {/* Custom Button Styles */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Button Styles</h2>
            <p className="text-fg-secondary mb-4">Customize button appearance with JSON-encoded text styles.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoAlert
                title="Custom Styling"
                message="Buttons can have custom colors, font sizes, and weights."
                cancelText="No Thanks"
                cancelTextStyle='{"color":"#FF3B30","fontSize":16,"fontWeight":"normal"}'
                confirmText="Proceed"
                confirmTextStyle='{"color":"#007AFF","fontSize":18,"fontWeight":"bold"}'
                onCancel={() => setLastAction('Declined with custom style')}
                onConfirm={() => setLastAction('Proceeded with custom style')}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  const alerts = document.querySelectorAll('flutter-cupertino-alert');
                  (alerts[3] as any)?.show();
                }}
              >
                Show Custom Styled Alert
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoAlert
  title="Custom Styling"
  message="Buttons with custom appearance."
  cancelText="No Thanks"
  cancelTextStyle='{"color":"#FF3B30","fontSize":16}'
  confirmText="Proceed"
  confirmTextStyle='{"color":"#007AFF","fontSize":18,"fontWeight":"bold"}'
/>`}</code></pre>
            </div>
          </section>

          {/* Imperative API with Ref */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Imperative API with Ref</h2>
            <p className="text-fg-secondary mb-4">Use ref to call show() and hide() methods imperatively, optionally overriding title/message.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoAlert
                ref={imperativeRef}
                title="Default Title"
                message="Default message content."
                confirmText="Got it"
                onConfirm={() => setLastAction('Confirmed via imperative API')}
              />
              <div className="flex gap-3 flex-wrap">
                <button
                  className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                  onClick={() => imperativeRef.current?.show({ title: 'Default', message: 'Using default props' })}
                >
                  Show with Default
                </button>
                <button
                  className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                  onClick={() => imperativeRef.current?.show({ title: 'Success!', message: 'Operation completed successfully.' })}
                >
                  Show Success
                </button>
                <button
                  className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
                  onClick={() => imperativeRef.current?.show({ title: 'Warning', message: 'Please check your input.' })}
                >
                  Show Warning
                </button>
              </div>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const ref = useRef<FlutterCupertinoAlertElement>(null);

<FlutterCupertinoAlert
  ref={ref}
  title="Default Title"
  message="Default message"
  confirmText="Got it"
/>

// Show with custom content
ref.current?.show({
  title: 'Success!',
  message: 'Operation completed.'
});

// Hide programmatically
ref.current?.hide();`}</code></pre>
            </div>
          </section>

          {/* Default Button Behavior */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Default Button Styling</h2>
            <p className="text-fg-secondary mb-4">Mark which button should have bold (default) styling.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <h3 className="font-semibold mb-2 text-sm">Confirm Default (typical)</h3>
                  <FlutterCupertinoAlert
                    title="Save Changes?"
                    message="Your modifications will be saved."
                    cancelText="Discard"
                    confirmText="Save"
                    confirmDefault={true}
                    onCancel={() => setLastAction('Discarded (cancel)')}
                    onConfirm={() => setLastAction('Saved (confirm default)')}
                  />
                  <button
                    className="w-full px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                    onClick={() => {
                      const alerts = document.querySelectorAll('flutter-cupertino-alert');
                      (alerts[4] as any)?.show();
                    }}
                  >
                    Show (Confirm Default)
                  </button>
                </div>

                <div>
                  <h3 className="font-semibold mb-2 text-sm">Cancel Default (safer)</h3>
                  <FlutterCupertinoAlert
                    title="Delete Account?"
                    message="This cannot be undone."
                    cancelText="Keep Account"
                    cancelDefault={true}
                    confirmText="Delete"
                    confirmDestructive={true}
                    onCancel={() => setLastAction('Kept account (cancel default)')}
                    onConfirm={() => setLastAction('Deleted account (destructive)')}
                  />
                  <button
                    className="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm"
                    onClick={() => {
                      const alerts = document.querySelectorAll('flutter-cupertino-alert');
                      (alerts[5] as any)?.show();
                    }}
                  >
                    Show (Cancel Default)
                  </button>
                </div>
              </div>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Confirm button is bold (typical)
<FlutterCupertinoAlert
  confirmDefault={true}
  ...
/>

// Cancel button is bold (safer for destructive actions)
<FlutterCupertinoAlert
  cancelDefault={true}
  confirmDestructive={true}
  ...
/>`}</code></pre>
            </div>
          </section>

          {/* Props Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Props Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Content Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">title</code> — Dialog title text (string, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">message</code> — Dialog message/body text (string, optional)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Cancel Button Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">cancelText</code> — Cancel button label (string, omit to hide button)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">cancelDestructive</code> — Makes cancel button red (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">cancelDefault</code> — Makes cancel button bold (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">cancelTextStyle</code> — JSON text style (string, e.g., {`'{"color":"#FF0000","fontSize":16}'`})</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onCancel</code> — Fired when cancel is pressed (function)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Confirm Button Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">confirmText</code> — Confirm button label (string, default: localized "OK")</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">confirmDestructive</code> — Makes confirm button red (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">confirmDefault</code> — Makes confirm button bold (boolean, default: true)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">confirmTextStyle</code> — JSON text style (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onConfirm</code> — Fired when confirm is pressed (function)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Ref Methods</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">show(options?)</code> — Show alert, optionally override title/message</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">hide()</code> — Hide alert if currently visible</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Default Actions:</strong> Confirm button is bold by default. For destructive actions, make cancel button bold instead using <code>cancelDefault=true</code></li>
                <li><strong>Destructive Styling:</strong> Use red destructive styling (<code>confirmDestructive=true</code>) for irreversible actions like delete, clear, or reset</li>
                <li><strong>Cancel Button:</strong> Omit <code>cancelText</code> for simple informational alerts. Include it when user needs choice</li>
                <li><strong>Text Styles:</strong> Custom button styles use JSON format: <code>{`'{"color":"#007AFF","fontSize":18,"fontWeight":"bold"}'`}</code></li>
                <li><strong>Imperative API:</strong> Use <code>show()</code> method to dynamically change alert content without re-rendering the component</li>
                <li><strong>Accessibility:</strong> Alert dialogs are modal and block interaction with rest of app until dismissed</li>
              </ul>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
