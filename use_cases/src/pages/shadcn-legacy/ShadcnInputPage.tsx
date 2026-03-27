import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnInput,
  FlutterShadcnTextarea,
  FlutterShadcnButton,
} from '@openwebf/react-shadcn-ui';

export const ShadcnInputPage: React.FC = () => {
  const [inputValue, setInputValue] = useState('');
  const [textareaValue, setTextareaValue] = useState('');

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Shadcn Input</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Text Input</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Default Input</label>
                <FlutterShadcnInput
                  placeholder="Enter your name"
                  value={inputValue}
                  onInput={(e: any) => setInputValue(e.target?.value || '')}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Email Input</label>
                <FlutterShadcnInput
                  type="email"
                  placeholder="email@example.com"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Password Input</label>
                <FlutterShadcnInput
                  type="password"
                  placeholder="Enter password"
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Input States</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Disabled</label>
                <FlutterShadcnInput
                  placeholder="Disabled input"
                  disabled
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Read Only</label>
                <FlutterShadcnInput
                  value="Read only value"
                  readonly
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">With Max Length (20)</label>
                <FlutterShadcnInput
                  placeholder="Max 20 characters"
                  maxlength="20"
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Textarea</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Default Textarea</label>
                <FlutterShadcnTextarea
                  placeholder="Enter your message..."
                  rows="4"
                  value={textareaValue}
                  onInput={(e: any) => setTextareaValue(e.target?.value || '')}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Disabled Textarea</label>
                <FlutterShadcnTextarea
                  placeholder="Disabled textarea"
                  rows="3"
                  disabled
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Form Example</h2>
            <div className="space-y-4 p-4 border rounded-lg">
              <div>
                <label className="block text-sm font-medium mb-2">Username</label>
                <FlutterShadcnInput placeholder="johndoe" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Email</label>
                <FlutterShadcnInput type="email" placeholder="john@example.com" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Bio</label>
                <FlutterShadcnTextarea placeholder="Tell us about yourself..." rows="3" />
              </div>
              <FlutterShadcnButton>Submit</FlutterShadcnButton>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
