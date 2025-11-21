import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoSlidingSegmentedControl, FlutterCupertinoSlidingSegmentedControlItem } from '@openwebf/react-cupertino-ui';

export const CupertinoSlidingSegmentedControlPage: React.FC = () => {
  const [basicIndex, setBasicIndex] = useState(0);
  const [viewMode, setViewMode] = useState(0);
  const [filterIndex, setFilterIndex] = useState(0);
  const [sortIndex, setSortIndex] = useState(0);
  const [customColorIndex, setCustomColorIndex] = useState(0);
  const [timeRangeIndex, setTimeRangeIndex] = useState(1);
  const [eventLog, setEventLog] = useState<string[]>([]);

  const addEventLog = (message: string) => {
    setEventLog(prev => [message, ...prev].slice(0, 5));
  };

  // Sample data for demonstration
  const allItems = [
    { id: 1, name: 'Meeting Notes', status: 'active', priority: 'high' },
    { id: 2, name: 'Project Plan', status: 'completed', priority: 'medium' },
    { id: 3, name: 'Bug Report', status: 'active', priority: 'high' },
    { id: 4, name: 'Design Doc', status: 'pending', priority: 'low' },
    { id: 5, name: 'Code Review', status: 'active', priority: 'medium' },
  ];

  const filterCategories = ['All', 'Active', 'Completed', 'Pending'];
  const filteredItems = filterIndex === 0
    ? allItems
    : allItems.filter(item => item.status === filterCategories[filterIndex].toLowerCase());

  const sortOptions = ['Name', 'Priority', 'Status'];

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Sliding Segmented Control</h1>
          <p className="text-fg-secondary mb-6">iOS-style segmented control with smooth sliding thumb animation.</p>

          {/* Basic Example */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Control</h2>
            <p className="text-fg-secondary mb-4">Simple three-segment control with default styling.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex justify-center mb-6">
                  <FlutterCupertinoSlidingSegmentedControl
                    currentIndex={basicIndex}
                    onChange={(e) => setBasicIndex(e.detail)}
                    className="w-full max-w-sm"
                  >
                    <FlutterCupertinoSlidingSegmentedControlItem title="Photos" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Music" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Videos" />
                  </FlutterCupertinoSlidingSegmentedControl>
                </div>
                <div className="text-center">
                  <div className="text-sm text-gray-600 mb-2">Selected: <span className="font-semibold">{['Photos', 'Music', 'Videos'][basicIndex]}</span></div>
                  <div className="text-sm text-gray-600">Index: {basicIndex}</div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [index, setIndex] = useState(0);

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={index}
  onChange={(e) => setIndex(e.detail)}
>
  <FlutterCupertinoSlidingSegmentedControlItem title="Photos" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Music" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Videos" />
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
            </div>
          </section>

          {/* Two Segments */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Two-Segment Toggle</h2>
            <p className="text-fg-secondary mb-4">Binary choice control for switching between two options.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex justify-center mb-6">
                  <FlutterCupertinoSlidingSegmentedControl
                    currentIndex={viewMode}
                    onChange={(e) => setViewMode(e.detail)}
                    className="w-64"
                  >
                    <FlutterCupertinoSlidingSegmentedControlItem title="Compact" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Detailed" />
                  </FlutterCupertinoSlidingSegmentedControl>
                </div>

                <div className="mt-6">
                  {viewMode === 0 ? (
                    <div className="space-y-2">
                      {[1, 2, 3, 4, 5, 6].map((i) => (
                        <div key={i} className="p-2 bg-gray-100 rounded-lg flex items-center">
                          <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white text-sm font-bold mr-2">
                            {i}
                          </div>
                          <div className="text-sm">Item {i}</div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="space-y-3">
                      {[1, 2, 3, 4, 5, 6].map((i) => (
                        <div key={i} className="p-4 bg-gradient-to-r from-blue-400 to-purple-500 rounded-lg text-white">
                          <div className="flex items-center mb-2">
                            <div className="w-10 h-10 bg-white bg-opacity-30 rounded-full flex items-center justify-center font-bold mr-3">
                              {i}
                            </div>
                            <div className="font-semibold">Item {i}</div>
                          </div>
                          <div className="text-sm opacity-90">
                            Detailed description for item {i} with additional information and metadata.
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [viewMode, setViewMode] = useState(0);

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={viewMode}
  onChange={(e) => setViewMode(e.detail)}
>
  <FlutterCupertinoSlidingSegmentedControlItem title="Compact" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Detailed" />
</FlutterCupertinoSlidingSegmentedControl>

{viewMode === 0 ? <CompactView /> : <DetailedView />}`}</code></pre>
            </div>
          </section>

          {/* Four Segments */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Four-Segment Filter</h2>
            <p className="text-fg-secondary mb-4">Segmented control with four options for content filtering.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex justify-center mb-6">
                  <FlutterCupertinoSlidingSegmentedControl
                    currentIndex={filterIndex}
                    onChange={(e) => setFilterIndex(e.detail)}
                    className="w-full max-w-md"
                  >
                    <FlutterCupertinoSlidingSegmentedControlItem title="All" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Active" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Completed" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Pending" />
                  </FlutterCupertinoSlidingSegmentedControl>
                </div>

                <div className="space-y-2">
                  {filteredItems.map((item) => (
                    <div key={item.id} className="p-3 bg-gray-50 rounded-lg flex justify-between items-center">
                      <div>
                        <div className="font-semibold">{item.name}</div>
                        <div className="text-xs text-gray-600">
                          {item.status} • {item.priority} priority
                        </div>
                      </div>
                      <div className={`px-2 py-1 rounded text-xs font-semibold ${
                        item.status === 'active' ? 'bg-green-100 text-green-700' :
                        item.status === 'completed' ? 'bg-blue-100 text-blue-700' :
                        'bg-yellow-100 text-yellow-700'
                      }`}>
                        {item.status}
                      </div>
                    </div>
                  ))}
                  {filteredItems.length === 0 && (
                    <div className="text-center py-8 text-gray-500">
                      No items found
                    </div>
                  )}
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [filter, setFilter] = useState(0);
const categories = ['All', 'Active', 'Completed', 'Pending'];

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={filter}
  onChange={(e) => setFilter(e.detail)}
>
  {categories.map((cat) => (
    <FlutterCupertinoSlidingSegmentedControlItem
      key={cat}
      title={cat}
    />
  ))}
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
            </div>
          </section>

          {/* Custom Colors */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Colors & Text Styles</h2>
            <p className="text-fg-secondary mb-4">Customize background, thumb colors, and text styling to match your design.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="space-y-6">
                {/* Blue Theme */}
                <div className="bg-white rounded-lg p-6">
                  <div className="text-sm font-semibold text-gray-700 mb-3">Blue Theme - Standard Text</div>
                  <div className="flex justify-center">
                    <FlutterCupertinoSlidingSegmentedControl
                      currentIndex={customColorIndex}
                      onChange={(e) => setCustomColorIndex(e.detail)}
                      backgroundColor="#E3F2FD"
                      thumbColor="#2196F3"
                      className="w-full max-w-xs"
                      style={{ fontSize: '14px', fontWeight: '500' }}
                    >
                      <FlutterCupertinoSlidingSegmentedControlItem title="One" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Two" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Three" />
                    </FlutterCupertinoSlidingSegmentedControl>
                  </div>
                </div>

                {/* Purple Theme */}
                <div className="bg-white rounded-lg p-6">
                  <div className="text-sm font-semibold text-gray-700 mb-3">Purple Theme - Bold Text</div>
                  <div className="flex justify-center">
                    <FlutterCupertinoSlidingSegmentedControl
                      currentIndex={0}
                      onChange={() => {}}
                      backgroundColor="#F3E5F5"
                      thumbColor="#9C27B0"
                      className="w-full max-w-xs"
                      style={{ fontSize: '16px', fontWeight: '700' }}
                    >
                      <FlutterCupertinoSlidingSegmentedControlItem title="Small" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Medium" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Large" />
                    </FlutterCupertinoSlidingSegmentedControl>
                  </div>
                </div>

                {/* Green Theme */}
                <div className="bg-white rounded-lg p-6">
                  <div className="text-sm font-semibold text-gray-700 mb-3">Green Theme - Large Text</div>
                  <div className="flex justify-center">
                    <FlutterCupertinoSlidingSegmentedControl
                      currentIndex={1}
                      onChange={() => {}}
                      backgroundColor="#1B5E20"
                      thumbColor="#4CAF50"
                      className="w-full max-w-xs"
                      style={{ fontSize: '18px', fontWeight: '600', padding: '8px', color: '#FFFFFF' }}
                    >
                      <FlutterCupertinoSlidingSegmentedControlItem title="Low" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Medium" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="High" />
                    </FlutterCupertinoSlidingSegmentedControl>
                  </div>
                </div>

                {/* Dark Theme */}
                <div className="bg-gray-900 rounded-lg p-6">
                  <div className="text-sm font-semibold text-gray-300 mb-3">Dark Theme - Light Text</div>
                  <div className="flex justify-center">
                    <FlutterCupertinoSlidingSegmentedControl
                      currentIndex={2}
                      onChange={() => {}}
                      backgroundColor="#1C1C1E"
                      thumbColor="#3A3A3C"
                      className="w-full max-w-xs"
                      style={{ fontSize: '15px', fontWeight: '600', padding: '6px', color: '#FFFFFF' }}
                    >
                      <FlutterCupertinoSlidingSegmentedControlItem title="Day" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Week" />
                      <FlutterCupertinoSlidingSegmentedControlItem title="Month" />
                    </FlutterCupertinoSlidingSegmentedControl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Blue theme with standard text
<FlutterCupertinoSlidingSegmentedControl
  backgroundColor="#E3F2FD"
  thumbColor="#2196F3"
  style={{ fontSize: '14px', fontWeight: '500' }}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>

// Purple theme with bold text
<FlutterCupertinoSlidingSegmentedControl
  backgroundColor="#F3E5F5"
  thumbColor="#9C27B0"
  style={{ fontSize: '16px', fontWeight: '700' }}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>

// Green theme with white text on dark background
<FlutterCupertinoSlidingSegmentedControl
  backgroundColor="#1B5E20"
  thumbColor="#4CAF50"
  style={{ fontSize: '18px', fontWeight: '600', padding: '8px', color: '#FFFFFF' }}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>

// Dark theme with light text
<FlutterCupertinoSlidingSegmentedControl
  backgroundColor="#1C1C1E"
  thumbColor="#3A3A3C"
  style={{ fontSize: '15px', fontWeight: '600', padding: '6px', color: '#FFFFFF' }}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
            </div>
          </section>

          {/* Practical Example - Time Range */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Time Range Selector</h2>
            <p className="text-fg-secondary mb-4">Practical example for selecting time ranges in analytics dashboards.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex justify-center mb-6">
                  <FlutterCupertinoSlidingSegmentedControl
                    currentIndex={timeRangeIndex}
                    onChange={(e) => setTimeRangeIndex(e.detail)}
                    className="w-full max-w-lg"
                  >
                    <FlutterCupertinoSlidingSegmentedControlItem title="Today" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="This Week" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="This Month" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="This Year" />
                  </FlutterCupertinoSlidingSegmentedControl>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div className="p-4 bg-blue-50 rounded-lg">
                    <div className="text-2xl font-bold text-blue-600">
                      {[234, 1567, 8942, 45231][timeRangeIndex]}
                    </div>
                    <div className="text-sm text-gray-600">Page Views</div>
                  </div>
                  <div className="p-4 bg-green-50 rounded-lg">
                    <div className="text-2xl font-bold text-green-600">
                      {[89, 523, 3214, 18567][timeRangeIndex]}
                    </div>
                    <div className="text-sm text-gray-600">Visitors</div>
                  </div>
                  <div className="p-4 bg-purple-50 rounded-lg">
                    <div className="text-2xl font-bold text-purple-600">
                      {[12, 78, 234, 1456][timeRangeIndex]}
                    </div>
                    <div className="text-sm text-gray-600">Conversions</div>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [timeRange, setTimeRange] = useState(1);

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={timeRange}
  onChange={(e) => setTimeRange(e.detail)}
>
  <FlutterCupertinoSlidingSegmentedControlItem title="Today" />
  <FlutterCupertinoSlidingSegmentedControlItem title="This Week" />
  <FlutterCupertinoSlidingSegmentedControlItem title="This Month" />
  <FlutterCupertinoSlidingSegmentedControlItem title="This Year" />
</FlutterCupertinoSlidingSegmentedControl>

{/* Display data based on selected time range */}
<Stats timeRange={timeRange} />`}</code></pre>
            </div>
          </section>

          {/* Sorting Example */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Sorting Control</h2>
            <p className="text-fg-secondary mb-4">Use segmented control for sorting options.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex items-center justify-between mb-4">
                  <span className="text-sm font-semibold text-gray-700">Sort by:</span>
                  <FlutterCupertinoSlidingSegmentedControl
                    currentIndex={sortIndex}
                    onChange={(e) => setSortIndex(e.detail)}
                    className="w-64"
                  >
                    <FlutterCupertinoSlidingSegmentedControlItem title="Name" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Priority" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Status" />
                  </FlutterCupertinoSlidingSegmentedControl>
                </div>

                <div className="space-y-2">
                  {[...allItems]
                    .sort((a, b) => {
                      if (sortIndex === 0) return a.name.localeCompare(b.name);
                      if (sortIndex === 1) return a.priority.localeCompare(b.priority);
                      return a.status.localeCompare(b.status);
                    })
                    .map((item) => (
                      <div key={item.id} className="p-3 bg-gray-50 rounded-lg">
                        <div className="font-semibold">{item.name}</div>
                        <div className="text-xs text-gray-600 mt-1">
                          Priority: {item.priority} • Status: {item.status}
                        </div>
                      </div>
                    ))}
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [sortBy, setSortBy] = useState(0);

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={sortBy}
  onChange={(e) => setSortBy(e.detail)}
>
  <FlutterCupertinoSlidingSegmentedControlItem title="Name" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Date" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Size" />
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
            </div>
          </section>

          {/* Event Handling */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Event Handling</h2>
            <p className="text-fg-secondary mb-4">Responding to selection changes with the onChange event.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="flex justify-center mb-6">
                  <FlutterCupertinoSlidingSegmentedControl
                    currentIndex={basicIndex}
                    onChange={(e) => {
                      setBasicIndex(e.detail);
                      addEventLog(`Selected index: ${e.detail} (${['First', 'Second', 'Third'][e.detail]})`);
                    }}
                    className="w-full max-w-sm"
                  >
                    <FlutterCupertinoSlidingSegmentedControlItem title="First" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Second" />
                    <FlutterCupertinoSlidingSegmentedControlItem title="Third" />
                  </FlutterCupertinoSlidingSegmentedControl>
                </div>

                {eventLog.length > 0 && (
                  <div className="p-3 bg-gray-50 rounded-lg">
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
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoSlidingSegmentedControl
  currentIndex={index}
  onChange={(e) => {
    const selectedIndex = e.detail;
    console.log('Selected:', selectedIndex);

    // Update state
    setIndex(selectedIndex);

    // Perform actions based on selection
    handleSelectionChange(selectedIndex);
  }}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
            </div>
          </section>

          {/* API Reference */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">API Reference</h2>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-6">
              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoSlidingSegmentedControl Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">currentIndex</code> — Zero-based index of selected segment (number, default: 0)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">backgroundColor</code> — Track background color (string, hex format #RRGGBB or #AARRGGBB)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">thumbColor</code> — Sliding thumb color (string, hex format #RRGGBB or #AARRGGBB)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Fired when selection changes (event: CustomEvent{'<number>'})</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">className</code> — CSS class for styling the wrapper</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">style</code> — Inline styles for the wrapper</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">FlutterCupertinoSlidingSegmentedControlItem Props</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">title</code> — Label text shown for this segment (string)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">e.detail</code> — Number representing the zero-based index of the selected segment</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Segment Count:</strong> Keep segments between 2-5 for optimal usability and readability</li>
                <li><strong>Label Length:</strong> Use short, concise labels (1-2 words) that fit comfortably in segments</li>
                <li><strong>Consistent Width:</strong> Design for equal-width segments by keeping label lengths similar</li>
                <li><strong>Clear Purpose:</strong> Use for mutually exclusive options, not for navigation or actions</li>
                <li><strong>State Management:</strong> Always use controlled components with currentIndex for predictable behavior</li>
                <li><strong>Visual Feedback:</strong> Update UI immediately when selection changes to provide instant feedback</li>
                <li><strong>Color Contrast:</strong> Ensure sufficient contrast between background and thumb colors</li>
                <li><strong>Context:</strong> Provide context about what the control affects (e.g., "View:" or "Sort by:")</li>
                <li><strong>Responsive Design:</strong> Set appropriate width constraints to prevent segments from becoming too narrow</li>
                <li><strong>Default Selection:</strong> Always have a default selected segment to avoid ambiguity</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Control Only</h4>
                <p className="text-sm text-fg-secondary">
                  This component only renders the segmented control itself. It does not manage or display tab content. Use the selected index to control your own content views.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Index Clamping</h4>
                <p className="text-sm text-fg-secondary">
                  When currentIndex is outside the valid range [0, items.length - 1], it is automatically clamped to the nearest valid value. This prevents errors but may cause unexpected behavior.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Empty State</h4>
                <p className="text-sm text-fg-secondary">
                  If no items are provided, the control renders in an inert state with no selection. Always provide at least two segments for meaningful interaction.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Color Format</h4>
                <p className="text-sm text-fg-secondary">
                  Colors must be in hex format: #RRGGBB for opaque colors or #AARRGGBB for colors with alpha transparency. Other color formats are not supported.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Smooth Animation</h4>
                <p className="text-sm text-fg-secondary">
                  The control features iOS-style sliding animation when switching segments. This animation is built-in and automatic, matching native iOS behavior.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Layout Neutral</h4>
                <p className="text-sm text-fg-secondary">
                  The control is layout-neutral. Use className or style props to control width, margin, and positioning within your layout.
                </p>
              </div>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">View Mode Switcher</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [viewMode, setViewMode] = useState(0);

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={viewMode}
  onChange={(e) => setViewMode(e.detail)}
>
  <FlutterCupertinoSlidingSegmentedControlItem title="Compact" />
  <FlutterCupertinoSlidingSegmentedControlItem title="Detailed" />
</FlutterCupertinoSlidingSegmentedControl>

{viewMode === 0 ? <CompactView /> : <DetailedView />}`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Filter Control</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [filter, setFilter] = useState(0);
const filters = ['All', 'Active', 'Completed'];

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={filter}
  onChange={(e) => setFilter(e.detail)}
>
  {filters.map((f) => (
    <FlutterCupertinoSlidingSegmentedControlItem
      key={f}
      title={f}
    />
  ))}
</FlutterCupertinoSlidingSegmentedControl>

<ItemList filter={filters[filter]} />`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">With Labels</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div className="flex items-center gap-4">
  <label className="text-sm font-semibold">
    Sort by:
  </label>
  <FlutterCupertinoSlidingSegmentedControl
    currentIndex={sortBy}
    onChange={(e) => setSortBy(e.detail)}
  >
    <FlutterCupertinoSlidingSegmentedControlItem title="Name" />
    <FlutterCupertinoSlidingSegmentedControlItem title="Date" />
    <FlutterCupertinoSlidingSegmentedControlItem title="Size" />
  </FlutterCupertinoSlidingSegmentedControl>
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Themed Control</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`// Match your app's theme
const theme = {
  light: {
    bg: '#F2F2F2',
    thumb: '#FFFFFF'
  },
  dark: {
    bg: '#2C2C2E',
    thumb: '#636366'
  }
};

<FlutterCupertinoSlidingSegmentedControl
  backgroundColor={isDark ? theme.dark.bg : theme.light.bg}
  thumbColor={isDark ? theme.dark.thumb : theme.light.thumb}
  currentIndex={selected}
  onChange={(e) => setSelected(e.detail)}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Persistent Selection</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`// Save selection to localStorage
const [segment, setSegment] = useState(() => {
  const saved = localStorage.getItem('selectedSegment');
  return saved ? parseInt(saved) : 0;
});

const handleChange = (e) => {
  const index = e.detail;
  setSegment(index);
  localStorage.setItem('selectedSegment', index.toString());
};

<FlutterCupertinoSlidingSegmentedControl
  currentIndex={segment}
  onChange={handleChange}
>
  {/* items... */}
</FlutterCupertinoSlidingSegmentedControl>`}</code></pre>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};

