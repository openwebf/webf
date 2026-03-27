import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnSelect,
  FlutterShadcnSelectItem,
  FlutterShadcnSelectGroup,
  FlutterShadcnSelectSeparator,
  FlutterShadcnCombobox,
  FlutterShadcnComboboxItem,
} from '@openwebf/react-shadcn-ui';

export const ShadcnSelectPage: React.FC = () => {
  const [selectedFruit, setSelectedFruit] = useState('');
  const [selectedFramework, setSelectedFramework] = useState('');

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Select & Combobox</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Select</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Choose a fruit</label>
                <FlutterShadcnSelect
                  placeholder="Select a fruit..."
                  value={selectedFruit}
                  onChange={(e: any) => setSelectedFruit(e.detail?.value || '')}
                >
                  <FlutterShadcnSelectItem value="apple">Apple</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="banana">Banana</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="orange">Orange</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="grape">Grape</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="mango">Mango</FlutterShadcnSelectItem>
                </FlutterShadcnSelect>
                <p className="text-sm text-gray-500 mt-2">Selected: {selectedFruit || 'None'}</p>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Select with Groups</h2>
            <div>
              <label className="block text-sm font-medium mb-2">Choose a framework</label>
              <FlutterShadcnSelect
                placeholder="Select a framework..."
                value={selectedFramework}
                onChange={(e: any) => setSelectedFramework(e.detail?.value || '')}
              >
                <FlutterShadcnSelectGroup label="Frontend">
                  <FlutterShadcnSelectItem value="react">React</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="vue">Vue</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="angular">Angular</FlutterShadcnSelectItem>
                </FlutterShadcnSelectGroup>
                <FlutterShadcnSelectSeparator />
                <FlutterShadcnSelectGroup label="Backend">
                  <FlutterShadcnSelectItem value="express">Express</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="fastify">Fastify</FlutterShadcnSelectItem>
                  <FlutterShadcnSelectItem value="nest">NestJS</FlutterShadcnSelectItem>
                </FlutterShadcnSelectGroup>
              </FlutterShadcnSelect>
              <p className="text-sm text-gray-500 mt-2">Selected: {selectedFramework || 'None'}</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled Select</h2>
            <FlutterShadcnSelect placeholder="Disabled select" disabled>
              <FlutterShadcnSelectItem value="option1">Option 1</FlutterShadcnSelectItem>
              <FlutterShadcnSelectItem value="option2">Option 2</FlutterShadcnSelectItem>
            </FlutterShadcnSelect>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Combobox (Searchable Select)</h2>
            <div>
              <label className="block text-sm font-medium mb-2">Search countries</label>
              <FlutterShadcnCombobox
                placeholder="Select a country..."
                searchPlaceholder="Search countries..."
              >
                <FlutterShadcnComboboxItem value="us">United States</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="uk">United Kingdom</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="ca">Canada</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="au">Australia</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="de">Germany</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="fr">France</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="jp">Japan</FlutterShadcnComboboxItem>
                <FlutterShadcnComboboxItem value="cn">China</FlutterShadcnComboboxItem>
              </FlutterShadcnCombobox>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
