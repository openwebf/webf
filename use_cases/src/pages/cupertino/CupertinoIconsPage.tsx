import React, {useState} from 'react';
import {WebFListView} from '@openwebf/react-core-ui';
import {FlutterCupertinoIcon, CupertinoIcons} from '@openwebf/react-cupertino-ui';

export const CupertinoIconsPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');

  // Popular icons for quick reference
  const popularIcons = [
    {name: 'house_fill', label: 'House'},
    {name: 'person_fill', label: 'Person'},
    {name: 'star_fill', label: 'Star'},
    {name: 'heart_fill', label: 'Heart'},
    {name: 'gear_alt_fill', label: 'Settings'},
    {name: 'search', label: 'Search'},
    {name: 'plus_circle_fill', label: 'Add'},
    {name: 'trash_fill', label: 'Delete'},
    {name: 'pencil', label: 'Edit'},
    {name: 'checkmark_alt', label: 'Check'},
    {name: 'xmark', label: 'Close'},
    {name: 'info_circle_fill', label: 'Info'},
    {name: 'exclamationmark_triangle_fill', label: 'Warning'},
    {name: 'arrow_right', label: 'Arrow Right'},
    {name: 'arrow_left', label: 'Arrow Left'},
    {name: 'arrow_up', label: 'Arrow Up'},
    {name: 'arrow_down', label: 'Arrow Down'},
    {name: 'chevron_right', label: 'Chevron Right'},
    {name: 'photo_fill', label: 'Photo'},
    {name: 'camera_fill', label: 'Camera'},
    {name: 'music_note_2', label: 'Music'},
    {name: 'doc_text_fill', label: 'Document'},
    {name: 'folder_fill', label: 'Folder'},
    {name: 'calendar', label: 'Calendar'},
    {name: 'clock_fill', label: 'Clock'},
    {name: 'bell_fill', label: 'Notification'},
    {name: 'bubble_left_bubble_right_fill', label: 'Chat'},
    {name: 'phone_fill', label: 'Phone'},
    {name: 'location_fill', label: 'Location'},
    {name: 'map_fill', label: 'Map'},
  ];

  // Get all icon names from the enum
  const allIconNames = Object.keys(CupertinoIcons).filter(key =>
    typeof CupertinoIcons[key as keyof typeof CupertinoIcons] === 'string'
  );

  const filteredIcons = searchTerm
    ? allIconNames.filter(name => name.toLowerCase().includes(searchTerm.toLowerCase()))
    : [];

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Icons</h1>
          <p className="text-fg-secondary mb-6">iOS SF Symbols icon set for your applications.</p>

          {/* Basic Usage */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Usage</h2>
            <p className="text-fg-secondary mb-4">Import FlutterCupertinoIcon and CupertinoIcons from the library.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="flex flex-wrap gap-6 items-center justify-center">
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.house_fill} className="text-4xl"/>
                  <span className="text-sm text-fg-secondary">Default Size</span>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.star_fill} className="text-6xl text-yellow-500"/>
                  <span className="text-sm text-fg-secondary">Large & Colored</span>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.heart_fill} className="text-5xl text-red-500"/>
                  <span className="text-sm text-fg-secondary">Custom Color</span>
                </div>
              </div>

              <div className="mt-6 p-4 bg-gray-900 text-gray-100 rounded overflow-x-auto text-sm">
                <pre>{`import { FlutterCupertinoIcon, CupertinoIcons } from '@openwebf/react-cupertino-ui';

// Basic usage
<FlutterCupertinoIcon type={CupertinoIcons.house_fill} />

// With size and color
<FlutterCupertinoIcon
  type={CupertinoIcons.star_fill}
  className="text-6xl text-yellow-500"
/>`}</pre>
              </div>
            </div>
          </section>

          {/* Popular Icons */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Popular Icons</h2>
            <p className="text-fg-secondary mb-4">Commonly used icons in iOS applications.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <div className="flex flex-wrap gap-4">
                {popularIcons.map((icon) => (
                  <div
                    key={icon.name}
                    className="flex flex-col items-center gap-2 p-3 rounded-lg hover:bg-surface-tertiary transition-colors cursor-pointer"
                    title={icon.name}
                  >
                    <FlutterCupertinoIcon
                      type={CupertinoIcons[icon.name as keyof typeof CupertinoIcons]}
                      className="text-3xl text-fg-primary"
                    />
                    <span className="text-xs text-fg-secondary text-center leading-tight">{icon.label}</span>
                  </div>
                ))}
              </div>
            </div>
          </section>

          {/* Sizes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Icon Sizes</h2>
            <p className="text-fg-secondary mb-4">Control icon size using Tailwind CSS classes.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <div className="flex flex-wrap gap-8 items-end justify-center">
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} className="text-sm"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-sm</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} className="text-base"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-base</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} className="text-xl"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-xl</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} className="text-2xl"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-2xl</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} className="text-4xl"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-4xl</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill} className="text-6xl"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-6xl</code>
                </div>
              </div>
            </div>
          </section>

          {/* Colors */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Icon Colors</h2>
            <p className="text-fg-secondary mb-4">Apply colors using Tailwind CSS or inline styles.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <div className="flex flex-wrap gap-8 items-center justify-center">
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.heart_fill} className="text-4xl text-red-500"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-red-500</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.star_fill} className="text-4xl text-yellow-500"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-yellow-500</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.checkmark_circle_fill} className="text-4xl text-green-500"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-green-500</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.info_circle_fill} className="text-4xl text-blue-500"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-blue-500</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.exclamationmark_triangle_fill} className="text-4xl text-orange-500"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-orange-500</code>
                </div>
                <div className="flex flex-col items-center gap-2">
                  <FlutterCupertinoIcon type={CupertinoIcons.xmark_circle_fill} className="text-4xl text-gray-500"/>
                  <code className="text-xs bg-gray-100 px-2 py-1 rounded">text-gray-500</code>
                </div>
              </div>
            </div>
          </section>

          {/* Common Use Cases */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Use Cases</h2>
            <p className="text-fg-secondary mb-4">Real-world examples of icon usage.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              {/* Button with Icon */}
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Buttons with Icons</h3>
                <div className="flex flex-wrap gap-3">
                  <button className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
                    <FlutterCupertinoIcon type={CupertinoIcons.plus_circle_fill}/>
                    <span>Add Item</span>
                  </button>
                  <button className="flex items-center gap-2 px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors">
                    <FlutterCupertinoIcon type={CupertinoIcons.trash_fill}/>
                    <span>Delete</span>
                  </button>
                  <button className="flex items-center gap-2 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors">
                    <FlutterCupertinoIcon type={CupertinoIcons.checkmark_circle_fill}/>
                    <span>Confirm</span>
                  </button>
                </div>
              </div>

              {/* List Items */}
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">List Items</h3>
                <div className="space-y-2">
                  <div className="flex items-center gap-3 p-3 bg-surface rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.person_circle_fill} className="text-2xl text-blue-500"/>
                    <div className="flex-1">
                      <div className="font-medium">Profile Settings</div>
                      <div className="text-sm text-fg-secondary">Manage your account</div>
                    </div>
                    <FlutterCupertinoIcon type={CupertinoIcons.chevron_right} className="text-gray-400"/>
                  </div>
                  <div className="flex items-center gap-3 p-3 bg-surface rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.bell_fill} className="text-2xl text-purple-500"/>
                    <div className="flex-1">
                      <div className="font-medium">Notifications</div>
                      <div className="text-sm text-fg-secondary">Manage alerts</div>
                    </div>
                    <FlutterCupertinoIcon type={CupertinoIcons.chevron_right} className="text-gray-400"/>
                  </div>
                  <div className="flex items-center gap-3 p-3 bg-surface rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.lock_fill} className="text-2xl text-red-500"/>
                    <div className="flex-1">
                      <div className="font-medium">Privacy & Security</div>
                      <div className="text-sm text-fg-secondary">Control your privacy</div>
                    </div>
                    <FlutterCupertinoIcon type={CupertinoIcons.chevron_right} className="text-gray-400"/>
                  </div>
                </div>
              </div>

              {/* Status Indicators */}
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Status Indicators</h3>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 p-3 bg-green-50 border border-green-200 rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.checkmark_circle_fill} className="text-xl text-green-600"/>
                    <span className="text-green-800">Success! Your changes have been saved.</span>
                  </div>
                  <div className="flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.info_circle_fill} className="text-xl text-blue-600"/>
                    <span className="text-blue-800">Information: Please review the details below.</span>
                  </div>
                  <div className="flex items-center gap-2 p-3 bg-orange-50 border border-orange-200 rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.exclamationmark_triangle_fill} className="text-xl text-orange-600"/>
                    <span className="text-orange-800">Warning: This action cannot be undone.</span>
                  </div>
                  <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
                    <FlutterCupertinoIcon type={CupertinoIcons.xmark_circle_fill} className="text-xl text-red-600"/>
                    <span className="text-red-800">Error: Something went wrong.</span>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Search Icons */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Search Icons</h2>
            <p className="text-fg-secondary mb-4">Search through {allIconNames.length} available icons.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <div className="mb-4">
                <input
                  type="text"
                  placeholder="Search icons... (e.g., 'heart', 'star', 'person')"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full px-4 py-3 border border-line rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

              {searchTerm && (
                <div>
                  <div className="text-sm text-fg-secondary mb-3">
                    Found {filteredIcons.length} icon{filteredIcons.length !== 1 ? 's' : ''}
                  </div>
                  {filteredIcons.length > 0 ? (
                    <div className="flex flex-wrap gap-3 max-h-96 overflow-y-auto">
                      {filteredIcons.slice(0, 50).map((iconName) => (
                        <div
                          key={iconName}
                          className="flex flex-col items-center gap-2 p-3 rounded-lg hover:bg-surface-tertiary transition-colors cursor-pointer w-1/3 md:w-1/4 lg:w-1/6"
                          title={iconName}
                        >
                          <FlutterCupertinoIcon
                            type={CupertinoIcons[iconName as keyof typeof CupertinoIcons]}
                            className="text-3xl text-fg-primary"
                          />
                          <span className="text-xs text-fg-secondary text-center leading-tight break-all">{iconName}</span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="text-center py-8 text-fg-secondary">
                      No icons found matching "{searchTerm}"
                    </div>
                  )}
                  {filteredIcons.length > 50 && (
                    <div className="text-center mt-3 text-sm text-fg-secondary">
                      Showing first 50 results. Refine your search for more specific results.
                    </div>
                  )}
                </div>
              )}

              {!searchTerm && (
                <div className="text-center py-8 text-fg-secondary">
                  Start typing to search icons...
                </div>
              )}
            </div>
          </section>

          {/* Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li>Icons are based on Apple's SF Symbols system</li>
                <li>Use the <code className="bg-gray-200 px-1 rounded">CupertinoIcons</code> enum for type-safe icon names</li>
                <li>Control size with Tailwind's text size classes (<code className="bg-gray-200 px-1 rounded">text-xl</code>, <code className="bg-gray-200 px-1 rounded">text-4xl</code>, etc.)</li>
                <li>Apply colors using Tailwind color classes or inline styles</li>
                <li>Icons with <code className="bg-gray-200 px-1 rounded">_fill</code> suffix are solid/filled variants</li>
                <li>Use icons to enhance user experience and provide visual cues</li>
              </ul>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
