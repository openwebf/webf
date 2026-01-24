import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnContextMenu,
  FlutterShadcnContextMenuTrigger,
  FlutterShadcnContextMenuContent,
  FlutterShadcnContextMenuItem,
  FlutterShadcnContextMenuSeparator,
  FlutterShadcnContextMenuLabel,
  FlutterShadcnContextMenuSub,
  FlutterShadcnContextMenuSubTrigger,
  FlutterShadcnContextMenuSubContent,
  FlutterShadcnContextMenuCheckboxItem,
  FlutterShadcnContextMenuRadioGroup,
  FlutterShadcnContextMenuRadioItem,
} from '@openwebf/react-shadcn-ui';

export const ShadcnContextMenuPage: React.FC = () => {
  const [showBookmarksBar, setShowBookmarksBar] = useState(true);
  const [showFullUrls, setShowFullUrls] = useState(false);
  const [selectedPerson, setSelectedPerson] = useState('pedro');

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
                <FlutterShadcnContextMenuItem onClick={() => handleAction('forward')} disabled>
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
            <h2 className="text-lg font-semibold mb-4">With Keyboard Shortcuts</h2>
            <p className="text-sm text-gray-600 mb-4">Menu items can display keyboard shortcuts.</p>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="flex items-center justify-center h-48 w-full border-2 border-dashed rounded-lg bg-gray-50">
                  <span className="text-gray-500">Right-click for edit menu</span>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuItem shortcut="⌘Z" onClick={() => handleAction('undo')}>
                  Undo
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem shortcut="⇧⌘Z" onClick={() => handleAction('redo')}>
                  Redo
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuItem shortcut="⌘X" onClick={() => handleAction('cut')}>
                  Cut
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem shortcut="⌘C" onClick={() => handleAction('copy')}>
                  Copy
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem shortcut="⌘V" onClick={() => handleAction('paste')}>
                  Paste
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuItem shortcut="⌘A" onClick={() => handleAction('selectAll')}>
                  Select All
                </FlutterShadcnContextMenuItem>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Submenus</h2>
            <p className="text-sm text-gray-600 mb-4">Context menus can have nested submenus.</p>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="flex items-center justify-center h-48 w-full border-2 border-dashed rounded-lg bg-gray-50">
                  <span className="text-gray-500">Right-click for nested menu</span>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuItem inset onClick={() => handleAction('back')}>
                  Back
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem inset disabled>
                  Forward
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem inset onClick={() => handleAction('reload')}>
                  Reload
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSub>
                  <FlutterShadcnContextMenuSubTrigger inset>
                    More Tools
                  </FlutterShadcnContextMenuSubTrigger>
                  <FlutterShadcnContextMenuSubContent>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('savePageAs')}>
                      Save Page As...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('createShortcut')}>
                      Create Shortcut...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('nameWindow')}>
                      Name Window...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuSeparator />
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('devTools')}>
                      Developer Tools
                    </FlutterShadcnContextMenuItem>
                  </FlutterShadcnContextMenuSubContent>
                </FlutterShadcnContextMenuSub>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Checkboxes</h2>
            <p className="text-sm text-gray-600 mb-4">Menu items can have checkbox indicators.</p>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="flex items-center justify-center h-48 w-full border-2 border-dashed rounded-lg bg-gray-50">
                  <span className="text-gray-500">Right-click for checkbox menu</span>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuCheckboxItem
                  checked={showBookmarksBar}
                  onChange={() => setShowBookmarksBar(!showBookmarksBar)}
                >
                  Show Bookmarks Bar
                </FlutterShadcnContextMenuCheckboxItem>
                <FlutterShadcnContextMenuCheckboxItem
                  checked={showFullUrls}
                  onChange={() => setShowFullUrls(!showFullUrls)}
                >
                  Show Full URLs
                </FlutterShadcnContextMenuCheckboxItem>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Radio Items</h2>
            <p className="text-sm text-gray-600 mb-4">Menu items can be grouped as radio buttons.</p>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="flex items-center justify-center h-48 w-full border-2 border-dashed rounded-lg bg-gray-50">
                  <span className="text-gray-500">Right-click for radio menu</span>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuRadioGroup
                  value={selectedPerson}
                  onChange={(e: CustomEvent<{ value: string | null }>) => {
                    if (e.detail?.value) {
                      setSelectedPerson(e.detail.value);
                    }
                  }}
                >
                  <FlutterShadcnContextMenuLabel>People</FlutterShadcnContextMenuLabel>
                  <FlutterShadcnContextMenuSeparator />
                  <FlutterShadcnContextMenuRadioItem value="pedro">
                    Pedro Duarte
                  </FlutterShadcnContextMenuRadioItem>
                  <FlutterShadcnContextMenuRadioItem value="colm">
                    Colm Tuite
                  </FlutterShadcnContextMenuRadioItem>
                </FlutterShadcnContextMenuRadioGroup>
              </FlutterShadcnContextMenuContent>
            </FlutterShadcnContextMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Complete Example</h2>
            <p className="text-sm text-gray-600 mb-4">A comprehensive context menu with all features.</p>
            <FlutterShadcnContextMenu>
              <FlutterShadcnContextMenuTrigger>
                <div className="flex items-center justify-center h-48 w-full border-2 border-dashed rounded-lg bg-gray-50">
                  <span className="text-gray-500">Right-click for full menu</span>
                </div>
              </FlutterShadcnContextMenuTrigger>
              <FlutterShadcnContextMenuContent>
                <FlutterShadcnContextMenuItem inset onClick={() => handleAction('back')}>
                  Back
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem inset disabled>
                  Forward
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuItem inset onClick={() => handleAction('reload')}>
                  Reload
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSub>
                  <FlutterShadcnContextMenuSubTrigger inset>
                    More Tools
                  </FlutterShadcnContextMenuSubTrigger>
                  <FlutterShadcnContextMenuSubContent>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('savePageAs')}>
                      Save Page As...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('createShortcut')}>
                      Create Shortcut...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('nameWindow')}>
                      Name Window...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuSeparator />
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('devTools')}>
                      Developer Tools
                    </FlutterShadcnContextMenuItem>
                  </FlutterShadcnContextMenuSubContent>
                </FlutterShadcnContextMenuSub>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuCheckboxItem
                  checked={showBookmarksBar}
                  onChange={() => setShowBookmarksBar(!showBookmarksBar)}
                >
                  Show Bookmarks Bar
                </FlutterShadcnContextMenuCheckboxItem>
                <FlutterShadcnContextMenuItem inset>
                  Show Full URLs
                </FlutterShadcnContextMenuItem>
                <FlutterShadcnContextMenuSeparator />
                <FlutterShadcnContextMenuRadioGroup
                  value={selectedPerson}
                  onChange={(e: CustomEvent<{ value: string | null }>) => {
                    if (e.detail?.value) {
                      setSelectedPerson(e.detail.value);
                    }
                  }}
                >
                  <FlutterShadcnContextMenuLabel>People</FlutterShadcnContextMenuLabel>
                  <FlutterShadcnContextMenuSeparator />
                  <FlutterShadcnContextMenuRadioItem value="pedro">
                    Pedro Duarte
                  </FlutterShadcnContextMenuRadioItem>
                  <FlutterShadcnContextMenuRadioItem value="colm">
                    Colm Tuite
                  </FlutterShadcnContextMenuRadioItem>
                </FlutterShadcnContextMenuRadioGroup>
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
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('open')}>
                      Open
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('openWith')}>
                      Open With...
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuSeparator />
                    <FlutterShadcnContextMenuItem shortcut="⌘D" onClick={() => handleAction('download')}>
                      Download
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem onClick={() => handleAction('share')}>
                      Share
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuItem shortcut="⌘R" onClick={() => handleAction('rename')}>
                      Rename
                    </FlutterShadcnContextMenuItem>
                    <FlutterShadcnContextMenuSeparator />
                    <FlutterShadcnContextMenuItem shortcut="⌘⌫" onClick={() => handleAction('trash')}>
                      Move to Trash
                    </FlutterShadcnContextMenuItem>
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
