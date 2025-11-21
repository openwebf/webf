import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoListTile,
  FlutterCupertinoListTileLeading,
  FlutterCupertinoListTileSubtitle,
  FlutterCupertinoListTileAdditionalInfo,
  FlutterCupertinoListTileTrailing,
  FlutterCupertinoListSection,
  FlutterCupertinoIcon,
  CupertinoIcons,
} from '@openwebf/react-cupertino-ui';

export const CupertinoListTilePage: React.FC = () => {
  const [wifiEnabled, setWifiEnabled] = useState(true);
  const [bluetoothEnabled, setBluetoothEnabled] = useState(false);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [eventLog, setEventLog] = useState<string[]>([]);

  const addEventLog = (message: string) => {
    setEventLog(prev => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino List Tile</h1>
          <p className="text-fg-secondary mb-6">iOS-style list rows for building settings pages, menus, and navigation lists.</p>

          {/* Basic List Tile */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic List Tile</h2>
            <p className="text-fg-secondary mb-4">Simple list tile with title and optional chevron indicator.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile showChevron={true}>
                    Wi-Fi
                    <FlutterCupertinoListTileAdditionalInfo>
                      HomeNetwork
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    Bluetooth
                    <FlutterCupertinoListTileAdditionalInfo>
                      Off
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    Cellular
                    <FlutterCupertinoListTileAdditionalInfo>
                      T-Mobile
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListTile showChevron={true}>
  Wi-Fi
  <FlutterCupertinoListTileAdditionalInfo>
    HomeNetwork
  </FlutterCupertinoListTileAdditionalInfo>
</FlutterCupertinoListTile>`}</code></pre>
            </div>
          </section>

          {/* With Leading Icon */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">List Tile with Leading Icon</h2>
            <p className="text-fg-secondary mb-4">Add icons or avatars to the leading edge of list tiles.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div id={"bug"} className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.phone_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Phone
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.bubble_left_bubble_right_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Messages
                    <FlutterCupertinoListTileAdditionalInfo>
                      3 new
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-purple-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Settings
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListTile showChevron={true}>
  <FlutterCupertinoListTileLeading>
    <div className="w-8 h-8 rounded-full bg-blue-500" />
  </FlutterCupertinoListTileLeading>
  Phone
</FlutterCupertinoListTile>`}</code></pre>
            </div>
          </section>

          {/* With Subtitle */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">List Tile with Subtitle</h2>
            <p className="text-fg-secondary mb-4">Add secondary text below the main title for additional context.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.bell_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Notifications
                    <FlutterCupertinoListTileSubtitle>
                      Push, email, and SMS notifications
                    </FlutterCupertinoListTileSubtitle>
                    <FlutterCupertinoListTileAdditionalInfo>
                      On
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.lock_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Privacy & Security
                    <FlutterCupertinoListTileSubtitle>
                      Control your data and how it's used
                    </FlutterCupertinoListTileSubtitle>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-orange-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.globe} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Language & Region
                    <FlutterCupertinoListTileSubtitle>
                      English, United States
                    </FlutterCupertinoListTileSubtitle>
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListTile showChevron={true}>
  <FlutterCupertinoListTileLeading>
    <div className="w-8 h-8 rounded-full bg-blue-500" />
  </FlutterCupertinoListTileLeading>
  Notifications
  <FlutterCupertinoListTileSubtitle>
    Push, email, and SMS notifications
  </FlutterCupertinoListTileSubtitle>
  <FlutterCupertinoListTileAdditionalInfo>
    On
  </FlutterCupertinoListTileAdditionalInfo>
</FlutterCupertinoListTile>`}</code></pre>
            </div>
          </section>

          {/* Custom Trailing Widget */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Trailing Widget</h2>
            <p className="text-fg-secondary mb-4">Replace the default chevron with custom trailing content like switches, badges, or buttons.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.wifi} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Wi-Fi
                    <FlutterCupertinoListTileSubtitle>
                      {wifiEnabled ? 'Connected to HomeNetwork' : 'Not connected'}
                    </FlutterCupertinoListTileSubtitle>
                    <FlutterCupertinoListTileTrailing>
                      <label className="relative inline-block w-12 h-7">
                        <input
                          type="checkbox"
                          checked={wifiEnabled}
                          onChange={(e) => setWifiEnabled(e.target.checked)}
                          className="sr-only peer"
                        />
                        <span className="absolute inset-0 bg-gray-300 peer-checked:bg-green-500 rounded-full transition-colors duration-200 cursor-pointer"></span>
                        <span className="absolute left-1 top-1 bg-white w-5 h-5 rounded-full transition-transform duration-200 peer-checked:translate-x-5"></span>
                      </label>
                    </FlutterCupertinoListTileTrailing>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.bluetooth} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Bluetooth
                    <FlutterCupertinoListTileSubtitle>
                      {bluetoothEnabled ? 'On' : 'Off'}
                    </FlutterCupertinoListTileSubtitle>
                    <FlutterCupertinoListTileTrailing>
                      <label className="relative inline-block w-12 h-7">
                        <input
                          type="checkbox"
                          checked={bluetoothEnabled}
                          onChange={(e) => setBluetoothEnabled(e.target.checked)}
                          className="sr-only peer"
                        />
                        <span className="absolute inset-0 bg-gray-300 peer-checked:bg-green-500 rounded-full transition-colors duration-200 cursor-pointer"></span>
                        <span className="absolute left-1 top-1 bg-white w-5 h-5 rounded-full transition-transform duration-200 peer-checked:translate-x-5"></span>
                      </label>
                    </FlutterCupertinoListTileTrailing>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.mail_solid} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Mail
                    <FlutterCupertinoListTileTrailing>
                      <span className="bg-red-500 text-white text-xs font-semibold px-2 py-1 rounded-full">
                        12
                      </span>
                    </FlutterCupertinoListTileTrailing>
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListTile>
  Wi-Fi
  <FlutterCupertinoListTileTrailing>
    <switch-component />
  </FlutterCupertinoListTileTrailing>
</FlutterCupertinoListTile>

<FlutterCupertinoListTile showChevron={true}>
  Mail
  <FlutterCupertinoListTileTrailing>
    <span className="badge">12</span>
  </FlutterCupertinoListTileTrailing>
</FlutterCupertinoListTile>`}</code></pre>
            </div>
          </section>

          {/* Notched Style */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Notched Visual Style</h2>
            <p className="text-fg-secondary mb-4">Use the notched style for a design similar to iOS Messages and Contacts apps.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile notched={true} showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-white font-semibold">
                        JD
                      </div>
                    </FlutterCupertinoListTileLeading>
                    John Doe
                    <FlutterCupertinoListTileSubtitle>
                      john.doe@example.com
                    </FlutterCupertinoListTileSubtitle>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile notched={true} showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center text-white font-semibold">
                        JS
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Jane Smith
                    <FlutterCupertinoListTileSubtitle>
                      jane.smith@example.com
                    </FlutterCupertinoListTileSubtitle>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile notched={true} showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center text-white font-semibold">
                        AB
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Alice Brown
                    <FlutterCupertinoListTileSubtitle>
                      alice.brown@example.com
                    </FlutterCupertinoListTileSubtitle>
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListTile notched={true} showChevron={true}>
  <FlutterCupertinoListTileLeading>
    <div className="w-10 h-10 rounded-full bg-blue-500">JD</div>
  </FlutterCupertinoListTileLeading>
  John Doe
  <FlutterCupertinoListTileSubtitle>
    john.doe@example.com
  </FlutterCupertinoListTileSubtitle>
</FlutterCupertinoListTile>`}</code></pre>
            </div>
          </section>

          {/* Interactive List Tiles */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Interactive List Tiles</h2>
            <p className="text-fg-secondary mb-4">Handle tap events on list tiles for navigation or actions.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile
                    showChevron={true}
                    onClick={() => addEventLog('Tapped: General')}
                  >
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-gray-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    General
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile
                    showChevron={true}
                    onClick={() => addEventLog('Tapped: Display & Brightness')}
                  >
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.sun_max_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Display & Brightness
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile
                    showChevron={true}
                    onClick={() => addEventLog('Tapped: Sounds & Haptics')}
                  >
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-pink-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.speaker_3_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Sounds & Haptics
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>

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
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoListTile
  showChevron={true}
  onClick={(event) => {
    console.log('List tile tapped');
    navigateToSettings();
  }}
>
  Settings
</FlutterCupertinoListTile>`}</code></pre>
            </div>
          </section>

          {/* Complex Examples */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Complex Examples</h2>
            <p className="text-fg-secondary mb-4">Real-world examples combining multiple features.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden">
                <div className="p-4 border-b border-gray-200">
                  <h3 className="text-lg font-semibold">Settings</h3>
                </div>

                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-white font-bold text-xs">
                        AB
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Apple ID
                    <FlutterCupertinoListTileSubtitle>
                      iCloud, Media & Purchases
                    </FlutterCupertinoListTileSubtitle>
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>

                <div className="p-3 bg-gray-50">
                  <p className="text-xs text-gray-500 uppercase font-semibold">Preferences</p>
                </div>

                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.airplane} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Airplane Mode
                    <FlutterCupertinoListTileTrailing>
                      <label className="relative inline-block w-12 h-7">
                        <input
                          type="checkbox"
                          checked={false}
                          onChange={() => {}}
                          className="sr-only peer"
                        />
                        <span className="absolute inset-0 bg-gray-300 peer-checked:bg-green-500 rounded-full transition-colors duration-200 cursor-pointer"></span>
                        <span className="absolute left-1 top-1 bg-white w-5 h-5 rounded-full transition-transform duration-200 peer-checked:translate-x-5"></span>
                      </label>
                    </FlutterCupertinoListTileTrailing>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.wifi} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Wi-Fi
                    <FlutterCupertinoListTileAdditionalInfo>
                      HomeNetwork
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.bluetooth} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Bluetooth
                    <FlutterCupertinoListTileAdditionalInfo>
                      On
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.device_phone_portrait} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Cellular
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.flame_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Personal Hotspot
                    <FlutterCupertinoListTileAdditionalInfo>
                      Off
                    </FlutterCupertinoListTileAdditionalInfo>
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>

                <div className="p-3 bg-gray-50">
                  <p className="text-xs text-gray-500 uppercase font-semibold">Notifications</p>
                </div>

                <FlutterCupertinoListSection>
                  <FlutterCupertinoListTile>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.bell_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Notifications
                    <FlutterCupertinoListTileSubtitle>
                      Badge, Sounds, Banners
                    </FlutterCupertinoListTileSubtitle>
                    <FlutterCupertinoListTileTrailing>
                      <label className="relative inline-block w-12 h-7">
                        <input
                          type="checkbox"
                          checked={notificationsEnabled}
                          onChange={(e) => setNotificationsEnabled(e.target.checked)}
                          className="sr-only peer"
                        />
                        <span className="absolute inset-0 bg-gray-300 peer-checked:bg-green-500 rounded-full transition-colors duration-200 cursor-pointer"></span>
                        <span className="absolute left-1 top-1 bg-white w-5 h-5 rounded-full transition-transform duration-200 peer-checked:translate-x-5"></span>
                      </label>
                    </FlutterCupertinoListTileTrailing>
                  </FlutterCupertinoListTile>

                  <FlutterCupertinoListTile showChevron={true}>
                    <FlutterCupertinoListTileLeading>
                      <div className="w-8 h-8 rounded-full bg-purple-500 flex items-center justify-center text-white text-sm">
                        <FlutterCupertinoIcon type={CupertinoIcons.moon_fill} />
                      </div>
                    </FlutterCupertinoListTileLeading>
                    Focus
                  </FlutterCupertinoListTile>
                </FlutterCupertinoListSection>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Settings page structure with sections
