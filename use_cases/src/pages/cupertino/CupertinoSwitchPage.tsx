import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoSwitch } from '@openwebf/react-cupertino-ui';

export const CupertinoSwitchPage: React.FC = () => {
  const [basicSwitch, setBasicSwitch] = useState(false);
  const [notificationsOn, setNotificationsOn] = useState(true);
  const [wifiOn, setWifiOn] = useState(false);
  const [bluetoothOn, setBluetoothOn] = useState(true);
  const [airplaneModeOn, setAirplaneModeOn] = useState(false);
  const [locationOn, setLocationOn] = useState(true);
  const [customColorSwitch, setCustomColorSwitch] = useState(true);
  const [inactiveColorSwitch, setInactiveColorSwitch] = useState(false);
  const [lastChange, setLastChange] = useState('');

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Switch</h1>
          <p className="text-fg-secondary mb-6">iOS-style toggle switch control with smooth animations.</p>

          {/* Basic Switch */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Switch</h2>
            <p className="text-fg-secondary mb-4">Simple on/off toggle with default iOS green color.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                <div>
                  <div className="font-semibold">Enable Feature</div>
                  <div className="text-sm text-gray-600">
                    Status: {basicSwitch ? 'On' : 'Off'}
                  </div>
                </div>
                <FlutterCupertinoSwitch
                  checked={basicSwitch}
                  onChange={(e) => {
                    setBasicSwitch(e.detail);
                    setLastChange(`Basic switch: ${e.detail ? 'ON' : 'OFF'}`);
                  }}
                />
              </div>
              {lastChange && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last change: {lastChange}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [enabled, setEnabled] = useState(false);

<FlutterCupertinoSwitch
  checked={enabled}
  onChange={(e) => setEnabled(e.detail)}
/>`}</code></pre>
            </div>
          </section>

          {/* Settings List Example */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Settings List Example</h2>
            <p className="text-fg-secondary mb-4">Multiple switches in a settings-style list.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden divide-y divide-gray-200">
                <div className="flex items-center justify-between p-4">
                  <div>
                    <div className="font-semibold">Notifications</div>
                    <div className="text-sm text-gray-600">Allow notifications and alerts</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={notificationsOn}
                    onChange={(e) => {
                      setNotificationsOn(e.detail);
                      setLastChange(`Notifications: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>

                <div className="flex items-center justify-between p-4">
                  <div>
                    <div className="font-semibold">Wi-Fi</div>
                    <div className="text-sm text-gray-600">
                      {wifiOn ? 'Connected to Home Network' : 'Not connected'}
                    </div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={wifiOn}
                    onChange={(e) => {
                      setWifiOn(e.detail);
                      setLastChange(`Wi-Fi: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>

                <div className="flex items-center justify-between p-4">
                  <div>
                    <div className="font-semibold">Bluetooth</div>
                    <div className="text-sm text-gray-600">
                      {bluetoothOn ? 'On' : 'Off'}
                    </div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={bluetoothOn}
                    onChange={(e) => {
                      setBluetoothOn(e.detail);
                      setLastChange(`Bluetooth: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>

                <div className="flex items-center justify-between p-4">
                  <div>
                    <div className="font-semibold">Airplane Mode</div>
                    <div className="text-sm text-gray-600">
                      {airplaneModeOn ? 'Wireless services disabled' : 'All services active'}
                    </div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={airplaneModeOn}
                    onChange={(e) => {
                      setAirplaneModeOn(e.detail);
                      setLastChange(`Airplane Mode: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>

                <div className="flex items-center justify-between p-4">
                  <div>
                    <div className="font-semibold">Location Services</div>
                    <div className="text-sm text-gray-600">
                      {locationOn ? 'Apps can access location' : 'Location access disabled'}
                    </div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={locationOn}
                    onChange={(e) => {
                      setLocationOn(e.detail);
                      setLastChange(`Location: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>
              </div>
              {lastChange && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last change: {lastChange}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<div className="settings-list">
  <div className="setting-item">
    <span>Wi-Fi</span>
    <FlutterCupertinoSwitch
      checked={wifiOn}
      onChange={(e) => setWifiOn(e.detail)}
    />
  </div>
  <div className="setting-item">
    <span>Bluetooth</span>
    <FlutterCupertinoSwitch
      checked={bluetoothOn}
      onChange={(e) => setBluetoothOn(e.detail)}
    />
  </div>
</div>`}</code></pre>
            </div>
          </section>

          {/* Disabled State */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
            <p className="text-fg-secondary mb-4">Switches can be disabled to prevent user interaction.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold text-gray-400">Disabled (Off)</div>
                    <div className="text-sm text-gray-500">Cannot be toggled</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={false}
                    disabled={true}
                    onChange={(e) => console.log('Should not fire', e.detail)}
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold text-gray-400">Disabled (On)</div>
                    <div className="text-sm text-gray-500">Cannot be toggled</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={true}
                    disabled={true}
                    onChange={(e) => console.log('Should not fire', e.detail)}
                  />
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoSwitch
  checked={false}
  disabled={true}
  onChange={(e) => console.log('Will not fire')}
/>

<FlutterCupertinoSwitch
  checked={true}
  disabled={true}
  onChange={(e) => console.log('Will not fire')}
/>`}</code></pre>
            </div>
          </section>

          {/* Custom Colors */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
            <p className="text-fg-secondary mb-4">Customize active and inactive colors using hex values.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Blue Active Color</div>
                    <div className="text-sm text-gray-600">Custom #007AFF when on</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={customColorSwitch}
                    activeColor="#007AFF"
                    onChange={(e) => {
                      setCustomColorSwitch(e.detail);
                      setLastChange(`Blue switch: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Purple Active Color</div>
                    <div className="text-sm text-gray-600">Custom #AF52DE when on</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={true}
                    activeColor="#AF52DE"
                    onChange={(e) => setLastChange(`Purple switch: ${e.detail ? 'ON' : 'OFF'}`)}
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Red Active Color</div>
                    <div className="text-sm text-gray-600">Custom #FF3B30 when on</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={true}
                    activeColor="#FF3B30"
                    onChange={(e) => setLastChange(`Red switch: ${e.detail ? 'ON' : 'OFF'}`)}
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Orange Active Color</div>
                    <div className="text-sm text-gray-600">Custom #FF9500 when on</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={true}
                    activeColor="#FF9500"
                    onChange={(e) => setLastChange(`Orange switch: ${e.detail ? 'ON' : 'OFF'}`)}
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Custom Inactive Color</div>
                    <div className="text-sm text-gray-600">Custom #FFC0CB when off</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={inactiveColorSwitch}
                    activeColor="#34C759"
                    inactiveColor="#FFC0CB"
                    onChange={(e) => {
                      setInactiveColorSwitch(e.detail);
                      setLastChange(`Custom inactive: ${e.detail ? 'ON' : 'OFF'}`);
                    }}
                  />
                </div>
              </div>
              {lastChange && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last change: {lastChange}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Blue active color
<FlutterCupertinoSwitch
  checked={true}
  activeColor="#007AFF"
/>

// Red active color (for warnings)
<FlutterCupertinoSwitch
  checked={true}
  activeColor="#FF3B30"
/>

// Custom inactive color
<FlutterCupertinoSwitch
  checked={false}
  activeColor="#34C759"
  inactiveColor="#FFC0CB"
/>`}</code></pre>
            </div>
          </section>

          {/* Controlled vs Uncontrolled */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Controlled vs Uncontrolled</h2>
            <p className="text-fg-secondary mb-4">Switches can be controlled (with state) or uncontrolled.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Controlled Switch</div>
                    <div className="text-sm text-gray-600">Managed by React state</div>
                  </div>
                  <FlutterCupertinoSwitch
                    checked={basicSwitch}
                    onChange={(e) => setBasicSwitch(e.detail)}
                  />
                </div>

                <div className="flex items-center justify-between p-4 bg-white rounded-lg">
                  <div>
                    <div className="font-semibold">Uncontrolled Switch</div>
                    <div className="text-sm text-gray-600">Manages its own state internally</div>
                  </div>
                  <FlutterCupertinoSwitch
                    onChange={(e) => setLastChange(`Uncontrolled: ${e.detail ? 'ON' : 'OFF'}`)}
                  />
                </div>
              </div>
              {lastChange && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">
                  Last change: {lastChange}
                </div>
              )}
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Controlled - requires state management
const [checked, setChecked] = useState(false);
<FlutterCupertinoSwitch
  checked={checked}
  onChange={(e) => setChecked(e.detail)}
/>

// Uncontrolled - manages its own state
<FlutterCupertinoSwitch
  onChange={(e) => console.log('Changed to:', e.detail)}
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
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">checked</code> — Current state of the switch (boolean, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">disabled</code> — Prevents user interaction (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">activeColor</code> — Color when switch is on (string hex, default: iOS green #34C759)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">inactiveColor</code> — Color when switch is off (string hex, optional)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Fired when switch state changes (event: CustomEvent{'<boolean>'})</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">e.detail</code> — Boolean value of the new state (true = on, false = off)</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Controlled State:</strong> Use controlled switches (with <code>checked</code> prop) for better state management</li>
                <li><strong>Labels:</strong> Always provide clear labels next to switches to indicate what they control</li>
                <li><strong>Feedback:</strong> Show immediate visual feedback when the state changes (e.g., update UI or text)</li>
                <li><strong>Default Colors:</strong> Use default iOS green unless you have a specific reason for custom colors</li>
                <li><strong>Disabled State:</strong> Use disabled state for switches that cannot be changed due to system constraints</li>
                <li><strong>Touch Target:</strong> Ensure the entire row is tappable in settings lists, not just the switch</li>
                <li><strong>Status Text:</strong> Show current status (On/Off or more descriptive text) near the switch</li>
                <li><strong>Color Meaning:</strong> If using custom colors, use red for destructive/warning actions</li>
                <li><strong>Accessibility:</strong> Switches should have sufficient contrast and be keyboard accessible</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Color Format</h4>
                <p className="text-sm text-fg-secondary">
                  Use hex color format for activeColor and inactiveColor (e.g., "#34C759" or "#FF3B30").
                  Both 6-digit (#RRGGBB) and 8-digit (#AARRGGBB) formats are supported.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">onChange Event</h4>
                <p className="text-sm text-fg-secondary">
                  The onChange event fires when the user toggles the switch. Access the new state via <code>e.detail</code> which is a boolean.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Disabled State</h4>
                <p className="text-sm text-fg-secondary">
                  When disabled, the switch appears dimmed and does not respond to user interaction.
                  The onChange event will not fire for disabled switches.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Animation</h4>
                <p className="text-sm text-fg-secondary">
                  The switch includes smooth iOS-style animation when toggling between states.
                  This animation is built-in and automatic.
                </p>
              </div>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Settings Row</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div className="flex items-center justify-between p-4">
  <div>
    <div className="font-semibold">Wi-Fi</div>
    <div className="text-sm text-gray-600">
      {wifiOn ? 'Connected' : 'Not connected'}
    </div>
  </div>
  <FlutterCupertinoSwitch
    checked={wifiOn}
    onChange={(e) => setWifiOn(e.detail)}
  />
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Confirmation Dialog</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [enabled, setEnabled] = useState(false);

const handleChange = (newValue: boolean) => {
  if (newValue) {
    // Show confirmation
    if (confirm('Enable this feature?')) {
      setEnabled(true);
    }
  } else {
    setEnabled(false);
  }
};

<FlutterCupertinoSwitch
  checked={enabled}
  onChange={(e) => handleChange(e.detail)}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Dependent Settings</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [parentEnabled, setParentEnabled] = useState(true);
const [childEnabled, setChildEnabled] = useState(false);

<FlutterCupertinoSwitch
  checked={parentEnabled}
  onChange={(e) => {
    setParentEnabled(e.detail);
    if (!e.detail) setChildEnabled(false); // Disable child
  }}
/>

<FlutterCupertinoSwitch
  checked={childEnabled}
  disabled={!parentEnabled}
  onChange={(e) => setChildEnabled(e.detail)}
/>`}</code></pre>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};

