import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoActionSheet, FlutterCupertinoActionSheetElement } from '@openwebf/react-cupertino-ui';

export const CupertinoActionSheetPage: React.FC = () => {
  const [lastAction, setLastAction] = useState('');
  const basicRef = useRef<FlutterCupertinoActionSheetElement>(null);
  const destructiveRef = useRef<FlutterCupertinoActionSheetElement>(null);
  const multiRef = useRef<FlutterCupertinoActionSheetElement>(null);
  const noCancelRef = useRef<FlutterCupertinoActionSheetElement>(null);
  const customEventsRef = useRef<FlutterCupertinoActionSheetElement>(null);
  const simpleRef = useRef<FlutterCupertinoActionSheetElement>(null);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Action Sheet</h1>
          <p className="text-fg-secondary mb-6">iOS-style bottom sheet with multiple action options.</p>

          {/* Basic Action Sheet */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Action Sheet</h2>
            <p className="text-fg-secondary mb-4">Simple action sheet with title, message, actions, and a cancel button.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoActionSheet
                ref={basicRef}
                onSelect={(e) => setLastAction(`Selected: ${e.detail.text} (index: ${e.detail.index})`)}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  basicRef.current?.show({
                    title: 'Choose an Option',
                    message: 'Select one of the following actions',
                    actions: [
                      { text: 'Option 1', event: 'option1' },
                      { text: 'Option 2', event: 'option2' },
                      { text: 'Option 3', event: 'option3' },
                    ],
                    cancelButton: { text: 'Cancel', event: 'cancel' },
                  });
                }}
              >
                Show Basic Action Sheet
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const ref = useRef<FlutterCupertinoActionSheetElement>(null);

<FlutterCupertinoActionSheet
  ref={ref}
  onSelect={(e) => console.log('Selected:', e.detail.text)}
/>

ref.current?.show({
  title: 'Choose an Option',
  message: 'Select one of the following actions',
  actions: [
    { text: 'Option 1', event: 'option1' },
    { text: 'Option 2', event: 'option2' },
    { text: 'Option 3', event: 'option3' },
  ],
  cancelButton: { text: 'Cancel', event: 'cancel' },
});`}</code></pre>
            </div>
          </section>

          {/* Destructive Actions */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Destructive Actions</h2>
            <p className="text-fg-secondary mb-4">Use red destructive styling for irreversible or dangerous actions.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoActionSheet
                ref={destructiveRef}
                onSelect={(e) => {
                  if (e.detail.isDestructive) {
                    setLastAction(`Destructive action: ${e.detail.text}`);
                  } else {
                    setLastAction(`Selected: ${e.detail.text}`);
                  }
                }}
              />
              <button
                className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                onClick={() => {
                  destructiveRef.current?.show({
                    title: 'Delete Photo?',
                    message: 'This photo will be permanently deleted from your library.',
                    actions: [
                      { text: 'Delete Photo', event: 'delete', isDestructive: true },
                    ],
                    cancelButton: { text: 'Cancel', event: 'cancel' },
                  });
                }}
              >
                Show Destructive Action
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`ref.current?.show({
  title: 'Delete Photo?',
  message: 'This will permanently delete the photo.',
  actions: [
    { text: 'Delete Photo', event: 'delete', isDestructive: true },
  ],
  cancelButton: { text: 'Cancel', event: 'cancel' },
});`}</code></pre>
            </div>
          </section>

          {/* Multiple Actions with Default */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Multiple Actions with Default</h2>
            <p className="text-fg-secondary mb-4">Mark one action as default with bold styling to guide users.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoActionSheet
                ref={multiRef}
                onSelect={(e) => {
                  const prefix = e.detail.isDefault ? 'Default: ' : '';
                  const suffix = e.detail.isDestructive ? ' (destructive)' : '';
                  setLastAction(`${prefix}${e.detail.text}${suffix}`);
                }}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  multiRef.current?.show({
                    title: 'Share Photo',
                    message: 'Choose how to share this photo with others',
                    actions: [
                      { text: 'Message', event: 'message', isDefault: true },
                      { text: 'Mail', event: 'mail' },
                      { text: 'AirDrop', event: 'airdrop' },
                      { text: 'Save to Files', event: 'files' },
                      { text: 'Delete', event: 'delete', isDestructive: true },
                    ],
                    cancelButton: { text: 'Cancel', event: 'cancel' },
                  });
                }}
              >
                Show Multi-Action Sheet
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`ref.current?.show({
  title: 'Share Photo',
  message: 'Choose how to share this photo',
  actions: [
    { text: 'Message', event: 'message', isDefault: true },
    { text: 'Mail', event: 'mail' },
    { text: 'AirDrop', event: 'airdrop' },
    { text: 'Save to Files', event: 'files' },
    { text: 'Delete', event: 'delete', isDestructive: true },
  ],
  cancelButton: { text: 'Cancel', event: 'cancel' },
});`}</code></pre>
            </div>
          </section>

          {/* Without Cancel Button */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Without Cancel Button</h2>
            <p className="text-fg-secondary mb-4">Action sheet without cancel button - user must select an action.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoActionSheet
                ref={noCancelRef}
                onSelect={(e) => setLastAction(`Selected: ${e.detail.text} (no cancel)`)}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  noCancelRef.current?.show({
                    title: 'Select Size',
                    message: 'Choose the size for your order',
                    actions: [
                      { text: 'Small', event: 'small' },
                      { text: 'Medium', event: 'medium', isDefault: true },
                      { text: 'Large', event: 'large' },
                      { text: 'Extra Large', event: 'xlarge' },
                    ],
                  });
                }}
              >
                Show Without Cancel
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Omit cancelButton to require selection
ref.current?.show({
  title: 'Select Size',
  message: 'Choose the size for your order',
  actions: [
    { text: 'Small', event: 'small' },
    { text: 'Medium', event: 'medium', isDefault: true },
    { text: 'Large', event: 'large' },
  ],
  // No cancelButton
});`}</code></pre>
            </div>
          </section>

          {/* Custom Event Handling */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Event Handling</h2>
            <p className="text-fg-secondary mb-4">Use custom event names to handle different actions programmatically.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoActionSheet
                ref={customEventsRef}
                onSelect={(e) => {
                  const eventMap: Record<string, string> = {
                    'edit': 'Opening editor...',
                    'duplicate': 'Creating duplicate...',
                    'share': 'Opening share sheet...',
                    'archive': 'Moving to archive...',
                    'delete': 'Deleting item...',
                    'cancel': 'Cancelled',
                  };
                  setLastAction(eventMap[e.detail.event] || `Unknown event: ${e.detail.event}`);
                }}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  customEventsRef.current?.show({
                    title: 'Document Options',
                    actions: [
                      { text: 'Edit', event: 'edit', isDefault: true },
                      { text: 'Duplicate', event: 'duplicate' },
                      { text: 'Share', event: 'share' },
                      { text: 'Archive', event: 'archive' },
                      { text: 'Delete', event: 'delete', isDestructive: true },
                    ],
                    cancelButton: { text: 'Cancel', event: 'cancel' },
                  });
                }}
              >
                Show Custom Events
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoActionSheet
  ref={ref}
  onSelect={(e) => {
    switch(e.detail.event) {
      case 'edit':
        console.log('Opening editor...');
        break;
      case 'delete':
        console.log('Deleting item...');
        break;
      default:
        console.log('Event:', e.detail.event);
    }
  }}