<FlutterCupertinoListSection>
  <FlutterCupertinoListTile showChevron={true}>
    <FlutterCupertinoListTileLeading>
      <Avatar />
    </FlutterCupertinoListTileLeading>
    Apple ID
    <FlutterCupertinoListTileSubtitle>
      iCloud, Media & Purchases
    </FlutterCupertinoListTileSubtitle>
  </FlutterCupertinoListTile>
</FlutterCupertinoListSection>

<SectionHeader>Preferences</SectionHeader>

<FlutterCupertinoListSection>
  <FlutterCupertinoListTile showChevron={true}>
    Wi-Fi
    <FlutterCupertinoListTileAdditionalInfo>
      HomeNetwork
    </FlutterCupertinoListTileAdditionalInfo>
  </FlutterCupertinoListTile>
</FlutterCupertinoListSection>`}</code></pre>
            </div>
          </section>

          {/* API Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">API Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoListTile Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">showChevron</code> — Show iOS-style chevron on trailing edge (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">notched</code> — Use notched visual style (boolean, default: false)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onClick</code> — Handler for tap events (event: Event) =&gt; void</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Slot Components</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">FlutterCupertinoListTileLeading</code> — Leading icon/avatar slot</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">FlutterCupertinoListTileSubtitle</code> — Secondary text below title</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">FlutterCupertinoListTileAdditionalInfo</code> — Right-aligned secondary label</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">FlutterCupertinoListTileTrailing</code> — Custom trailing widget (replaces chevron)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Import Statement</h3>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`import {
  FlutterCupertinoListTile,
  FlutterCupertinoListTileLeading,
  FlutterCupertinoListTileSubtitle,
  FlutterCupertinoListTileAdditionalInfo,
  FlutterCupertinoListTileTrailing,
  FlutterCupertinoListSection,
} from '@openwebf/react-cupertino-ui';`}</code></pre>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Group Related Items:</strong> Use FlutterCupertinoListSection to group related list tiles</li>
                <li><strong>Chevron Indicator:</strong> Use showChevron for tiles that navigate to another screen</li>
                <li><strong>Leading Icons:</strong> Use consistent icon sizes (typically 28-32px) for leading content</li>
                <li><strong>Subtitle Usage:</strong> Use subtitles for clarifying information, not essential content</li>
                <li><strong>Additional Info:</strong> Keep additional info text short (1-3 words)</li>
                <li><strong>Trailing Content:</strong> Use trailing slot for switches, badges, or other controls</li>
                <li><strong>Notched Style:</strong> Use notched style for contact lists and similar UIs</li>
                <li><strong>Touch Targets:</strong> Ensure adequate tap target size for interactive tiles</li>
                <li><strong>Dividers:</strong> FlutterCupertinoListSection handles dividers automatically</li>
                <li><strong>Section Headers:</strong> Use subtle section headers to organize long lists</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Chevron vs. Trailing</h4>
                <p className="text-sm text-fg-secondary">
                  The chevron indicator is automatically hidden when you provide a custom trailing widget. If you need both, include the chevron in your custom trailing component.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">List Section Integration</h4>
                <p className="text-sm text-fg-secondary">
                  Always wrap list tiles inside FlutterCupertinoListSection for proper iOS-style dividers, padding, and corner rounding.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Notched Style</h4>
                <p className="text-sm text-fg-secondary">
                  The notched prop creates a visual indentation similar to iOS Messages and Contacts apps. Best used with leading avatars or icons.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Event Handling</h4>
                <p className="text-sm text-fg-secondary">
                  Use onClick for navigation or actions. Avoid onClick on tiles with interactive trailing content (like switches) to prevent confusion.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Native Rendering</h4>
                <p className="text-sm text-fg-secondary">
                  List tiles are rendered by Flutter using native iOS Cupertino styling. Animations and interactions match iOS design guidelines.
                </p>
              </div>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Settings Row with Navigation</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<FlutterCupertinoListTile
  showChevron={true}
  onClick={() => navigate('/settings/wifi')}
>
  <FlutterCupertinoListTileLeading>
    <WifiIcon />
  </FlutterCupertinoListTileLeading>
  Wi-Fi
  <FlutterCupertinoListTileAdditionalInfo>
    HomeNetwork
  </FlutterCupertinoListTileAdditionalInfo>
</FlutterCupertinoListTile>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Settings Row with Toggle</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<FlutterCupertinoListTile>
  Airplane Mode
  <FlutterCupertinoListTileTrailing>
    <CupertinoSwitch
      value={airplaneMode}
      onChanged={setAirplaneMode}
    />
  </FlutterCupertinoListTileTrailing>
</FlutterCupertinoListTile>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Contact List Entry</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<FlutterCupertinoListTile
  notched={true}
  showChevron={true}
  onClick={() => openContact(contact.id)}
>
  <FlutterCupertinoListTileLeading>
    <Avatar src={contact.avatar} name={contact.name} />
  </FlutterCupertinoListTileLeading>
  {contact.name}
  <FlutterCupertinoListTileSubtitle>
    {contact.email}
  </FlutterCupertinoListTileSubtitle>
</FlutterCupertinoListTile>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Menu with Badge</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<FlutterCupertinoListTile showChevron={true}>
  <FlutterCupertinoListTileLeading>
    <MessageIcon />
  </FlutterCupertinoListTileLeading>
  Messages
  <FlutterCupertinoListTileTrailing>
    <Badge count={unreadCount} />
  </FlutterCupertinoListTileTrailing>
</FlutterCupertinoListTile>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Grouped Settings Section</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div>
  <SectionHeader>Network</SectionHeader>
  <FlutterCupertinoListSection>
    <FlutterCupertinoListTile showChevron={true}>
      Wi-Fi
      <FlutterCupertinoListTileAdditionalInfo>
        On
      </FlutterCupertinoListTileAdditionalInfo>
    </FlutterCupertinoListTile>
    <FlutterCupertinoListTile showChevron={true}>
      Bluetooth
      <FlutterCupertinoListTileAdditionalInfo>
        On
      </FlutterCupertinoListTileAdditionalInfo>
    </FlutterCupertinoListTile>
    <FlutterCupertinoListTile showChevron={true}>
      Cellular
    </FlutterCupertinoListTile>
  </FlutterCupertinoListSection>
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Rich Information Row</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<FlutterCupertinoListTile showChevron={true}>
  <FlutterCupertinoListTileLeading>
    <AppIcon src={app.icon} />
  </FlutterCupertinoListTileLeading>
  {app.name}
  <FlutterCupertinoListTileSubtitle>
    Version {app.version} • {app.size}
  </FlutterCupertinoListTileSubtitle>
  <FlutterCupertinoListTileAdditionalInfo>
    Installed
  </FlutterCupertinoListTileAdditionalInfo>
</FlutterCupertinoListTile>`}</code></pre>
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
                  Provide meaningful labels for screen readers by using descriptive text content and proper HTML structure.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Touch Targets</h4>
                <p className="text-sm text-fg-secondary">
                  List tiles automatically provide adequate touch target sizes (minimum 44pt) following iOS accessibility guidelines.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Focus Management</h4>
                <p className="text-sm text-fg-secondary">
                  Interactive list tiles support keyboard navigation and focus indicators for users with motor impairments.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Visual Hierarchy</h4>
                <p className="text-sm text-fg-secondary">
                  Use leading icons, titles, subtitles, and additional info to create clear visual hierarchy. Don't rely solely on color to convey information.
                </p>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
