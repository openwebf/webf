import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnRadio,
  FlutterShadcnRadioItem,
} from '@openwebf/react-shadcn-ui';

export const ShadcnRadioPage: React.FC = () => {
  const [selectedPlan, setSelectedPlan] = useState('comfortable');
  const [selectedSize, setSelectedSize] = useState('medium');

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Radio Group</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Radio Group</h2>
            <div className="space-y-4">
              <label className="text-sm font-medium">Select a plan</label>
              <FlutterShadcnRadio
                value={selectedPlan}
                onChange={(e: any) => setSelectedPlan(e.detail?.value || 'comfortable')}
              >
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <FlutterShadcnRadioItem value="default" />
                    <label className="text-sm">Default</label>
                  </div>
                  <div className="flex items-center gap-3">
                    <FlutterShadcnRadioItem value="comfortable" />
                    <label className="text-sm">Comfortable</label>
                  </div>
                  <div className="flex items-center gap-3">
                    <FlutterShadcnRadioItem value="compact" />
                    <label className="text-sm">Compact</label>
                  </div>
                </div>
              </FlutterShadcnRadio>
              <p className="text-sm text-gray-500">Selected: {selectedPlan}</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Size Selection</h2>
            <FlutterShadcnRadio
              value={selectedSize}
              onChange={(e: any) => setSelectedSize(e.detail?.value || 'medium')}
            >
              <div className="flex gap-6">
                <div className="flex items-center gap-2">
                  <FlutterShadcnRadioItem value="small" />
                  <label className="text-sm">Small</label>
                </div>
                <div className="flex items-center gap-2">
                  <FlutterShadcnRadioItem value="medium" />
                  <label className="text-sm">Medium</label>
                </div>
                <div className="flex items-center gap-2">
                  <FlutterShadcnRadioItem value="large" />
                  <label className="text-sm">Large</label>
                </div>
              </div>
            </FlutterShadcnRadio>
            <p className="text-sm text-gray-500 mt-2">Selected size: {selectedSize}</p>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Descriptions</h2>
            <FlutterShadcnRadio value="startup">
              <div className="space-y-4">
                <div className="flex items-start gap-3 p-3 border rounded-lg">
                  <FlutterShadcnRadioItem value="startup" />
                  <div>
                    <label className="text-sm font-medium">Startup</label>
                    <p className="text-xs text-gray-500">Best for small teams just getting started.</p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 border rounded-lg">
                  <FlutterShadcnRadioItem value="business" />
                  <div>
                    <label className="text-sm font-medium">Business</label>
                    <p className="text-xs text-gray-500">For growing teams that need more features.</p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 border rounded-lg">
                  <FlutterShadcnRadioItem value="enterprise" />
                  <div>
                    <label className="text-sm font-medium">Enterprise</label>
                    <p className="text-xs text-gray-500">For large organizations with custom needs.</p>
                  </div>
                </div>
              </div>
            </FlutterShadcnRadio>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled State</h2>
            <FlutterShadcnRadio value="option1" disabled>
              <div className="space-y-3 opacity-50">
                <div className="flex items-center gap-3">
                  <FlutterShadcnRadioItem value="option1" />
                  <label className="text-sm">Option 1 (disabled)</label>
                </div>
                <div className="flex items-center gap-3">
                  <FlutterShadcnRadioItem value="option2" />
                  <label className="text-sm">Option 2 (disabled)</label>
                </div>
              </div>
            </FlutterShadcnRadio>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
