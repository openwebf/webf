import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnContextMenu,
  FlutterShadcnContextMenuTrigger,
  FlutterShadcnContextMenuContent,
  FlutterShadcnContextMenuItem,
  FlutterShadcnContextMenuSeparator,
} from '@openwebf/react-shadcn-ui';

export const ShadcnContextMenuPage: React.FC = () => {
  const handleAction = (action: string) => {
    console.log(`Context menu action: ${action}`);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Context Menu</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Context Menu</h2>
            <p className="text-sm text-gray-600 mb-4">Right-click (or long-press on mobile) on the box below.</p>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="flex items-center justify-center h-48 w-full border-2 border-dashed rounded-lg bg-gray-50">
                  <span className="text-gray-500">Right-click here</span>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuItem onClick={() => handleAction('back')}>
                  Back
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem onClick={() => handleAction('forward')}>
                  Forward
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem onClick={() => handleAction('reload')}>
                  Reload
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuItem onClick={() => handleAction('save')}>
                  Save Page As...
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem onClick={() => handleAction('print')}>
                  Print...
                </FlutterShadcnContextMenuItem>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Image Context Menu</h2>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="relative">
                  <div className="h-48 w-full bg-gradient-to-br from-purple-400 to-blue-500 rounded-lg flex items-center justify-center">
                    <span className="text-white text-lg font-medium">Sample Image</span>
                  </div>
                  <p className="text-xs text-gray-500 mt-1">Right-click the image above</p>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuItem>Open Image in New Tab</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem>Save Image As...</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem>Copy Image</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem>Copy Image Address</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuItem>Inspect</FlutterShadcnContextMenuItem>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Text Context Menu</h2>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="p-4 border rounded-lg bg-gray-50">
                  <p className="text-sm">
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod
                    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
                    quis nostrud exercitation ullamco laboris.
                  </p>
                  <p className="text-xs text-gray-500 mt-2">Right-click the text above</p>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuItem>Copy</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem>Cut</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem>Paste</FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuItem>Select All</FlutterShadcnContextMenuItem>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">File Item Context Menu</h2>
            <div className="space-y-2">
              {['document.pdf', 'spreadsheet.xlsx', 'presentation.pptx'].map((file, index) => (
                <FlutterShadcnContextMenu key={index}>
                  <FlutterShadcnContextMenuTrigger>
                    <div className="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer">
                      <div className="w-10 h-10 bg-gray-200 rounded flex items-center justify-center text-xs">
                        {file.split('.')[1].toUpperCase()}
                      </div>
                      <div className="flex-1">
                        <p className="font-medium text-sm">{file}</p>
                        <p className="text-xs text-gray-500">Modified 2 hours ago</p>
                      </div>
                    </div>
                  </FlutterShadcnContextMenuTrigger>
                  <FlutterShadcnContextMenuContent>
                    <FlutterShadcnContextMenuItem>Open</FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem>Open With...</FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuSeparator />
                    <FlutterShadcnContextMenuItem>Download</FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem>Share</FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem>Rename</FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuSeparator />
                    <FlutterShadcnContextMenuItem>Move to Trash</FlutterShadcnContextMenuItem>
                  </FlutterShadcnContextMenuContent>
                </FlutterShadcnContextMenu>
              ))}
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
