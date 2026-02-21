import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnProgress,
} from '@openwebf/react-shadcn-ui';

export const ShadcnProgressPage: React.FC = () => {
  const [animatedProgress, setAnimatedProgress] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setAnimatedProgress((prev) => {
        if (prev >= 100) return 0;
        return prev + 10;
      });
    }, 500);
    return () => clearInterval(timer);
  }, []);

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Progress</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Progress</h2>
            <div className="space-y-6">
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm font-medium">0%</span>
                </div>
                <FlutterShadcnProgress value="0" />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm font-medium">25%</span>
                </div>
                <FlutterShadcnProgress value="25" />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm font-medium">50%</span>
                </div>
                <FlutterShadcnProgress value="50" />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm font-medium">75%</span>
                </div>
                <FlutterShadcnProgress value="75" />
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm font-medium">100%</span>
                </div>
                <FlutterShadcnProgress value="100" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Animated Progress</h2>
            <div>
              <div className="flex justify-between mb-2">
                <span className="text-sm font-medium">Loading...</span>
                <span className="text-sm text-gray-500">{animatedProgress}%</span>
              </div>
              <FlutterShadcnProgress value={animatedProgress.toString()} />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Progress with Labels</h2>
            <div className="space-y-6">
              <div className="p-4 border rounded-lg">
                <div className="flex justify-between items-center mb-3">
                  <div>
                    <p className="font-medium">Uploading files</p>
                    <p className="text-sm text-gray-500">3 of 10 files uploaded</p>
                  </div>
                  <span className="text-sm font-medium">30%</span>
                </div>
                <FlutterShadcnProgress value="30" />
              </div>

              <div className="p-4 border rounded-lg">
                <div className="flex justify-between items-center mb-3">
                  <div>
                    <p className="font-medium">Processing data</p>
                    <p className="text-sm text-gray-500">Analyzing 500MB</p>
                  </div>
                  <span className="text-sm font-medium">65%</span>
                </div>
                <FlutterShadcnProgress value="65" />
              </div>

              <div className="p-4 border rounded-lg bg-green-50">
                <div className="flex justify-between items-center mb-3">
                  <div>
                    <p className="font-medium text-green-800">Complete!</p>
                    <p className="text-sm text-green-600">All tasks finished</p>
                  </div>
                  <span className="text-sm font-medium text-green-800">100%</span>
                </div>
                <FlutterShadcnProgress value="100" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Indeterminate</h2>
            <div className="space-y-6">
              <div>
                <p className="text-sm text-gray-500 mb-2">Default indeterminate animation</p>
                <FlutterShadcnProgress variant="indeterminate" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Indeterminate with custom color</p>
                <FlutterShadcnProgress variant="indeterminate" color="#22c55e" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Custom Colors</h2>
            <div className="space-y-6">
              <div>
                <p className="text-sm text-gray-500 mb-2">Blue indicator</p>
                <FlutterShadcnProgress value="60" color="#3b82f6" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Green indicator</p>
                <FlutterShadcnProgress value="80" color="#22c55e" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Red indicator</p>
                <FlutterShadcnProgress value="30" color="#ef4444" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Purple indicator with custom background</p>
                <FlutterShadcnProgress value="45" color="#8b5cf6" backgroundColor="#ede9fe" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Orange indicator with dark background</p>
                <FlutterShadcnProgress value="70" color="#f97316" backgroundColor="#1c1917" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Custom Height</h2>
            <div className="space-y-6">
              <div>
                <p className="text-sm text-gray-500 mb-2">Thin (4px)</p>
                <FlutterShadcnProgress value="60" minHeight="4" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Default (16px)</p>
                <FlutterShadcnProgress value="60" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Thick (24px)</p>
                <FlutterShadcnProgress value="60" minHeight="24" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Extra thick (32px)</p>
                <FlutterShadcnProgress value="60" minHeight="32" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Custom Border Radius</h2>
            <div className="space-y-6">
              <div>
                <p className="text-sm text-gray-500 mb-2">Square corners (0)</p>
                <FlutterShadcnProgress value="50" borderRadius="0" minHeight="20" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Slightly rounded (4)</p>
                <FlutterShadcnProgress value="50" borderRadius="4" minHeight="20" />
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-2">Default rounded (16)</p>
                <FlutterShadcnProgress value="50" minHeight="20" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Combined Customization</h2>
            <div className="space-y-6">
              <div className="p-4 border rounded-lg">
                <p className="font-medium mb-1">Download Progress</p>
                <p className="text-sm text-gray-500 mb-3">2.4 GB / 4.0 GB</p>
                <FlutterShadcnProgress
                  value="60"
                  color="#3b82f6"
                  backgroundColor="#dbeafe"
                  minHeight="8"
                  borderRadius="4"
                />
              </div>
              <div className="p-4 border rounded-lg">
                <p className="font-medium mb-1">Storage Used</p>
                <p className="text-sm text-gray-500 mb-3">85% of 100 GB</p>
                <FlutterShadcnProgress
                  value="85"
                  color="#ef4444"
                  backgroundColor="#fef2f2"
                  minHeight="12"
                />
              </div>
              <div className="p-4 border rounded-lg">
                <p className="font-medium mb-1">Battery Level</p>
                <p className="text-sm text-gray-500 mb-3">72% remaining</p>
                <FlutterShadcnProgress
                  value="72"
                  color="#22c55e"
                  backgroundColor="#f0fdf4"
                  minHeight="24"
                  borderRadius="4"
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Multi-step Progress</h2>
            <div className="space-y-2">
              <div className="flex items-center gap-3">
                <span className="text-sm w-24">Step 1</span>
                <div className="flex-1">
                  <FlutterShadcnProgress value="100" />
                </div>
                <span className="text-sm text-green-600">Done</span>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-sm w-24">Step 2</span>
                <div className="flex-1">
                  <FlutterShadcnProgress value="100" />
                </div>
                <span className="text-sm text-green-600">Done</span>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-sm w-24">Step 3</span>
                <div className="flex-1">
                  <FlutterShadcnProgress value="60" />
                </div>
                <span className="text-sm text-blue-600">In Progress</span>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-sm w-24 text-gray-400">Step 4</span>
                <div className="flex-1">
                  <FlutterShadcnProgress value="0" />
                </div>
                <span className="text-sm text-gray-400">Pending</span>
              </div>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
