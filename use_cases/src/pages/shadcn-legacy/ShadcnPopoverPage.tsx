import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnPopover,
  FlutterShadcnPopoverTrigger,
  FlutterShadcnPopoverContent,
  FlutterShadcnTooltip,
  FlutterShadcnButton,
  FlutterShadcnInput,
} from '@openwebf/react-shadcn-ui';

export const ShadcnPopoverPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Popover & Tooltip</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Popover</h2>
            <FlutterShadcnPopover>
              <FlutterShadcnPopoverTrigger>
                <FlutterShadcnButton variant="outline">Open Popover</FlutterShadcnButton>
              </FlutterShadcnPopoverTrigger>
              <FlutterShadcnPopoverContent>
                <div className="p-4">
                  <h3 className="font-medium mb-2">Popover Title</h3>
                  <p className="text-sm text-gray-600">
                    This is a popover content. You can put any content here.
                  </p>
                </div>
              </FlutterShadcnPopoverContent>
            </FlutterShadcnPopover>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Popover with Form</h2>
            <FlutterShadcnPopover>
              <FlutterShadcnPopoverTrigger>
                <FlutterShadcnButton>Update Dimensions</FlutterShadcnButton>
              </FlutterShadcnPopoverTrigger>
              <FlutterShadcnPopoverContent>
                <div className="p-4 space-y-4">
                  <h3 className="font-medium">Dimensions</h3>
                  <p className="text-sm text-gray-600">Set the dimensions for the layer.</p>
                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <label className="text-xs font-medium">Width</label>
                      <FlutterShadcnInput placeholder="100%" />
                    </div>
                    <div>
                      <label className="text-xs font-medium">Height</label>
                      <FlutterShadcnInput placeholder="25px" />
                    </div>
                    <div>
                      <label className="text-xs font-medium">Max Width</label>
                      <FlutterShadcnInput placeholder="300px" />
                    </div>
                    <div>
                      <label className="text-xs font-medium">Max Height</label>
                      <FlutterShadcnInput placeholder="none" />
                    </div>
                  </div>
                </div>
              </FlutterShadcnPopoverContent>
            </FlutterShadcnPopover>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Tooltip</h2>
            <div className="flex gap-4">
              <FlutterShadcnTooltip content="This is a tooltip">
                <FlutterShadcnButton variant="outline">Hover me</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Add to library">
                <FlutterShadcnButton variant="secondary">+</FlutterShadcnButton>
              </FlutterShadcnTooltip>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Tooltips on Icons</h2>
            <div className="flex gap-4 items-center">
              <FlutterShadcnTooltip content="Bold">
                <FlutterShadcnButton variant="ghost" size="icon">B</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Italic">
                <FlutterShadcnButton variant="ghost" size="icon">I</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Underline">
                <FlutterShadcnButton variant="ghost" size="icon">U</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Strikethrough">
                <FlutterShadcnButton variant="ghost" size="icon">S</FlutterShadcnButton>
              </FlutterShadcnTooltip>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Tooltip Positions</h2>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnTooltip content="Top tooltip" side="top">
                <FlutterShadcnButton variant="outline">Top</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Bottom tooltip" side="bottom">
                <FlutterShadcnButton variant="outline">Bottom</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Left tooltip" side="left">
                <FlutterShadcnButton variant="outline">Left</FlutterShadcnButton>
              </FlutterShadcnTooltip>
              <FlutterShadcnTooltip content="Right tooltip" side="right">
                <FlutterShadcnButton variant="outline">Right</FlutterShadcnButton>
              </FlutterShadcnTooltip>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Popover with Actions</h2>
            <FlutterShadcnPopover>
              <FlutterShadcnPopoverTrigger>
                <FlutterShadcnButton variant="destructive">Delete Item</FlutterShadcnButton>
              </FlutterShadcnPopoverTrigger>
              <FlutterShadcnPopoverContent>
                <div className="p-4">
                  <h3 className="font-medium mb-2">Are you sure?</h3>
                  <p className="text-sm text-gray-600 mb-4">
                    This action cannot be undone. This will permanently delete the item.
                  </p>
                  <div className="flex gap-2 justify-end">
                    <FlutterShadcnButton variant="outline" size="sm">Cancel</FlutterShadcnButton>
                    <FlutterShadcnButton variant="destructive" size="sm">Delete</FlutterShadcnButton>
                  </div>
                </div>
              </FlutterShadcnPopoverContent>
            </FlutterShadcnPopover>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Tooltip in Context</h2>
            <div className="p-4 border rounded-lg">
              <p className="text-sm mb-4">
                Click the{' '}
                <FlutterShadcnTooltip content="This will save your changes">
                  <span className="text-blue-500 underline cursor-pointer">save button</span>
                </FlutterShadcnTooltip>
                {' '}to save your changes, or the{' '}
                <FlutterShadcnTooltip content="This will discard unsaved changes">
                  <span className="text-red-500 underline cursor-pointer">cancel button</span>
                </FlutterShadcnTooltip>
                {' '}to discard them.
              </p>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
