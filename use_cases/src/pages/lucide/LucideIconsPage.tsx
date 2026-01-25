import React, {useState, useCallback, useMemo, useRef, useEffect} from 'react';
import {WebFListView, WebFListViewElement} from '@openwebf/react-core-ui';
import {FlutterLucideIcon, LucideIcons} from '@openwebf/react-lucide-icons';

const ICONS_PER_PAGE = 60;

export const LucideIconsPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [debouncedSearchTerm, setDebouncedSearchTerm] = useState('');
  const [displayCount, setDisplayCount] = useState(ICONS_PER_PAGE);
  const debounceTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const iconsListRef = useRef<WebFListViewElement>(null);

  // Debounce the search term
  useEffect(() => {
    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }
    debounceTimerRef.current = setTimeout(() => {
      setDebouncedSearchTerm(searchTerm);
    }, 300);
    return () => {
      if (debounceTimerRef.current) {
        clearTimeout(debounceTimerRef.current);
      }
    };
  }, [searchTerm]);

  // Get all icon names from the enum
  const allIconNames = useMemo(() =>
    Object.keys(LucideIcons).filter(key =>
      typeof LucideIcons[key as keyof typeof LucideIcons] === 'string'
    ),
    []
  );

  // Filter icons based on debounced search term
  const filteredIcons = useMemo(() => {
    if (!debouncedSearchTerm) return allIconNames;
    const term = debouncedSearchTerm.toLowerCase();
    return allIconNames.filter(name => name.toLowerCase().includes(term));
  }, [allIconNames, debouncedSearchTerm]);

  // Reset display count when search term changes
  useEffect(() => {
    setDisplayCount(ICONS_PER_PAGE);
  }, [debouncedSearchTerm]);

  const handleSearchChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(e.target.value);
  }, []);

  const handleLoadMore = useCallback(() => {
    const hasMore = displayCount < filteredIcons.length;
    if (hasMore) {
      setDisplayCount(prev => Math.min(prev + ICONS_PER_PAGE, filteredIcons.length));
      // Signal successful load
      setTimeout(() => {
        iconsListRef.current?.finishLoad('success');
      }, 100);
    } else {
      // No more items to load
      iconsListRef.current?.finishLoad('noMore');
    }
  }, [displayCount, filteredIcons.length]);

  // Icons to display
  const displayedIcons = useMemo(() => {
    return filteredIcons.slice(0, displayCount);
  }, [filteredIcons, displayCount]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Lucide Icons</h1>
        <p className="text-fg-secondary mb-6">Beautiful & consistent icon set with {allIconNames.length} icons for your applications.</p>

        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Use Cases</h2>
          <p className="text-fg-secondary mb-4">Real-world examples of icon usage.</p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
            {/* Button with Icon */}
            <div>
              <h3 className="font-semibold text-fg-primary mb-3">Buttons with Icons</h3>
              <div className="flex flex-wrap gap-3">
                <button
                  className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
                  <FlutterLucideIcon name={LucideIcons.plus}/>
                  <span>Add Item</span>
                </button>
                <button
                  className="flex items-center gap-2 px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors">
                  <FlutterLucideIcon name={LucideIcons.trash}/>
                  <span>Delete</span>
                </button>
                <button
                  className="flex items-center gap-2 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors">
                  <FlutterLucideIcon name={LucideIcons.check}/>
                  <span>Confirm</span>
                </button>
              </div>
            </div>

            {/* List Items */}
            <div>
              <h3 className="font-semibold text-fg-primary mb-3 mt-3">List Items</h3>
              <div className="space-y-2">
                <div className="flex items-center gap-3 p-3 bg-surface rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.circleUser} className="text-2xl text-blue-500"/>
                  <div className="flex-1">
                    <div className="font-medium">Profile Settings</div>
                    <div className="text-sm text-fg-secondary">Manage your account</div>
                  </div>
                  <FlutterLucideIcon name={LucideIcons.chevronRight} className="text-gray-400"/>
                </div>
                <div className="flex items-center gap-3 p-3 bg-surface rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.bell} className="text-2xl text-purple-500"/>
                  <div className="flex-1">
                    <div className="font-medium">Notifications</div>
                    <div className="text-sm text-fg-secondary">Manage alerts</div>
                  </div>
                  <FlutterLucideIcon name={LucideIcons.chevronRight} className="text-gray-400"/>
                </div>
                <div className="flex items-center gap-3 p-3 bg-surface rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.lock} className="text-2xl text-red-500"/>
                  <div className="flex-1">
                    <div className="font-medium">Privacy & Security</div>
                    <div className="text-sm text-fg-secondary">Control your privacy</div>
                  </div>
                  <FlutterLucideIcon name={LucideIcons.chevronRight} className="text-gray-400"/>
                </div>
              </div>
            </div>

            {/* Status Indicators */}
            <div>
              <h3 className="font-semibold text-fg-primary mb-3">Status Indicators</h3>
              <div className="space-y-2">
                <div className="flex items-center gap-2 p-3 bg-green-50 border border-green-200 rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.circleCheck} className="text-xl text-green-600"/>
                  <span className="text-green-800">Success! Your changes have been saved.</span>
                </div>
                <div className="flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.info} className="text-xl text-blue-600"/>
                  <span className="text-blue-800">Information: Please review the details below.</span>
                </div>
                <div className="flex items-center gap-2 p-3 bg-orange-50 border border-orange-200 rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.triangleAlert} className="text-xl text-orange-600"/>
                  <span className="text-orange-800">Warning: This action cannot be undone.</span>
                </div>
                <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
                  <FlutterLucideIcon name={LucideIcons.circleX} className="text-xl text-red-600"/>
                  <span className="text-red-800">Error: Something went wrong.</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Search Section */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Search Icons</h2>
          <p className="text-fg-secondary mb-4">Search through all {allIconNames.length} icons.</p>

          <div className="mb-4">
            <input
              type="text"
              placeholder="Search icons..."
              value={searchTerm}
              onChange={handleSearchChange}
              className="w-full px-4 py-2 border border-line rounded-lg bg-surface text-fg-primary focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div className="bg-surface-secondary rounded-xl border border-line overflow-hidden">
            <div className="text-sm text-fg-secondary p-4 pb-2">
              {filteredIcons.length === allIconNames.length
                ? `Showing ${displayedIcons.length} of ${allIconNames.length} icons`
                : `Found ${filteredIcons.length} icons matching "${debouncedSearchTerm}" (showing ${displayedIcons.length})`}
            </div>

            {filteredIcons.length === 0 ? (
              <div className="text-center py-8 text-fg-secondary">
                No icons found matching "{debouncedSearchTerm}"
              </div>
            ) : (
              <WebFListView
                ref={iconsListRef}
                className="h-96 px-4 pb-4"
                shrinkWrap={false}
                onLoadmore={handleLoadMore}
              >
                <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-2">
                  {displayedIcons.map((iconName) => (
                    <div
                      key={iconName}
                      className="flex flex-col items-center justify-start gap-2 p-2 rounded-lg hover:bg-surface-tertiary transition-colors cursor-pointer h-20"
                      title={iconName}
                    >
                      <div className="h-8 flex items-center justify-center">
                        <FlutterLucideIcon
                          name={LucideIcons[iconName as keyof typeof LucideIcons]}
                          className="text-2xl text-fg-primary"
                        />
                      </div>
                      <span className="text-xs text-fg-secondary text-center leading-tight break-all line-clamp-2 w-full flex items-center justify-center">
                        {iconName}
                      </span>
                    </div>
                  ))}
                </div>
                {displayCount < filteredIcons.length && (
                  <div className="text-center py-4 text-fg-secondary text-sm">
                    Scroll down to load more...
                  </div>
                )}
              </WebFListView>
            )}
          </div>
        </section>

        {/* Notes */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
          <div className="bg-orange-50 border-l-4 border-orange-500 p-4 rounded">
            <ul className="space-y-2 text-sm text-gray-700">
              <li>Icons are from the Lucide icon set (lucide.dev)</li>
              <li>Use the <code className="bg-gray-200 px-1 rounded">LucideIcons</code> enum for type-safe icon names</li>
              <li>Control size with Tailwind's text size classes (<code className="bg-gray-200 px-1 rounded">text-xl</code>, <code className="bg-gray-200 px-1 rounded">text-4xl</code>, etc.)</li>
              <li>Apply colors using Tailwind color classes or inline styles</li>
              <li>Use <code className="bg-gray-200 px-1 rounded">strokeWidth</code> prop (100-600) for weight variants</li>
              <li>Add <code className="bg-gray-200 px-1 rounded">label</code> prop for accessibility</li>
            </ul>
          </div>
        </section>
      </WebFListView>
    </div>
  );
};
