import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoListSection,
  FlutterCupertinoListSectionHeader,
  FlutterCupertinoListSectionFooter,
  FlutterCupertinoSwitch,
  FlutterCupertinoIcon,
  CupertinoIcons,
} from '@openwebf/react-cupertino-ui';

export const CupertinoListSectionPage: React.FC = () => {
  const [autoDownloads, setAutoDownloads] = useState(true);
  const [backgroundRefresh, setBackgroundRefresh] = useState(false);
  const [darkMode, setDarkMode] = useState(false);
  const [allowNotifications, setAllowNotifications] = useState(true);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino List Section</h1>
          <p className="text-fg-secondary mb-6">iOS-style grouped list sections with headers and footers.</p>

          {/* Basic List Section */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic List Section</h2>
            <p className="text-fg-secondary mb-4">Simple grouped list section without header or footer.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoListSection>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer">
                  <div className="font-semibold">Item 1</div>
                  <div className="text-sm text-gray-600">Description for item 1</div>
                </div>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer">
                  <div className="font-semibold">Item 2</div>
                  <div className="text-sm text-gray-600">Description for item 2</div>
                </div>
                <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer">
                  <div className="font-semibold">Item 3</div>
                  <div className="text-sm text-gray-600">Description for item 3</div>
                </div>
              </FlutterCupertinoListSection>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListSection>
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* With Header */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">With Header</h2>
            <p className="text-fg-secondary mb-4">List section with a header label.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoListSection>
                <FlutterCupertinoListSectionHeader>
                  <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                    General Settings
                  </div>
                </FlutterCupertinoListSectionHeader>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Wi-Fi</span>
                  <span className="text-gray-500">Home Network →</span>
                </div>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Bluetooth</span>
                  <span className="text-gray-500">On →</span>
                </div>
                <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Cellular</span>
                  <span className="text-gray-500">→</span>
                </div>
              </FlutterCupertinoListSection>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListSection>
  <FlutterCupertinoListSectionHeader>
    General Settings
  </FlutterCupertinoListSectionHeader>
  <div>Wi-Fi</div>
  <div>Bluetooth</div>
  <div>Cellular</div>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* With Footer */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">With Footer</h2>
            <p className="text-fg-secondary mb-4">List section with explanatory footer text.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoListSection>
                <div className="bg-white border-b border-gray-200 p-4">
                  <div className="flex items-center justify-between">
                    <span className="font-medium">Automatic Downloads</span>
                    <FlutterCupertinoSwitch
                      checked={autoDownloads}
                      onChange={(e) => setAutoDownloads(e.detail)}
                    />
                  </div>
                </div>
                <div className="bg-white p-4">
                  <div className="flex items-center justify-between">
                    <span className="font-medium">Background Refresh</span>
                    <FlutterCupertinoSwitch
                      checked={backgroundRefresh}
                      onChange={(e) => setBackgroundRefresh(e.detail)}
                    />
                  </div>
                </div>
                <FlutterCupertinoListSectionFooter>
                  <div className="px-4 py-2 text-sm text-gray-600">
                    Enabling automatic downloads will update your apps and content in the background.
                  </div>
                </FlutterCupertinoListSectionFooter>
              </FlutterCupertinoListSection>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [autoDownloads, setAutoDownloads] = useState(true);
const [backgroundRefresh, setBackgroundRefresh] = useState(false);

<FlutterCupertinoListSection>
  <div className="flex items-center justify-between">
    <span>Automatic Downloads</span>
    <FlutterCupertinoSwitch
      checked={autoDownloads}
      onChange={(e) => setAutoDownloads(e.detail)}
    />
  </div>
  <div className="flex items-center justify-between">
    <span>Background Refresh</span>
    <FlutterCupertinoSwitch
      checked={backgroundRefresh}
      onChange={(e) => setBackgroundRefresh(e.detail)}
    />
  </div>
  <FlutterCupertinoListSectionFooter>
    Enabling automatic downloads will update your apps...
  </FlutterCupertinoListSectionFooter>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* With Header and Footer */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">With Header & Footer</h2>
            <p className="text-fg-secondary mb-4">Complete section with both header and footer.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoListSection>
                <FlutterCupertinoListSectionHeader>
                  <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                    Privacy
                  </div>
                </FlutterCupertinoListSectionHeader>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Location Services</span>
                  <span className="text-gray-500">On →</span>
                </div>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Tracking</span>
                  <span className="text-gray-500">Ask Apps Not to Track →</span>
                </div>
                <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Analytics & Improvements</span>
                  <span className="text-gray-500">→</span>
                </div>
                <FlutterCupertinoListSectionFooter>
                  <div className="px-4 py-2 text-sm text-gray-600">
                    These settings help protect your personal information and give you control over how apps use your data.
                  </div>
                </FlutterCupertinoListSectionFooter>
              </FlutterCupertinoListSection>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListSection>
  <FlutterCupertinoListSectionHeader>
    Privacy
  </FlutterCupertinoListSectionHeader>
  <div>Location Services</div>
  <div>Tracking</div>
  <div>Analytics & Improvements</div>
  <FlutterCupertinoListSectionFooter>
    These settings help protect your personal information...
  </FlutterCupertinoListSectionFooter>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* Inset Grouped Style */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Inset Grouped Style</h2>
            <p className="text-fg-secondary mb-4">iOS Settings-style inset sections with rounded corners.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoListSection insetGrouped={true}>
                <FlutterCupertinoListSectionHeader>
                  <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                    Account
                  </div>
                </FlutterCupertinoListSectionHeader>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
                  <div className="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center text-white font-semibold">
                    JD
                  </div>
                  <div className="flex-1">
                    <div className="font-semibold">John Doe</div>
                    <div className="text-sm text-gray-600">Apple ID, iCloud, Media & Purchases</div>
                  </div>
                  <span className="text-gray-400">→</span>
                </div>
              </FlutterCupertinoListSection>

              <div className="mt-6">
                <FlutterCupertinoListSection insetGrouped={true}>
                  <FlutterCupertinoListSectionHeader>
                    <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                      Devices
                    </div>
                  </FlutterCupertinoListSectionHeader>
                  <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
                    <span className="text-2xl">
                      <FlutterCupertinoIcon type={CupertinoIcons.device_phone_portrait} />
                    </span>
                    <span className="flex-1 font-medium">iPhone 15 Pro</span>
                    <span className="text-gray-400">→</span>
                  </div>
                  <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
                    <span className="text-2xl">
                      <FlutterCupertinoIcon type={CupertinoIcons.device_laptop} />
                    </span>
                    <span className="flex-1 font-medium">MacBook Pro</span>
                    <span className="text-gray-400">→</span>
                  </div>
                  <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer flex items-center gap-3">
                    <span className="text-2xl">
                      <FlutterCupertinoIcon type={CupertinoIcons.stopwatch_fill} />
                    </span>
                    <span className="flex-1 font-medium">Apple Watch</span>
                    <span className="text-gray-400">→</span>
                  </div>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListSection insetGrouped={true}>
  <FlutterCupertinoListSectionHeader>
    Account
  </FlutterCupertinoListSectionHeader>
  <div>John Doe - Apple ID, iCloud...</div>
</FlutterCupertinoListSection>

<FlutterCupertinoListSection insetGrouped={true}>
  <FlutterCupertinoListSectionHeader>
    Devices
  </FlutterCupertinoListSectionHeader>
  <div>iPhone 15 Pro</div>
  <div>MacBook Pro</div>
  <div>Apple Watch</div>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* Multiple Sections */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Multiple Sections</h2>
            <p className="text-fg-secondary mb-4">Stack multiple sections to create organized settings screens.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <FlutterCupertinoListSection>
                <FlutterCupertinoListSectionHeader>
                  <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                    Appearance
                  </div>
                </FlutterCupertinoListSectionHeader>
                <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Dark Mode</span>
                  <FlutterCupertinoSwitch
                    checked={darkMode}
                    onChange={(e) => setDarkMode(e.detail)}
                  />
                </div>
                <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                  <span className="font-medium">Text Size</span>
                  <span className="text-gray-500">Medium →</span>
                </div>
              </FlutterCupertinoListSection>

              <div className="mt-6">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListSectionHeader>
                    <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                      Notifications
                    </div>
                  </FlutterCupertinoListSectionHeader>
                  <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                    <span className="font-medium">Allow Notifications</span>
                    <FlutterCupertinoSwitch
                      checked={allowNotifications}
                      onChange={(e) => setAllowNotifications(e.detail)}
                    />
                  </div>
                  <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                    <span className="font-medium">Notification Style</span>
                    <span className="text-gray-500">Banners →</span>
                  </div>
                  <FlutterCupertinoListSectionFooter>
                    <div className="px-4 py-2 text-sm text-gray-600">
                      Choose how you want to receive notifications from this app.
                    </div>
                  </FlutterCupertinoListSectionFooter>
                </FlutterCupertinoListSection>
              </div>

              <div className="mt-6">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListSectionHeader>
                    <div className="px-4 py-2 text-sm font-semibold text-gray-600 uppercase">
                      About
                    </div>
                  </FlutterCupertinoListSectionHeader>
                  <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                    <span className="font-medium">Version</span>
                    <span className="text-gray-500">1.0.0</span>
                  </div>
                  <div className="bg-white border-b border-gray-200 p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                    <span className="font-medium">Terms of Service</span>
                    <span className="text-gray-500">→</span>
                  </div>
                  <div className="bg-white p-4 hover:bg-gray-50 cursor-pointer flex justify-between items-center">
                    <span className="font-medium">Privacy Policy</span>
                    <span className="text-gray-500">→</span>
                  </div>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`{/* Appearance Section */}
<FlutterCupertinoListSection>
  <FlutterCupertinoListSectionHeader>
    Appearance
  </FlutterCupertinoListSectionHeader>
  {/* items... */}
</FlutterCupertinoListSection>

{/* Notifications Section */}
<FlutterCupertinoListSection>
  <FlutterCupertinoListSectionHeader>
    Notifications
  </FlutterCupertinoListSectionHeader>
  {/* items... */}
  <FlutterCupertinoListSectionFooter>
    Footer text...
  </FlutterCupertinoListSectionFooter>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* API Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">API Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoListSection</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">insetGrouped</code> — Use iOS Settings-style inset sections (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">children</code> — List items and optional header/footer (ReactNode)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoListSectionHeader</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">children</code> — Header content, typically text label (ReactNode)</li>
                  <li>Place as first child of FlutterCupertinoListSection</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoListSectionFooter</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">children</code> — Footer content, typically explanatory text (ReactNode)</li>
                  <li>Place as last child of FlutterCupertinoListSection</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Header Text:</strong> Use uppercase, smaller font for section headers to match iOS conventions</li>
                <li><strong>Footer Text:</strong> Use footer for explanatory text or additional context about the section</li>
                <li><strong>Item Separators:</strong> Add border-bottom between items (except last item) for visual separation</li>
                <li><strong>Inset Grouped:</strong> Use <code>insetGrouped=true</code> for Settings-style screens with rounded corners</li>
                <li><strong>Multiple Sections:</strong> Add spacing (e.g., mt-6) between consecutive sections</li>
                <li><strong>Interactive Items:</strong> Add hover states and cursor-pointer for clickable items</li>
                <li><strong>Consistency:</strong> Keep item heights and padding consistent within a section</li>
                <li><strong>Content Hierarchy:</strong> Place important content in headers, details in footers</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Component Structure</h4>
                <p className="text-sm text-fg-secondary">
                  FlutterCupertinoListSection is a container component. Place Header as the first child (optional),
                  list items in the middle, and Footer as the last child (optional).
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Standard vs Inset Grouped</h4>
                <p className="text-sm text-fg-secondary">
                  Standard sections span full width with no margins. Inset grouped sections have horizontal
                  margins and rounded corners, matching iOS Settings app style.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Item Content</h4>
                <p className="text-sm text-fg-secondary">
                  List items can contain any React content. Common patterns include text with chevron,
                  text with toggle switches, or text with secondary information.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Styling</h4>
                <p className="text-sm text-fg-secondary">
                  The component provides the grouping structure. You're responsible for styling individual
                  items including background colors, borders, padding, and hover states.
                </p>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
