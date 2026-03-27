import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnSlider,
  FlutterShadcnProgress,
} from '@openwebf/react-shadcn-ui';

export const ShadcnSliderPage: React.FC = () => {
  const [volume, setVolume] = useState(50);
  const [brightness, setBrightness] = useState(75);

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Slider & Progress</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Slider</h2>
            <div className="space-y-6">
              <div>
                <div className="flex justify-between mb-2">
                  <label className="text-sm font-medium">Volume</label>
                  <span className="text-sm text-gray-500">{volume}%</span>
                </div>
                <FlutterShadcnSlider
                  value={volume.toString()}
                  min="0"
                  max="100"
                  step="1"
                  onInput={(e: any) => setVolume(parseInt(e.detail?.value || '50'))}
                />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <label className="text-sm font-medium">Brightness</label>
                  <span className="text-sm text-gray-500">{brightness}%</span>
                </div>
                <FlutterShadcnSlider
                  value={brightness.toString()}
                  min="0"
                  max="100"
                  step="5"
                  onInput={(e: any) => setBrightness(parseInt(e.detail?.value || '75'))}
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled Slider</h2>
            <FlutterShadcnSlider
              value="30"
              min="0"
              max="100"
              disabled
            />
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Progress</h2>
            <div className="space-y-6">
              <div>
                <div className="flex justify-between mb-2">
                  <label className="text-sm font-medium">Download Progress</label>
                  <span className="text-sm text-gray-500">33%</span>
                </div>
                <FlutterShadcnProgress value="33" />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <label className="text-sm font-medium">Upload Progress</label>
                  <span className="text-sm text-gray-500">66%</span>
                </div>
                <FlutterShadcnProgress value="66" />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <label className="text-sm font-medium">Complete</label>
                  <span className="text-sm text-gray-500">100%</span>
                </div>
                <FlutterShadcnProgress value="100" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Progress Examples</h2>
            <div className="space-y-4 p-4 border rounded-lg">
              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <p className="text-sm font-medium">Uploading files...</p>
                  <p className="text-xs text-gray-500">3 of 10 files uploaded</p>
                </div>
                <div className="w-32">
                  <FlutterShadcnProgress value="30" />
                </div>
              </div>
              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <p className="text-sm font-medium">Processing...</p>
                  <p className="text-xs text-gray-500">Please wait</p>
                </div>
                <div className="w-32">
                  <FlutterShadcnProgress value="60" />
                </div>
              </div>
              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <p className="text-sm font-medium">Installation complete</p>
                  <p className="text-xs text-green-500">Success!</p>
                </div>
                <div className="w-32">
                  <FlutterShadcnProgress value="100" />
                </div>
              </div>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
