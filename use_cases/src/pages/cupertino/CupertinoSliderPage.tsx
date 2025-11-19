import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoSlider, FlutterCupertinoIcon, CupertinoIcons } from '@openwebf/react-cupertino-ui';

export const CupertinoSliderPage: React.FC = () => {
  const [basicValue, setBasicValue] = useState(50);
  const [volumeValue, setVolumeValue] = useState(75);
  const [brightnessValue, setBrightnessValue] = useState(60);
  const [temperatureValue, setTemperatureValue] = useState(22);
  const [steppedValue, setSteppedValue] = useState(50);
  const [customRangeValue, setCustomRangeValue] = useState(5);
  const [redValue, setRedValue] = useState(255);
  const [greenValue, setGreenValue] = useState(128);
  const [blueValue, setBlueValue] = useState(64);
  const [eventLog, setEventLog] = useState<string[]>([]);

  const addEventLog = (message: string) => {
    setEventLog(prev => [message, ...prev].slice(0, 5));
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Slider</h1>
          <p className="text-fg-secondary mb-6">iOS-style continuous or stepped slider for value selection.</p>

          {/* Basic Slider */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Basic Slider</h2>
            <p className="text-fg-secondary mb-4">Simple continuous slider with default range (0-100).</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-semibold">Value</span>
                    <span className="text-2xl font-bold text-blue-600">{basicValue.toFixed(0)}</span>
                  </div>
                  <FlutterCupertinoSlider
                    val={basicValue}
                    min={0}
                    max={100}
                    onChange={(e) => setBasicValue(e.detail)}
                    style={{ width: '100%' }}
                  />
                </div>
                <div className="text-sm text-gray-600 text-center">
                  Drag the slider to change the value
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [value, setValue] = useState(50);

<FlutterCupertinoSlider
  val={value}
  min={0}
  max={100}
  onChange={(e) => setValue(e.detail)}
  style={{ width: '100%' }}
/>`}</code></pre>
            </div>
          </section>

          {/* Stepped Slider */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Stepped Slider</h2>
            <p className="text-fg-secondary mb-4">Slider with discrete divisions for precise value selection.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-semibold">Steps (10 divisions)</span>
                    <span className="text-2xl font-bold text-blue-600">{steppedValue.toFixed(0)}</span>
                  </div>
                  <FlutterCupertinoSlider
                    val={steppedValue}
                    min={0}
                    max={100}
                    step={10}
                    onChange={(e) => setSteppedValue(e.detail)}
                    style={{ width: '100%' }}
                  />
                  <div className="flex justify-between text-xs text-gray-500 mt-2">
                    <span>0</span>
                    <span>10</span>
                    <span>20</span>
                    <span>30</span>
                    <span>40</span>
                    <span>50</span>
                    <span>60</span>
                    <span>70</span>
                    <span>80</span>
                    <span>90</span>
                    <span>100</span>
                  </div>
                </div>
                <div className="text-sm text-gray-600 text-center">
                  Slider snaps to discrete values
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoSlider
  val={value}
  min={0}
  max={100}
  step={10}  // 10 discrete divisions
  onChange={(e) => setValue(e.detail)}
  style={{ width: '100%' }}
/>`}</code></pre>
            </div>
          </section>

          {/* Custom Range */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Custom Range</h2>
            <p className="text-fg-secondary mb-4">Sliders can use any min/max range.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-semibold">Rating (1-10)</span>
                    <span className="text-2xl font-bold text-blue-600">{customRangeValue.toFixed(1)}</span>
                  </div>
                  <FlutterCupertinoSlider
                    val={customRangeValue}
                    min={1}
                    max={10}
                    onChange={(e) => setCustomRangeValue(e.detail)}
                    style={{ width: '100%' }}
                  />
                  <div className="flex justify-between text-xs text-gray-500 mt-2">
                    <span>1 (Poor)</span>
                    <span>5.5 (Average)</span>
                    <span>10 (Excellent)</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoSlider
  val={rating}
  min={1}
  max={10}
  onChange={(e) => setRating(e.detail)}
  style={{ width: '100%' }}
/>`}</code></pre>
            </div>
          </section>

          {/* Practical Examples */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Practical Examples</h2>
            <p className="text-fg-secondary mb-4">Common use cases for sliders in iOS-style interfaces.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg overflow-hidden divide-y divide-gray-200">
                {/* Volume Control */}
                <div className="p-4">
                  <div className="flex items-center gap-3 mb-3">
                    <span className="text-2xl">
                      <FlutterCupertinoIcon type={CupertinoIcons.speaker_3_fill} />
                    </span>
                    <div className="flex-1">
                      <div className="flex justify-between items-center mb-1">
                        <span className="font-semibold">Volume</span>
                        <span className="text-sm text-gray-600">{volumeValue.toFixed(0)}%</span>
                      </div>
                      <FlutterCupertinoSlider
                        val={volumeValue}
                        min={0}
                        max={100}
                        onChange={(e) => setVolumeValue(e.detail)}
                        style={{ width: '100%' }}
                      />
                    </div>
                  </div>
                </div>

                {/* Brightness Control */}
                <div className="p-4">
                  <div className="flex items-center gap-3 mb-3">
                    <span className="text-2xl">
                      <FlutterCupertinoIcon type={CupertinoIcons.sun_max_fill} />
                    </span>
                    <div className="flex-1">
                      <div className="flex justify-between items-center mb-1">
                        <span className="font-semibold">Brightness</span>
                        <span className="text-sm text-gray-600">{brightnessValue.toFixed(0)}%</span>
                      </div>
                      <FlutterCupertinoSlider
                        val={brightnessValue}
                        min={0}
                        max={100}
                        onChange={(e) => setBrightnessValue(e.detail)}
                        style={{ width: '100%' }}
                      />
                    </div>
                  </div>
                </div>

                {/* Temperature Control */}
                <div className="p-4">
                  <div className="flex items-center gap-3 mb-3">
                    <span className="text-2xl">
                      <FlutterCupertinoIcon type={CupertinoIcons.thermometer} />
                    </span>
                    <div className="flex-1">
                      <div className="flex justify-between items-center mb-1">
                        <span className="font-semibold">Temperature</span>
                        <span className="text-sm text-gray-600">{temperatureValue.toFixed(1)}°C</span>
                      </div>
                      <FlutterCupertinoSlider
                        val={temperatureValue}
                        min={16}
                        max={30}
                        onChange={(e) => setTemperatureValue(e.detail)}
                        style={{ width: '100%' }}
                      />
                      <div className="flex justify-between text-xs text-gray-500 mt-1">
                        <span>16°C</span>
                        <span>30°C</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`// Volume slider (0-100)
<FlutterCupertinoSlider
  val={volume}
  min={0}
  max={100}
  onChange={(e) => setVolume(e.detail)}
  style={{ width: '100%' }}
/>

// Temperature slider (16-30°C)
<FlutterCupertinoSlider
  val={temperature}
  min={16}
  max={30}
  onChange={(e) => setTemperature(e.detail)}
  style={{ width: '100%' }}
/>`}</code></pre>
            </div>
          </section>

          {/* Color Picker Example */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Color Picker Example</h2>
            <p className="text-fg-secondary mb-4">Using multiple sliders to create an RGB color picker.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div
                  className="w-full h-32 rounded-lg mb-6 border-2 border-gray-200"
                  style={{ backgroundColor: `rgb(${redValue}, ${greenValue}, ${blueValue})` }}
                >
                  <div className="h-full flex items-center justify-center">
                    <span className="font-mono text-sm bg-white bg-opacity-90 px-3 py-1 rounded">
                      rgb({redValue.toFixed(0)}, {greenValue.toFixed(0)}, {blueValue.toFixed(0)})
                    </span>
                  </div>
                </div>

                <div className="space-y-4">
                  <div>
                    <div className="flex justify-between items-center mb-1">
                      <span className="font-semibold text-red-600">Red</span>
                      <span className="text-sm text-gray-600">{redValue.toFixed(0)}</span>
                    </div>
                    <FlutterCupertinoSlider
                      val={redValue}
                      min={0}
                      max={255}
                      onChange={(e) => setRedValue(e.detail)}
                      style={{ width: '100%' }}
                    />
                  </div>

                  <div>
                    <div className="flex justify-between items-center mb-1">
                      <span className="font-semibold text-green-600">Green</span>
                      <span className="text-sm text-gray-600">{greenValue.toFixed(0)}</span>
                    </div>
                    <FlutterCupertinoSlider
                      val={greenValue}
                      min={0}
                      max={255}
                      onChange={(e) => setGreenValue(e.detail)}
                      style={{ width: '100%' }}
                    />
                  </div>

                  <div>
                    <div className="flex justify-between items-center mb-1">
                      <span className="font-semibold text-blue-600">Blue</span>
                      <span className="text-sm text-gray-600">{blueValue.toFixed(0)}</span>
                    </div>
                    <FlutterCupertinoSlider
                      val={blueValue}
                      min={0}
                      max={255}
                      onChange={(e) => setBlueValue(e.detail)}
                      style={{ width: '100%' }}
                    />
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`const [red, setRed] = useState(255);
const [green, setGreen] = useState(128);
const [blue, setBlue] = useState(64);

<div style={{
  backgroundColor: \`rgb(\${red}, \${green}, \${blue})\`
}}>
  <FlutterCupertinoSlider
    val={red}
    min={0}
    max={255}
    onChange={(e) => setRed(e.detail)}
    style={{ width: '100%' }}
  />
  <FlutterCupertinoSlider
    val={green}
    min={0}
    max={255}
    onChange={(e) => setGreen(e.detail)}
    style={{ width: '100%' }}
  />
  <FlutterCupertinoSlider
    val={blue}
    min={0}
    max={255}
    onChange={(e) => setBlue(e.detail)}
    style={{ width: '100%' }}
  />
</div>`}</code></pre>
            </div>
          </section>

          {/* Events Demo */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Event Handling</h2>
            <p className="text-fg-secondary mb-4">Sliders fire three types of events: change, changestart, and changeend.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="bg-white rounded-lg p-6">
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-semibold">Interactive Slider</span>
                    <span className="text-xl font-bold text-blue-600">{basicValue.toFixed(1)}</span>
                  </div>
                  <FlutterCupertinoSlider
                    val={basicValue}
                    min={0}
                    max={100}
                    onChange={(e) => {
                      setBasicValue(e.detail);
                      addEventLog(`change: ${e.detail.toFixed(1)}`);
                    }}
                    onChangestart={(e) => {
                      addEventLog(`changestart: ${e.detail.toFixed(1)}`);
                    }}
                    onChangeend={(e) => {
                      addEventLog(`changeend: ${e.detail.toFixed(1)}`);
                    }}
                    style={{ width: '100%' }}
                  />
                </div>

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
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoSlider
  val={value}
  onChange={(e) => {
    // Fired continuously while dragging
    console.log('change:', e.detail);
  }}
  onChangestart={(e) => {
    // Fired when user starts dragging
    console.log('start:', e.detail);
  }}
  onChangeend={(e) => {
    // Fired when user releases thumb
    console.log('end:', e.detail);
  }}
  style={{ width: '100%' }}
/>`}</code></pre>
            </div>
          </section>

          {/* Disabled State */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
            <p className="text-fg-secondary mb-4">Sliders can be disabled to prevent user interaction.</p>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
              <div className="space-y-4">
                <div className="bg-white rounded-lg p-4">
                  <div className="mb-2">
                    <span className="font-semibold text-gray-400">Disabled (Low Value)</span>
                    <div className="text-sm text-gray-500">Cannot be adjusted</div>
                  </div>
                  <FlutterCupertinoSlider
                    val={25}
                    min={0}
                    max={100}
                    disabled={true}
                    style={{ width: '100%' }}
                  />
                </div>

                <div className="bg-white rounded-lg p-4">
                  <div className="mb-2">
                    <span className="font-semibold text-gray-400">Disabled (Mid Value)</span>
                    <div className="text-sm text-gray-500">Cannot be adjusted</div>
                  </div>
                  <FlutterCupertinoSlider
                    val={50}
                    min={0}
                    max={100}
                    disabled={true}
                    style={{ width: '100%' }}
                  />
                </div>

                <div className="bg-white rounded-lg p-4">
                  <div className="mb-2">
                    <span className="font-semibold text-gray-400">Disabled (High Value)</span>
                    <div className="text-sm text-gray-500">Cannot be adjusted</div>
                  </div>
                  <FlutterCupertinoSlider
                    val={75}
                    min={0}
                    max={100}
                    disabled={true}
                    style={{ width: '100%' }}
                  />
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto"><code>{`<FlutterCupertinoSlider
  val={50}
  disabled={true}
  onChange={(e) => {
    // This will not fire when disabled
    console.log(e.detail);
  }}
  style={{ width: '100%' }}
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
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">val</code> — Current value of the slider (number, default: 0.0)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">min</code> — Minimum value of the range (number, default: 0.0)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">max</code> — Maximum value of the range (number, default: 100.0)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">step</code> — Number of discrete divisions (integer, optional, omit for continuous)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">disabled</code> — Prevents user interaction (boolean, default: false)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Events</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChange</code> — Fired continuously while dragging (event: CustomEvent{'<number>'})</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChangestart</code> — Fired when user starts dragging (event: CustomEvent{'<number>'})</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">onChangeend</code> — Fired when user releases thumb (event: CustomEvent{'<number>'})</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Methods</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">getValue()</code> — Returns the current value (number)</li>
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">setValue(val)</code> — Sets the value programmatically (clamped to min/max)</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-fg-primary mb-3">Event Detail</h3>
                <ul className="space-y-2 text-sm text-fg-secondary">
                  <li><code className="bg-gray-100 px-2 py-0.5 rounded">e.detail</code> — Number value representing the current slider position</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Best Practices */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Best Practices</h2>
            <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <ul className="space-y-2 text-sm text-gray-700">
                <li><strong>Value Display:</strong> Always show the current value near the slider for clarity</li>
                <li><strong>Range Labels:</strong> Display min/max labels to indicate the available range</li>
                <li><strong>Use Steps Wisely:</strong> Use stepped sliders when precise values matter (e.g., ratings 1-5)</li>
                <li><strong>Appropriate Range:</strong> Choose min/max values that make sense for the use case</li>
                <li><strong>Visual Context:</strong> Add icons or labels to indicate what the slider controls</li>
                <li><strong>Feedback:</strong> Provide immediate visual feedback when the value changes</li>
                <li><strong>Touch Target:</strong> Ensure adequate spacing around sliders for easy interaction</li>
                <li><strong>Performance:</strong> Use onChangeend for expensive operations instead of onChange</li>
                <li><strong>Disabled State:</strong> Use disabled state when values should not be changed</li>
                <li><strong>Decimal Precision:</strong> Format displayed values appropriately (e.g., toFixed(0) for integers)</li>
              </ul>
            </div>
          </section>

          {/* Usage Notes */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Usage Notes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Value Clamping</h4>
                <p className="text-sm text-fg-secondary">
                  The slider automatically clamps values to stay within [min, max]. Setting a value outside this range will adjust it to the nearest boundary.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Continuous vs Stepped</h4>
                <p className="text-sm text-fg-secondary">
                  When step is omitted or null, the slider is continuous. When step is provided, the slider divides the range into that many discrete divisions.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Event Timing</h4>
                <p className="text-sm text-fg-secondary">
                  onChange fires continuously during drag. Use onChangestart/onChangeend to detect when interaction begins/ends. For expensive operations like API calls, prefer onChangeend.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Disabled Interaction</h4>
                <p className="text-sm text-fg-secondary">
                  When disabled is true, the slider becomes non-interactive and appears dimmed. No events will fire in this state.
                </p>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Native Styling</h4>
                <p className="text-sm text-fg-secondary">
                  The slider uses native iOS Cupertino styling. Colors and animations are handled by Flutter to match iOS design guidelines.
                </p>
              </div>
            </div>
          </section>

          {/* Common Patterns */}
          <section className="mb-8">
            <h2 className="text-xl font-semibold text-fg-primary mb-3">Common Patterns</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Settings Row with Icon</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`<div className="flex items-center gap-3">
  <span className="text-2xl">
    <FlutterCupertinoIcon type={CupertinoIcons.speaker_3_fill} />
  </span>
  <div className="flex-1">
    <div className="flex justify-between mb-1">
      <span className="font-semibold">Volume</span>
      <span className="text-sm">{volume}%</span>
    </div>
    <FlutterCupertinoSlider
      val={volume}
      min={0}
      max={100}
      onChange={(e) => setVolume(e.detail)}
      style={{ width: '100%' }}
    />
  </div>
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Debounced API Call</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [value, setValue] = useState(50);

// Use onChangeend for API calls, not onChange
<FlutterCupertinoSlider
  val={value}
  onChange={(e) => setValue(e.detail)}
  onChangeend={(e) => {
    // Only call API when user finishes dragging
    saveSettingToAPI(e.detail);
  }}
  style={{ width: '100%' }}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Conditional Min/Max</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [min, setMin] = useState(0);
const [max, setMax] = useState(100);
const [value, setValue] = useState(50);

// Adjust value when range changes
useEffect(() => {
  setValue(v => Math.min(Math.max(v, min), max));
}, [min, max]);

<FlutterCupertinoSlider
  val={value}
  min={min}
  max={max}
  onChange={(e) => setValue(e.detail)}
  style={{ width: '100%' }}
/>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Percentage Display</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const [value, setValue] = useState(75);
const percentage = ((value - min) / (max - min) * 100).toFixed(0);

<div>
  <div>Progress: {percentage}%</div>
  <FlutterCupertinoSlider
    val={value}
    min={min}
    max={max}
    onChange={(e) => setValue(e.detail)}
    style={{ width: '100%' }}
  />
</div>`}</code></pre>
              </div>

              <div>
                <h4 className="font-semibold text-fg-primary mb-2 text-sm">Imperative Control</h4>
                <pre className="text-xs overflow-x-auto bg-gray-50 p-3 rounded"><code>{`const sliderRef = useRef(null);

const resetToDefault = () => {
  sliderRef.current?.setValue(50);
};

<FlutterCupertinoSlider
  ref={sliderRef}
  val={value}
  onChange={(e) => setValue(e.detail)}
  style={{ width: '100%' }}
/>
<button onClick={resetToDefault}>Reset</button>`}</code></pre>
              </div>
            </div>
          </section>
      </WebFListView>
    </div>
  );
};
