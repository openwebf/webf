import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';

const CupertinoButtonsPage: React.FC = () => {
  const [counter, setCounter] = React.useState(0);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Buttons</h1>
          <p className="text-fg-secondary mb-6">iOS-style buttons with haptic feedback</p>

          {/* Button Variants */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Button Variants</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <p className="text-sm text-fg-secondary mb-2">Plain Button (default)</p>
                <FlutterCupertinoButton
                  variant="plain"
                  onClick={() => console.log('Plain button clicked')}
                >
                  Plain Button
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Tinted Button</p>
                <FlutterCupertinoButton
                  variant="tinted"
                  onClick={() => console.log('Tinted button clicked')}
                >
                  Tinted Button
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Filled Button</p>
                <FlutterCupertinoButton
                  variant="filled"
                  onClick={() => {
                    setCounter(counter + 1);
                    console.log('Filled button clicked');
                  }}
                >
                  Filled Button ({counter})
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Button Sizes */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Button Sizes</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <p className="text-sm text-fg-secondary mb-2">Small Size</p>
                <FlutterCupertinoButton
                  variant="filled"
                  size="small"
                  onClick={() => console.log('Small button')}
                >
                  Small Button
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Default Size</p>
                <FlutterCupertinoButton
                  variant="filled"
                  onClick={() => console.log('Default button')}
                >
                  Default Button
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Large Size</p>
                <FlutterCupertinoButton
                  variant="filled"
                  size="large"
                  onClick={() => console.log('Large button')}
                >
                  Large Button
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Disabled State */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Disabled State</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <p className="text-sm text-fg-secondary mb-2">Disabled Plain Button</p>
                <FlutterCupertinoButton
                  variant="plain"
                  disabled
                >
                  Disabled Plain
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Disabled Tinted Button</p>
                <FlutterCupertinoButton
                  variant="tinted"
                  disabled
                >
                  Disabled Tinted
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Disabled Filled Button</p>
                <FlutterCupertinoButton
                  variant="filled"
                  disabled
                >
                  Disabled Filled
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Disabled with Custom Color</p>
                <FlutterCupertinoButton
                  variant="filled"
                  disabled
                  disabledColor="#B0B0B0"
                >
                  Custom Disabled Color
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Pressed Opacity */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Pressed Opacity</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <p className="text-sm text-fg-secondary mb-2">Default Pressed Opacity (0.4)</p>
                <FlutterCupertinoButton
                  variant="filled"
                  onClick={() => console.log('Default opacity')}
                >
                  Default Press
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Softer Press (0.2)</p>
                <FlutterCupertinoButton
                  variant="filled"
                  pressedOpacity="0.2"
                  onClick={() => console.log('Soft press')}
                >
                  Softer Press
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Harder Press (0.6)</p>
                <FlutterCupertinoButton
                  variant="filled"
                  pressedOpacity="0.6"
                  onClick={() => console.log('Hard press')}
                >
                  Harder Press
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Custom Styling */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Custom Styling</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <p className="text-sm text-fg-secondary mb-2">Custom Padding & Border Radius</p>
                <FlutterCupertinoButton
                  variant="tinted"
                  className="px-4 py-2 rounded-xl"
                  style={{ minHeight: 44, textAlign: 'center' }}
                  onClick={() => console.log('Custom styling')}
                >
                  Continue
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Fixed Width Button</p>
                <FlutterCupertinoButton
                  variant="tinted"
                  className="w-52 rounded-lg"
                  onClick={() => console.log('Fixed width')}
                >
                  Fixed Width
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Custom Background (Tinted with CSS)</p>
                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#34C759', color: 'white' }}
                  onClick={() => console.log('Custom background')}
                >
                  Success Green
                </FlutterCupertinoButton>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-2">Custom Background (Plain with CSS)</p>
                <FlutterCupertinoButton
                  variant="plain"
                  className="rounded-lg px-4 py-2"
                  style={{ backgroundColor: '#FF3B30', color: 'white' }}
                  onClick={() => console.log('Custom danger')}
                >
                  Danger Red
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Color Variants (using tinted variant + CSS) */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Color Variants</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <p className="text-sm text-fg-secondary mb-4">Using tinted variant with custom CSS colors</p>
              <div className="flex flex-wrap gap-3">
                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#007AFF', color: 'white' }}
                  onClick={() => console.log('Primary')}
                >
                  Primary
                </FlutterCupertinoButton>

                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#34C759', color: 'white' }}
                  onClick={() => console.log('Success')}
                >
                  Success
                </FlutterCupertinoButton>

                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#FF9500', color: 'white' }}
                  onClick={() => console.log('Warning')}
                >
                  Warning
                </FlutterCupertinoButton>

                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#FF3B30', color: 'white' }}
                  onClick={() => console.log('Danger')}
                >
                  Danger
                </FlutterCupertinoButton>

                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#8E8E93', color: 'white' }}
                  onClick={() => console.log('Secondary')}
                >
                  Secondary
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Interactive Example */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Interactive Example</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <p className="text-fg-secondary mb-4">Counter: <span className="font-bold text-2xl text-fg-primary">{counter}</span></p>
              <div className="flex flex-wrap gap-3">
                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#34C759', color: 'white' }}
                  onClick={() => setCounter(counter + 1)}
                >
                  Increment
                </FlutterCupertinoButton>

                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#FF3B30', color: 'white' }}
                  onClick={() => setCounter(counter - 1)}
                >
                  Decrement
                </FlutterCupertinoButton>

                <FlutterCupertinoButton
                  variant="tinted"
                  className="rounded-lg"
                  style={{ backgroundColor: '#8E8E93', color: 'white' }}
                  onClick={() => setCounter(0)}
                >
                  Reset
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
export default CupertinoButtonsPage