/>`}</code></pre>
            </div>
          </section>

          {/* Simple Usage (Title Only) */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Simple Usage (Title Only)</h2>
            <p className="text-fg-secondary mb-4">Minimal action sheet with just a title and actions.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoActionSheet
                ref={simpleRef}
                onSelect={(e) => setLastAction(`Quick action: ${e.detail.text}`)}
              />
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                onClick={() => {
                  simpleRef.current?.show({
                    title: 'Quick Actions',
                    actions: [
                      { text: 'Copy', event: 'copy' },
                      { text: 'Paste', event: 'paste' },
                      { text: 'Select All', event: 'selectAll' },
                    ],
                    cancelButton: { text: 'Cancel', event: 'cancel' },
                  });
                }}
              >
                Show Simple Sheet
              </button>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Minimal - just title and actions
ref.current?.show({
  title: 'Quick Actions',
  actions: [
    { text: 'Copy', event: 'copy' },
    { text: 'Paste', event: 'paste' },
  ],
  cancelButton: { text: 'Cancel', event: 'cancel' },
});`}</code></pre>
            </div>
          </section>

          {/* Props Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">API Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoActionSheetOptions</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">title</code> — Sheet title text (string, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">message</code> — Sheet message/description (string, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">actions</code> — Array of action button configurations (optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">cancelButton</code> — Cancel button configuration (optional, omit to hide)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoActionSheetAction</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">text</code> — Button label text (string, required)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">event</code> — Custom event identifier (string, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">isDefault</code> — Makes button bold (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">isDestructive</code> — Makes button red (boolean, default: false)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail (onSelect)</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">text</code> — Selected button's text (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">event</code> — Custom event identifier (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">index</code> — Index of selected action (number, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">isDefault</code> — Whether button was marked default (boolean)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">isDestructive</code> — Whether button was destructive (boolean)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Ref Methods</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">show(options)</code> — Display the action sheet with given options</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Component Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onSelect</code> — Fired when any action is selected (function)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">ref</code> — Reference to call show() method</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Action Order:</strong> Place default action first or most common actions at the top for easy thumb reach</li>
                <li><strong>Destructive Actions:</strong> Always use <code>isDestructive: true</code> for irreversible actions like delete or clear</li>
                <li><strong>Cancel Button:</strong> Include a cancel button unless the user must make a selection (e.g., required settings)</li>
                <li><strong>Default Action:</strong> Mark the most common or recommended action with <code>isDefault: true</code> to make it bold</li>
                <li><strong>Event Names:</strong> Use descriptive event names to make selection handling clear and maintainable</li>
                <li><strong>Title & Message:</strong> Keep title short (1-2 words), use message for longer explanations if needed</li>
                <li><strong>Action Count:</strong> Avoid too many actions (5-7 max). Consider using a different UI pattern for longer lists</li>
                <li><strong>Accessibility:</strong> Action sheets block interaction with the rest of the app until dismissed</li>
              </ul>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Photo/File Actions</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`{ title: 'Photo Options', actions: [
  { text: 'View', event: 'view', isDefault: true },
  { text: 'Share', event: 'share' },
  { text: 'Save to Files', event: 'save' },
  { text: 'Delete', event: 'delete', isDestructive: true }
]}`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Confirmation Before Action</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`{ title: 'Delete Account?',
  message: 'This cannot be undone.',
  actions: [
    { text: 'Delete Account', event: 'delete', isDestructive: true }
  ],
  cancelButton: { text: 'Keep Account', event: 'cancel' }
}`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Selection Menu</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`{ title: 'Sort By', actions: [
  { text: 'Name', event: 'name', isDefault: true },
  { text: 'Date', event: 'date' },
  { text: 'Size', event: 'size' }
]}`}</code></pre>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
