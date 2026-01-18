import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnCheckbox,
  FlutterShadcnSwitch,
} from '@openwebf/react-shadcn-ui';

export const ShadcnCheckboxSwitchPage: React.FC = () => {
  const [checkboxes, setCheckboxes] = useState({
    terms: false,
    marketing: true,
    updates: false,
  });
  const [switches, setSwitches] = useState({
    notifications: true,
    darkMode: false,
    autoSave: true,
  });

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Checkbox & Switch</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Checkboxes</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <FlutterShadcnCheckbox
                  checked={checkboxes.terms}
                  onChange={() => setCheckboxes(prev => ({ ...prev, terms: !prev.terms }))}
                />
                <label className="text-sm">Accept terms and conditions</label>
              </div>
              <div className="flex items-center gap-3">
                <FlutterShadcnCheckbox
                  checked={checkboxes.marketing}
                  onChange={() => setCheckboxes(prev => ({ ...prev, marketing: !prev.marketing }))}
                />
                <label className="text-sm">Receive marketing emails</label>
              </div>
              <div className="flex items-center gap-3">
                <FlutterShadcnCheckbox
                  checked={checkboxes.updates}
                  onChange={() => setCheckboxes(prev => ({ ...prev, updates: !prev.updates }))}
                />
                <label className="text-sm">Get product updates</label>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled Checkboxes</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <FlutterShadcnCheckbox disabled />
                <label className="text-sm text-gray-400">Disabled unchecked</label>
              </div>
              <div className="flex items-center gap-3">
                <FlutterShadcnCheckbox checked disabled />
                <label className="text-sm text-gray-400">Disabled checked</label>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Switches</h2>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 border rounded-lg">
                <div>
                  <div className="font-medium">Notifications</div>
                  <div className="text-sm text-gray-500">Receive push notifications</div>
                </div>
                <FlutterShadcnSwitch
                  checked={switches.notifications}
                  onChange={() => setSwitches(prev => ({ ...prev, notifications: !prev.notifications }))}
                />
              </div>
              <div className="flex items-center justify-between p-3 border rounded-lg">
                <div>
                  <div className="font-medium">Dark Mode</div>
                  <div className="text-sm text-gray-500">Use dark theme</div>
                </div>
                <FlutterShadcnSwitch
                  checked={switches.darkMode}
                  onChange={() => setSwitches(prev => ({ ...prev, darkMode: !prev.darkMode }))}
                />
              </div>
              <div className="flex items-center justify-between p-3 border rounded-lg">
                <div>
                  <div className="font-medium">Auto Save</div>
                  <div className="text-sm text-gray-500">Automatically save changes</div>
                </div>
                <FlutterShadcnSwitch
                  checked={switches.autoSave}
                  onChange={() => setSwitches(prev => ({ ...prev, autoSave: !prev.autoSave }))}
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled Switches</h2>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 border rounded-lg opacity-50">
                <div>
                  <div className="font-medium">Disabled Off</div>
                  <div className="text-sm text-gray-500">Cannot be toggled</div>
                </div>
                <FlutterShadcnSwitch disabled />
              </div>
              <div className="flex items-center justify-between p-3 border rounded-lg opacity-50">
                <div>
                  <div className="font-medium">Disabled On</div>
                  <div className="text-sm text-gray-500">Cannot be toggled</div>
                </div>
                <FlutterShadcnSwitch checked disabled />
              </div>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
