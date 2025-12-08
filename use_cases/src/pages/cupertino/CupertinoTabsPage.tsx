import React, {useState} from 'react';
import {WebFListView} from '@openwebf/react-core-ui';
import {
  FlutterCupertinoTabBar,
  FlutterCupertinoTabBarItem,
  FlutterCupertinoTabScaffold,
  FlutterCupertinoTabScaffoldTab,
  FlutterCupertinoTabView,
  FlutterCupertinoIcon,
  CupertinoIcons, CupertinoColors,
} from '@openwebf/react-cupertino-ui';

export const CupertinoTabsPage: React.FC = () => {
  const [basicTabIndex, setBasicTabIndex] = useState(0);
  const [scaffoldTabIndex, setScaffoldTabIndex] = useState(0);
  const [customTabIndex, setCustomTabIndex] = useState(0);
  const [navTabIndex, setNavTabIndex] = useState(0);
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Tabs</h1>
          <p className="text-fg-secondary mb-6">iOS-style tab bars, scaffolds, and per-tab navigation.</p>

          {/* Basic TabBar */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic TabBar</h2>
            <p className="text-fg-secondary mb-4">A standalone bottom navigation bar with items.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg h-[300px] relative">
                <div className="p-6 text-center">
                  <h3 className="text-lg font-semibold mb-2">Selected Tab: {basicTabIndex}</h3>
                  <p className="text-gray-600">
                    {basicTabIndex === 0 && 'Home content'}
                    {basicTabIndex === 1 && 'Search content'}
                    {basicTabIndex === 2 && 'Profile content'}
                  </p>
                </div>

                <div className="absolute bottom-0 left-0 right-0">
                  <FlutterCupertinoTabBar
                    currentIndex={basicTabIndex}
                    onChange={(e) => setBasicTabIndex(e.detail)}
                  >
                    <FlutterCupertinoTabBarItem title="Home">
                      <FlutterCupertinoIcon type={CupertinoIcons.house_fill}/>
                    </FlutterCupertinoTabBarItem>
                    <FlutterCupertinoTabBarItem title="Search">
                      <FlutterCupertinoIcon type={CupertinoIcons.search}/>
                    </FlutterCupertinoTabBarItem>
                    <FlutterCupertinoTabBarItem title="Profile">
                      <FlutterCupertinoIcon type={CupertinoIcons.person_fill}/>
                    </FlutterCupertinoTabBarItem>
                  </FlutterCupertinoTabBar>
                </div>
              </div>
            </div>
          </section>

          {/* TabScaffold Basic */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">TabScaffold</h2>
            <p className="text-fg-secondary mb-4">Complete tab interface with integrated bottom bar and content areas.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg h-[400px]">
                <FlutterCupertinoTabScaffold
                  className="h-full"
                  currentIndex={scaffoldTabIndex}
                  onChange={(e) => setScaffoldTabIndex(e.detail)}
                >
                  <FlutterCupertinoTabScaffoldTab title="Home">
                    <FlutterCupertinoIcon type={CupertinoIcons.house_fill}/>
                    <div className="p-6">
                      <h3 className="text-lg font-semibold mb-2">Home</h3>
                      <p className="text-gray-600 mb-4">Welcome to the home tab.</p>
                      <div className="space-y-2">
                        <div className="bg-blue-50 p-4 rounded-lg">Recent Activity</div>
                        <div className="bg-blue-50 p-4 rounded-lg">Quick Actions</div>
                        <div className="bg-blue-50 p-4 rounded-lg">News Feed</div>
                      </div>
                    </div>
                  </FlutterCupertinoTabScaffoldTab>

                  <FlutterCupertinoTabScaffoldTab title="Favorites">
                    <FlutterCupertinoIcon type={CupertinoIcons.star_fill}/>
                    <div className="p-6">
                      <h3 className="text-lg font-semibold mb-2">Favorites</h3>
                      <p className="text-gray-600 mb-4">Your saved items appear here.</p>
                      <div className="space-y-2">
                        <div className="bg-yellow-50 p-4 rounded-lg flex items-center">
                          <FlutterCupertinoIcon type={CupertinoIcons.star_fill} className="text-2xl mr-3"/>
                          <span>Favorite Item 1</span>
                        </div>
                        <div className="bg-yellow-50 p-4 rounded-lg flex items-center">
                          <FlutterCupertinoIcon type={CupertinoIcons.star_fill} className="text-2xl mr-3"/>
                          <span>Favorite Item 2</span>
                        </div>
                      </div>
                    </div>
                  </FlutterCupertinoTabScaffoldTab>

                  <FlutterCupertinoTabScaffoldTab title="Settings">
                    <FlutterCupertinoIcon type={CupertinoIcons.gear_alt_fill}/>
                    <div className="p-6">
                      <h3 className="text-lg font-semibold mb-2">Settings</h3>
                      <p className="text-gray-600 mb-4">Manage your preferences.</p>
                      <div className="space-y-2">
                        <div className="bg-gray-50 p-4 rounded-lg">Account Settings</div>
                        <div className="bg-gray-50 p-4 rounded-lg">Privacy & Security</div>
                        <div className="bg-gray-50 p-4 rounded-lg">Notifications</div>
                        <div className="bg-gray-50 p-4 rounded-lg">About</div>
                      </div>
                    </div>
                  </FlutterCupertinoTabScaffoldTab>
                </FlutterCupertinoTabScaffold>
              </div>
            </div>
          </section>

          {/* TabScaffold with Custom TabBar */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">TabScaffold with Custom TabBar</h2>
            <p className="text-fg-secondary mb-4">Customize tab bar appearance with colors, icon size, and border.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg h-[400px]">
                <FlutterCupertinoTabScaffold
                  className="h-full"
                  currentIndex={customTabIndex}
                  onChange={(e) => setCustomTabIndex(e.detail)}
                >
                  <FlutterCupertinoTabBar
                    backgroundColor={CupertinoColors.systemGrey6}
                    activeColor={CupertinoColors.systemBlue}
                    inactiveColor={CupertinoColors.inactiveGray}
                    iconSize={32}
                    noTopBorder={false}
                  >
                    <FlutterCupertinoTabBarItem title="Chat">
                      <FlutterCupertinoIcon type={CupertinoIcons.bubble_left_bubble_right_fill}/>
                    </FlutterCupertinoTabBarItem>
                    <FlutterCupertinoTabBarItem title="Photos">
                      <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                    </FlutterCupertinoTabBarItem>
                    <FlutterCupertinoTabBarItem title="Music">
                      <FlutterCupertinoIcon type={CupertinoIcons.music_note_2}/>
                    </FlutterCupertinoTabBarItem>
                  </FlutterCupertinoTabBar>

                  <FlutterCupertinoTabScaffoldTab title="Chat">
                    <div className="p-6 h-full overflow-auto">
                      <h3 className="text-lg font-semibold mb-2">Messages</h3>
                      <p className="text-gray-600 mb-4">Your conversations.</p>
                      <div className="space-y-2 overflow-auto">
                        <div className="bg-blue-50 p-4 rounded-lg flex items-center gap-2">
                          <FlutterCupertinoIcon type={CupertinoIcons.bubble_left_bubble_right_fill}/>
                          <span>John Doe</span>
                        </div>
                        <div className="bg-blue-50 p-4 rounded-lg flex items-center gap-2">
                          <FlutterCupertinoIcon type={CupertinoIcons.bubble_left_bubble_right_fill}/>
                          <span>Jane Smith</span>
                        </div>
                        <div className="bg-blue-50 p-4 rounded-lg flex items-center gap-2">
                          <FlutterCupertinoIcon type={CupertinoIcons.bubble_left_bubble_right_fill}/>
                          <span>Team Chat</span>
                        </div>
                      </div>
                    </div>
                  </FlutterCupertinoTabScaffoldTab>

                  <FlutterCupertinoTabScaffoldTab title="Photos">
                    <div className="p-6 h-full overflow-auto">
                      <h3 className="text-lg font-semibold mb-2">Photo Library</h3>
                      <p className="text-gray-600 mb-4">Your photo collection.</p>
                      <div className="flex flex-wrap gap-2">
                        <div className="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-1/3">
                          <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                        </div>
                        <div className="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-1/3">
                          <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                        </div>
                        <div className="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-1/3">
                          <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                        </div>
                        <div className="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-1/3">
                          <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                        </div>
                        <div className="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-1/3">
                          <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                        </div>
                        <div className="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-1/3">
                          <FlutterCupertinoIcon type={CupertinoIcons.photo_fill}/>
                        </div>
                      </div>
                    </div>
                  </FlutterCupertinoTabScaffoldTab>

                  <FlutterCupertinoTabScaffoldTab title="Music">
                    <div className="p-6 h-full overflow-auto">
                      <h3 className="text-lg font-semibold mb-2">Music Player</h3>
                      <p className="text-gray-600 mb-4">Your music library.</p>
                      <div className="space-y-2">
                        <div className="bg-pink-50 p-4 rounded-lg flex items-center gap-2">
                          <FlutterCupertinoIcon type={CupertinoIcons.music_note_2}/>
                          <span>Recently Played</span>
                        </div>
                        <div className="bg-pink-50 p-4 rounded-lg flex items-center gap-2">
                          <FlutterCupertinoIcon type={CupertinoIcons.music_note_2}/>
                          <span>Playlists</span>
                        </div>
                        <div className="bg-pink-50 p-4 rounded-lg flex items-center gap-2">
                          <FlutterCupertinoIcon type={CupertinoIcons.music_note_2}/>
                          <span>Albums</span>
                        </div>
                      </div>
                    </div>
                  </FlutterCupertinoTabScaffoldTab>
                </FlutterCupertinoTabScaffold>
              </div>
            </div>
          </section>

          {/* TabView with Navigation */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">TabView with Per-Tab Navigation</h2>
            <p className="text-fg-secondary mb-4">Each tab maintains its own navigation stack using TabView.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden h-[400px]">
                <FlutterCupertinoTabScaffold
                  className="h-full"
                  currentIndex={navTabIndex}
                  onChange={(e) => setNavTabIndex(e.detail)}
                >
                  <FlutterCupertinoTabScaffoldTab title="Feed">
                    <FlutterCupertinoIcon type={CupertinoIcons.rectangle_stack_fill}/>
                    <FlutterCupertinoTabView defaultTitle="Feed">
                      <div className="p-6">
                        <h3 className="text-lg font-semibold mb-2">Activity Feed</h3>
                        <p className="text-gray-600 mb-4">Latest updates with navigation support.</p>
                        <div className="space-y-2">
                          <div className="bg-indigo-50 p-4 rounded-lg border-l-4 border-indigo-500">
                            <div className="font-semibold">Update 1</div>
                            <div className="text-sm text-gray-600">Navigate to details →</div>
                          </div>
                          <div className="bg-indigo-50 p-4 rounded-lg border-l-4 border-indigo-500">
                            <div className="font-semibold">Update 2</div>
                            <div className="text-sm text-gray-600">Navigate to details →</div>
                          </div>
                          <div className="bg-indigo-50 p-4 rounded-lg border-l-4 border-indigo-500">
                            <div className="font-semibold">Update 3</div>
                            <div className="text-sm text-gray-600">Navigate to details →</div>
                          </div>
                        </div>
                      </div>
                    </FlutterCupertinoTabView>
                  </FlutterCupertinoTabScaffoldTab>

                  <FlutterCupertinoTabScaffoldTab title="Account">
                    <FlutterCupertinoIcon type={CupertinoIcons.person_crop_circle_fill}/>
                    <FlutterCupertinoTabView defaultTitle="Account">
                      <div className="p-6">
                        <h3 className="text-lg font-semibold mb-2">Your Account</h3>
                        <p className="text-gray-600 mb-4">Account settings with independent navigation.</p>
                        <div className="space-y-2">
                          <div className="bg-green-50 p-4 rounded-lg">Profile Information</div>
                          <div className="bg-green-50 p-4 rounded-lg">Security Settings</div>
                          <div className="bg-green-50 p-4 rounded-lg">Subscription</div>
                          <div className="bg-green-50 p-4 rounded-lg">Billing History</div>
                        </div>
                      </div>
                    </FlutterCupertinoTabView>
                  </FlutterCupertinoTabScaffoldTab>
                </FlutterCupertinoTabScaffold>
              </div>
            </div>
          </section>

          {/* Props Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Props Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-2">FlutterCupertinoTabBar</h3>
                <ul className="space-y-1 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">currentIndex</code> — Active tab index (number)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">backgroundColor</code> — Hex color (#RRGGBB or #AARRGGBB)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">activeColor</code> — Active item color</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">inactiveColor</code> — Inactive items color</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">iconSize</code> — Icon size in pixels</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">noTopBorder</code> — Remove top border (boolean)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Selection change event</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-2">FlutterCupertinoTabScaffold</h3>
                <ul className="space-y-1 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">currentIndex</code> — Active tab index (number)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">resizeToAvoidBottomInset</code> — Reserved for parity (boolean)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Tab change event (e.detail contains index)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-2">FlutterCupertinoTabView</h3>
                <ul className="space-y-1 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">defaultTitle</code> — Default Navigator title (string)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">restorationScopeId</code> — State restoration ID (string)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-2">FlutterCupertinoTabBarItem</h3>
                <ul className="space-y-1 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">title</code> — Label below the icon (string)</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>TabBar</strong> can be used standalone or nested in TabScaffold for appearance customization</li>
                <li><strong>TabScaffold</strong> uses IndexedStack to keep off-screen tabs alive (state persists)</li>
                <li><strong>TabView</strong> provides per-tab Navigator for independent navigation stacks</li>
                <li>Event <code>change</code> maps to <code>onChange</code> in React with index in <code>event.detail</code></li>
                <li>Keep TabScaffoldTab count/order in sync with TabBarItem when using nested TabBar</li>
              </ul>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
