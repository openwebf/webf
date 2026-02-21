import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnRadioGroup,
  FlutterShadcnRadioGroupItem,
} from '@openwebf/react-shadcn-ui';

const resolveRadioValue = (event: any): string | null => {
  const detail = event?.detail;

  if (typeof detail === 'string' && detail) {
    return detail;
  }

  if (detail && typeof detail === 'object' && typeof detail.value === 'string' && detail.value) {
    return detail.value;
  }

  const targetValue = event?.target?.value;
  if (typeof targetValue === 'string' && targetValue) {
    return targetValue;
  }

  return null;
};

export const ShadcnRadioPage: React.FC = () => {
  const [selectedPlan, setSelectedPlan] = useState('comfortable');
  const [selectedSize, setSelectedSize] = useState('medium');

  const selectPlan = (value: string) => {
    console.log('selectPlan', value);
    setSelectedPlan(value);
  };

  const selectSize = (value: string) => {
    console.log('selectSize', value);
    setSelectedSize(value);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Radio Group</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Radio Group</h2>
            <div className="space-y-4">
              <label className="text-sm font-medium">Select a plan</label>
              <FlutterShadcnRadioGroup
                value={selectedPlan}
                onChange={(event: any) => {
                  console.log('plan group change', event?.detail);
                  const nextValue = resolveRadioValue(event);
                  if (nextValue) {
                    selectPlan(nextValue);
                  }
                }}
              >
                <FlutterShadcnRadioGroupItem value="default">Default</FlutterShadcnRadioGroupItem>
                <FlutterShadcnRadioGroupItem value="comfortable">Comfortable</FlutterShadcnRadioGroupItem>
                <FlutterShadcnRadioGroupItem value="compact">Compact</FlutterShadcnRadioGroupItem>
              </FlutterShadcnRadioGroup>
              <p className="text-sm text-gray-500">Selected: {selectedPlan}</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Size Selection</h2>
            <FlutterShadcnRadioGroup
              value={selectedSize}
              onChange={(event: any) => {
                console.log('size group change', event?.detail);
                const nextValue = resolveRadioValue(event);
                if (nextValue) {
                  selectSize(nextValue);
                }
              }}
            >
              <FlutterShadcnRadioGroupItem value="small">Small</FlutterShadcnRadioGroupItem>
              <FlutterShadcnRadioGroupItem value="medium">Medium</FlutterShadcnRadioGroupItem>
              <FlutterShadcnRadioGroupItem value="large">Large</FlutterShadcnRadioGroupItem>
            </FlutterShadcnRadioGroup>
            <p className="text-sm text-gray-500 mt-2">Selected size: {selectedSize}</p>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Descriptions</h2>
            <FlutterShadcnRadioGroup value="startup">
              <FlutterShadcnRadioGroupItem value="startup">Startup</FlutterShadcnRadioGroupItem>
              <FlutterShadcnRadioGroupItem value="business">Business</FlutterShadcnRadioGroupItem>
              <FlutterShadcnRadioGroupItem value="enterprise">Enterprise</FlutterShadcnRadioGroupItem>
            </FlutterShadcnRadioGroup>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled State</h2>
            <FlutterShadcnRadioGroup value="option1" disabled>
              <FlutterShadcnRadioGroupItem value="option1">Option 1 (disabled)</FlutterShadcnRadioGroupItem>
              <FlutterShadcnRadioGroupItem value="option2">Option 2 (disabled)</FlutterShadcnRadioGroupItem>
            </FlutterShadcnRadioGroup>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
