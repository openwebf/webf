import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnInput,
  FlutterShadcnTextarea,
  FlutterShadcnButton,
} from '@openwebf/react-shadcn-ui';

// New props added but not yet regenerated in the npm package types.
// Cast to allow passing them as attributes until types are regenerated.
const ShadcnInput = FlutterShadcnInput as React.FC<any>;

export const ShadcnInputPage: React.FC = () => {
  const [inputValue, setInputValue] = useState('');
  const [textareaValue, setTextareaValue] = useState('');
  const [submitted, setSubmitted] = useState('');

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
                <ShadcnInput
                  placeholder="Enter your name"
                  value={inputValue}
                  onInput={(e: any) => setInputValue(e.target?.value || '')}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Email Input</label>
                <ShadcnInput
                  type="email"
                  placeholder="email@example.com"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Password Input</label>
                <ShadcnInput
                  type="password"
                  placeholder="Enter password"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Password (custom mask '*')</label>
                <ShadcnInput
                  type="password"
                  placeholder="Enter password"
                  obscuringcharacter="*"
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Input States</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Disabled</label>
                <ShadcnInput
                  placeholder="Disabled input"
                  disabled
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Read Only</label>
                <ShadcnInput
                  value="Read only value"
                  readonly
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">With Max Length (20)</label>
                <ShadcnInput
                  placeholder="Max 20 characters"
                  maxlength="20"
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Text Alignment</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Left (default)</label>
                <ShadcnInput placeholder="Left aligned" textalign="left" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Center</label>
                <ShadcnInput placeholder="Center aligned" textalign="center" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Right</label>
                <ShadcnInput placeholder="Right aligned" textalign="right" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Keyboard & Input Behavior</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Autocapitalize: words</label>
                <ShadcnInput
                  placeholder="Each Word Capitalized"
                  autocapitalize="words"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">No autocorrect / suggestions</label>
                <ShadcnInput
                  placeholder="Raw input"
                  autocorrect={false}
                  enablesuggestions={false}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Enter key: search</label>
                <ShadcnInput
                  placeholder="Search..."
                  type="search"
                  enterkeyhint="search"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">
                  Submit event (enterkeyhint: done)
                </label>
                <ShadcnInput
                  placeholder="Press Enter to submit"
                  enterkeyhint="done"
                  onSubmit={() => setSubmitted('Submitted!')}
                />
                {submitted && (
                  <span className="text-sm text-green-600 mt-1 block">{submitted}</span>
                )}
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Multi-line Input</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Min 2 / Max 5 lines</label>
                <ShadcnInput
                  placeholder="Grows from 2 to 5 lines..."
                  minlines="2"
                  maxlines="5"
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Cursor & Selection Colors</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Red cursor</label>
                <ShadcnInput
                  placeholder="Type here..."
                  cursorcolor="#FF0000"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Blue selection</label>
                <ShadcnInput
                  placeholder="Select some text..."
                  selectioncolor="#4488FF"
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
                <ShadcnInput placeholder="johndoe" enterkeyhint="next" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Email</label>
                <ShadcnInput
                  type="email"
                  placeholder="john@example.com"
                  enterkeyhint="next"
                  autocapitalize="none"
                />
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
