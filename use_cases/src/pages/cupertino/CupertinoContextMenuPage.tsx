import React, { useRef, useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoContextMenu,
  FlutterCupertinoContextMenuElement,
  FlutterCupertinoIcon,
  CupertinoIcons,
} from '@openwebf/react-cupertino-ui';

export const CupertinoContextMenuPage: React.FC = () => {
  const [lastAction, setLastAction] = useState('');
  const basicRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const iconRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const destructiveRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const defaultRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const dynamicRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const hapticRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const photoRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const musicRef = useRef<FlutterCupertinoContextMenuElement>(null);
  const videoRef = useRef<FlutterCupertinoContextMenuElement>(null);

  const handleSelect = (e: CustomEvent<any>) => {
    const detail = e.detail;
    const prefix = detail.default ? 'Default: ' : '';
    const suffix = detail.destructive ? ' (destructive)' : '';
    setLastAction(`${prefix}${detail.text}${suffix} [index: ${detail.index}]`);
  };

  // Set up context menu actions on mount
  useEffect(() => {
    // Basic actions
    basicRef.current?.setActions([
      { text: 'Open', event: 'open' },
      { text: 'Get Info', event: 'info' },
      { text: 'Rename', event: 'rename' },
    ]);

    // Actions with icons
    iconRef.current?.setActions([
      { text: 'Share', icon: 'square_arrow_up', event: 'share' },
      { text: 'Edit', icon: 'pencil', event: 'edit' },
      { text: 'Duplicate', icon: 'doc_on_doc', event: 'duplicate' },
      { text: 'Delete', icon: 'trash', destructive: true, event: 'delete' },
    ]);

    // Destructive actions
    destructiveRef.current?.setActions([
      { text: 'Mark as Read', event: 'read' },
      { text: 'Archive', event: 'archive' },
      { text: 'Delete', event: 'delete', destructive: true },
      { text: 'Block Sender', event: 'block', destructive: true },
    ]);

    // Default action
    defaultRef.current?.setActions([
      { text: 'Open', event: 'open', default: true },
      { text: 'Get Info', event: 'info' },
      { text: 'Rename', event: 'rename' },
      { text: 'Compress', event: 'compress' },
    ]);

    // Haptic feedback
    hapticRef.current?.setActions([
      { text: 'Call', event: 'call', icon: 'phone' },
      { text: 'Message', event: 'message', icon: 'chat_bubble' },
      { text: 'Email', event: 'email', icon: 'mail' },
    ]);

    // Photo actions
    photoRef.current?.setActions([
      { text: 'View', default: true, icon: 'eye', event: 'view' },
      { text: 'Edit', icon: 'pencil', event: 'edit' },
      { text: 'Share', icon: 'square_arrow_up', event: 'share' },
      { text: 'Delete', destructive: true, icon: 'trash', event: 'delete' },
    ]);

    // Music actions
    musicRef.current?.setActions([
      { text: 'Play', default: true, icon: 'play', event: 'play' },
      { text: 'Add to Playlist', icon: 'music_note', event: 'playlist' },
      { text: 'Share', icon: 'square_arrow_up', event: 'share' },
    ]);

    // Video actions
    videoRef.current?.setActions([
      { text: 'Play', default: true, icon: 'play', event: 'play' },
      { text: 'Get Info', icon: 'info', event: 'info' },
      { text: 'Share', icon: 'square_arrow_up', event: 'share' },
      { text: 'Delete', destructive: true, icon: 'trash', event: 'delete' },
    ]);
  }, []);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Context Menu</h1>
          <p className="text-fg-secondary mb-6">iOS-style long-press context menu with preview and actions.</p>

          {/* Info Box */}
          <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded mb-8">
            <p className="text-sm text-gray-700">
              <strong>How to use:</strong> Long-press (click and hold) on any card below to reveal the context menu.
            </p>
          </div>

          {/* Basic Context Menu */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Context Menu</h2>
            <p className="text-fg-secondary mb-4">Simple context menu with multiple actions triggered by long-press.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoContextMenu
                ref={basicRef}
                onSelect={handleSelect}
              >
                <div className="bg-blue-100 rounded-lg p-6 border-2 border-blue-300 text-center cursor-pointer select-none">
                  <div className="text-2xl mb-2">
                    <FlutterCupertinoIcon type={CupertinoIcons.doc_text_fill} />
                  </div>
                  <div className="font-semibold text-blue-900">Document.pdf</div>
                  <div className="text-sm text-blue-700 mt-1">Long-press to open menu</div>
                </div>
              </FlutterCupertinoContextMenu>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoContextMenu
  onSelect={(e) => console.log('Selected:', e.detail.text)}
>
  <div className="card">
    Document.pdf
  </div>
</FlutterCupertinoContextMenu>

// Actions are set via ref.current?.setActions([...])`}</code></pre>
            </div>
          </section>

          {/* With Icons */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Context Menu with Icons</h2>
            <p className="text-fg-secondary mb-4">Actions can include trailing icons from the Cupertino icon set.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoContextMenu
                ref={iconRef}
                onSelect={handleSelect}
              >
                <div className="bg-purple-100 rounded-lg p-6 border-2 border-purple-300 text-center cursor-pointer select-none">
                  <div className="text-2xl mb-2">
                    <FlutterCupertinoIcon type={CupertinoIcons.photo} />
                  </div>
                  <div className="font-semibold text-purple-900">Image.jpg</div>
                  <div className="text-sm text-purple-700 mt-1">Long-press for options</div>
                </div>
              </FlutterCupertinoContextMenu>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const ref = useRef<FlutterCupertinoContextMenuElement>(null);

useEffect(() => {
  ref.current?.setActions([
    { text: 'Share', icon: 'square_arrow_up' },
    { text: 'Edit', icon: 'pencil' },
    { text: 'Duplicate', icon: 'doc_on_doc' },
    { text: 'Delete', icon: 'trash', destructive: true },
  ]);
}, []);`}</code></pre>
            </div>
          </section>

          {/* Destructive Actions */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Destructive Actions</h2>
            <p className="text-fg-secondary mb-4">Mark dangerous actions as destructive with red styling.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoContextMenu
                ref={destructiveRef}
                onSelect={handleSelect}
              >
                <div className="bg-red-100 rounded-lg p-6 border-2 border-red-300 text-center cursor-pointer select-none">
                  <div className="text-2xl mb-2">
                    <FlutterCupertinoIcon type={CupertinoIcons.mail_solid} />
                  </div>
                  <div className="font-semibold text-red-900">Spam Email</div>
                  <div className="text-sm text-red-700 mt-1">Long-press to manage</div>
                </div>
              </FlutterCupertinoContextMenu>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`ref.current?.setActions([
  { text: 'Mark as Read', event: 'read' },
  { text: 'Archive', event: 'archive' },
  { text: 'Delete', event: 'delete', destructive: true },
  { text: 'Block Sender', event: 'block', destructive: true },
]);`}</code></pre>
            </div>
          </section>

          {/* Default Action */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Default Action</h2>
            <p className="text-fg-secondary mb-4">Mark the most common action as default with bold styling.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoContextMenu
                ref={defaultRef}
                onSelect={handleSelect}
              >
                <div className="bg-green-100 rounded-lg p-6 border-2 border-green-300 text-center cursor-pointer select-none">
                  <div className="text-2xl mb-2">
                    <FlutterCupertinoIcon type={CupertinoIcons.folder_fill} />
                  </div>
                  <div className="font-semibold text-green-900">Project Folder</div>
                  <div className="text-sm text-green-700 mt-1">Long-press for actions</div>
                </div>
              </FlutterCupertinoContextMenu>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`ref.current?.setActions([
  { text: 'Open', event: 'open', default: true },
  { text: 'Get Info', event: 'info' },
  { text: 'Rename', event: 'rename' },
  { text: 'Compress', event: 'compress' },
]);`}</code></pre>
            </div>
          </section>

          {/* Dynamic Actions */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Dynamic Actions</h2>
            <p className="text-fg-secondary mb-4">Update menu actions dynamically using the setActions method.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoContextMenu
                ref={dynamicRef}
                onSelect={handleSelect}
              >
                <div className="bg-yellow-100 rounded-lg p-6 border-2 border-yellow-300 text-center cursor-pointer select-none">
                  <div className="text-2xl mb-2">
                    <FlutterCupertinoIcon type={CupertinoIcons.star_fill} />
                  </div>
                  <div className="font-semibold text-yellow-900">Dynamic Menu</div>
                  <div className="text-sm text-yellow-700 mt-1">Long-press to see current actions</div>
                </div>
              </FlutterCupertinoContextMenu>

              <div className="mt-4 flex gap-3 flex-wrap">
                <button
                  className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
                  onClick={() => {
                    dynamicRef.current?.setActions([
                      { text: 'View', event: 'view', default: true, icon: 'eye' },
                      { text: 'Edit', event: 'edit', icon: 'pencil' },
                      { text: 'Share', event: 'share', icon: 'square_arrow_up' },
                    ]);
                    setLastAction('Updated to: View, Edit, Share');
                  }}
                >
                  Set View Actions
                </button>
                <button
                  className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm"
                  onClick={() => {
                    dynamicRef.current?.setActions([
                      { text: 'Copy', event: 'copy', icon: 'doc_on_doc' },
                      { text: 'Paste', event: 'paste' },
                      { text: 'Cut', event: 'cut' },
                    ]);
                    setLastAction('Updated to: Copy, Paste, Cut');
                  }}
                >
                  Set Edit Actions
                </button>
                <button
                  className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm"
                  onClick={() => {
                    dynamicRef.current?.setActions([
                      { text: 'Archive', event: 'archive' },
                      { text: 'Delete', event: 'delete', destructive: true, icon: 'trash' },
                    ]);
                    setLastAction('Updated to: Archive, Delete');
                  }}
                >
                  Set Delete Actions
                </button>
              </div>

              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const ref = useRef<FlutterCupertinoContextMenuElement>(null);

// Update actions based on state
const updateActions = (mode: 'view' | 'edit') => {
  if (mode === 'view') {
    ref.current?.setActions([
      { text: 'View', default: true },
      { text: 'Edit' },
      { text: 'Share' },
    ]);
  } else {
    ref.current?.setActions([
      { text: 'Copy' },
      { text: 'Paste' },
      { text: 'Cut' },
    ]);
  }
};`}</code></pre>
            </div>
          </section>

          {/* With Haptic Feedback */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">With Haptic Feedback</h2>
            <p className="text-fg-secondary mb-4">Enable haptic feedback when the menu opens (on supported devices).</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoContextMenu
                ref={hapticRef}
                enableHapticFeedback={true}
                onSelect={handleSelect}
              >
                <div className="bg-indigo-100 rounded-lg p-6 border-2 border-indigo-300 text-center cursor-pointer select-none">
                  <div className="text-2xl mb-2">
                    <FlutterCupertinoIcon type={CupertinoIcons.device_phone_portrait} />
                  </div>
                  <div className="font-semibold text-indigo-900">Haptic Enabled</div>
                  <div className="text-sm text-indigo-700 mt-1">Long-press to feel haptic feedback</div>
                </div>
              </FlutterCupertinoContextMenu>
              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoContextMenu
  enableHapticFeedback={true}
  onSelect={(e) => console.log('Selected:', e.detail)}
>
  <div className="content">
    Long-press me
  </div>
</FlutterCupertinoContextMenu>`}</code></pre>
            </div>
          </section>

          {/* Complex Example */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Complex Example</h2>
            <p className="text-fg-secondary mb-4">Real-world example with multiple item types and action sets.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <FlutterCupertinoContextMenu ref={photoRef} onSelect={handleSelect}>
                  <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm cursor-pointer select-none">
                    <div className="text-3xl mb-2">
                      <FlutterCupertinoIcon type={CupertinoIcons.camera_fill} />
                    </div>
                    <div className="font-semibold text-sm">Photo.jpg</div>
                    <div className="text-xs text-gray-500 mt-1">2.4 MB</div>
                  </div>
                </FlutterCupertinoContextMenu>

                <FlutterCupertinoContextMenu ref={musicRef} onSelect={handleSelect}>
                  <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm cursor-pointer select-none">
                    <div className="text-3xl mb-2">
                      <FlutterCupertinoIcon type={CupertinoIcons.music_note_2} />
                    </div>
                    <div className="font-semibold text-sm">Song.mp3</div>
                    <div className="text-xs text-gray-500 mt-1">4.8 MB</div>
                  </div>
                </FlutterCupertinoContextMenu>

                <FlutterCupertinoContextMenu ref={videoRef} onSelect={handleSelect}>
                  <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm cursor-pointer select-none">
                    <div className="text-3xl mb-2">
                      <FlutterCupertinoIcon type={CupertinoIcons.film_fill} />
                    </div>
                    <div className="font-semibold text-sm">Video.mp4</div>
                    <div className="text-xs text-gray-500 mt-1">45.2 MB</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>

              {lastAction && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last action: {lastAction}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Photo actions
ref.current?.setActions([
  { text: 'View', default: true, icon: 'eye' },
  { text: 'Edit', icon: 'pencil' },
  { text: 'Share', icon: 'square_arrow_up' },
  { text: 'Delete', destructive: true, icon: 'trash' },
]);`}</code></pre>
            </div>
          </section>

          {/* API Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">API Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Component Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">enableHapticFeedback</code> — Enable haptic feedback on menu open (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onSelect</code> — Fired when action is selected (function)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">children</code> — Content that triggers the menu on long-press (ReactNode)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">ref</code> — Reference to call setActions() method</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">ContextMenuAction</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">text</code> — Button label text (string, required)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">icon</code> — Trailing icon name from Cupertino icons (string, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">destructive</code> — Makes action red/destructive (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">default</code> — Makes action bold (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">event</code> — Custom event identifier (string, optional)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail (onSelect)</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">index</code> — Zero-based index of selected action (number)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">text</code> — Selected action's text (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">event</code> — Custom event identifier (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">destructive</code> — Whether action was destructive (boolean)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">default</code> — Whether action was default (boolean)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Ref Methods</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">setActions(actions)</code> — Set the list of actions displayed in the menu</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Action Count:</strong> Limit to 3-6 actions for best usability. Too many actions make the menu hard to use</li>
                <li><strong>Default Action:</strong> Mark the most common action as default with <code>default: true</code></li>
                <li><strong>Destructive Actions:</strong> Always mark dangerous/irreversible actions as destructive</li>
                <li><strong>Icons:</strong> Use icons to make actions more recognizable and scannable</li>
                <li><strong>Trigger Area:</strong> Ensure the wrapped content has sufficient size for easy long-press (minimum 44x44 points)</li>
                <li><strong>Visual Feedback:</strong> Style the wrapped content to indicate it's interactive (border, shadow, etc.)</li>
                <li><strong>Dynamic Updates:</strong> Use <code>setActions()</code> to update menu based on item state or context</li>
                <li><strong>Haptic Feedback:</strong> Enable haptics for better user experience on supported devices</li>
                <li><strong>Event Names:</strong> Use descriptive event names for easier action handling</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Long-Press Interaction</h4>
                <p className="text-sm text-fg-secondary">
                  The context menu is triggered by a long-press gesture on the wrapped content.
                  On mobile devices, this is a natural gesture. On desktop, click and hold to trigger.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Preview</h4>
                <p className="text-sm text-fg-secondary">
                  The wrapped content serves as both the trigger and preview. During long-press,
                  the content is shown in a preview popup along with the action menu.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Setting Actions</h4>
                <p className="text-sm text-fg-secondary">
                  Actions must be set via the <code>setActions()</code> ref method. You can call this
                  in <code>useEffect</code>, event handlers, or any time you need to update the menu.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Icon Names</h4>
                <p className="text-sm text-fg-secondary">
                  Use Cupertino icon names (e.g., 'trash', 'pencil', 'square_arrow_up').
                  See the Cupertino Icons page for available icons.
                </p>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
