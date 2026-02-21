import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnMenubar,
  FlutterShadcnMenubarMenu,
  FlutterShadcnMenubarTrigger,
  FlutterShadcnMenubarContent,
  FlutterShadcnMenubarItem,
  FlutterShadcnMenubarSeparator,
  FlutterShadcnMenubarLabel,
  FlutterShadcnMenubarSub,
  FlutterShadcnMenubarSubTrigger,
  FlutterShadcnMenubarSubContent,
  FlutterShadcnMenubarCheckboxItem,
  FlutterShadcnMenubarRadioGroup,
  FlutterShadcnMenubarRadioItem,
} from '@openwebf/react-shadcn-ui';

export const ShadcnMenubarPage: React.FC = () => {
  const [showBookmarksBar, setShowBookmarksBar] = useState(true);
  const [showFullUrls, setShowFullUrls] = useState(false);
  const [showStatusBar, setShowStatusBar] = useState(true);
  const [selectedPerson, setSelectedPerson] = useState('benoit');

  const handleAction = (action: string) => {
    console.log(`Menubar action: ${action}`);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Menubar</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Complete Menubar</h2>
            <p className="text-sm text-gray-600 mb-4">
              A full-featured menubar with items, shortcuts, submenus, checkboxes, and radio groups.
            </p>
            <FlutterShadcnMenubar>
              {/* File Menu */}
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>File</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarItem shortcut="⌘T" onClick={() => handleAction('newTab')}>
                    New Tab
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem shortcut="⌘N" onClick={() => handleAction('newWindow')}>
                    New Window
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem disabled>
                    New Incognito Window
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarSub>
                    <FlutterShadcnMenubarSubTrigger>Share</FlutterShadcnMenubarSubTrigger>
                    <FlutterShadcnMenubarSubContent>
                      <FlutterShadcnMenubarItem onClick={() => handleAction('emailLink')}>
                        Email link
                      </FlutterShadcnMenubarItem>
                      <FlutterShadcnMenubarItem onClick={() => handleAction('messages')}>
                        Messages
                      </FlutterShadcnMenubarItem>
                      <FlutterShadcnMenubarItem onClick={() => handleAction('notes')}>
                        Notes
                      </FlutterShadcnMenubarItem>
                    </FlutterShadcnMenubarSubContent>
                  </FlutterShadcnMenubarSub>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem shortcut="⌘P" onClick={() => handleAction('print')}>
                    Print...
                  </FlutterShadcnMenubarItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>

              {/* Edit Menu */}
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>Edit</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarItem shortcut="⌘Z" onClick={() => handleAction('undo')}>
                    Undo
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem shortcut="⇧⌘Z" onClick={() => handleAction('redo')}>
                    Redo
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarSub>
                    <FlutterShadcnMenubarSubTrigger>Find</FlutterShadcnMenubarSubTrigger>
                    <FlutterShadcnMenubarSubContent>
                      <FlutterShadcnMenubarItem onClick={() => handleAction('searchWeb')}>
                        Search the web
                      </FlutterShadcnMenubarItem>
                      <FlutterShadcnMenubarSeparator />
                      <FlutterShadcnMenubarItem onClick={() => handleAction('find')}>
                        Find...
                      </FlutterShadcnMenubarItem>
                      <FlutterShadcnMenubarItem onClick={() => handleAction('findNext')}>
                        Find Next
                      </FlutterShadcnMenubarItem>
                      <FlutterShadcnMenubarItem onClick={() => handleAction('findPrev')}>
                        Find Previous
                      </FlutterShadcnMenubarItem>
                    </FlutterShadcnMenubarSubContent>
                  </FlutterShadcnMenubarSub>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem shortcut="⌘X" onClick={() => handleAction('cut')}>
                    Cut
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem shortcut="⌘C" onClick={() => handleAction('copy')}>
                    Copy
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem shortcut="⌘V" onClick={() => handleAction('paste')}>
                    Paste
                  </FlutterShadcnMenubarItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>

              {/* View Menu */}
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>View</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarCheckboxItem
                    checked={showBookmarksBar}
                    onChange={() => setShowBookmarksBar(!showBookmarksBar)}
                  >
                    Always Show Bookmarks Bar
                  </FlutterShadcnMenubarCheckboxItem>
                  <FlutterShadcnMenubarCheckboxItem
                    checked={showFullUrls}
                    onChange={() => setShowFullUrls(!showFullUrls)}
                  >
                    Always Show Full URLs
                  </FlutterShadcnMenubarCheckboxItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem inset shortcut="⌘R" onClick={() => handleAction('reload')}>
                    Reload
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem inset shortcut="⇧⌘R" disabled>
                    Force Reload
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem inset onClick={() => handleAction('toggleFullscreen')}>
                    Toggle Fullscreen
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem inset onClick={() => handleAction('hideSidebar')}>
                    Hide Sidebar
                  </FlutterShadcnMenubarItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>

              {/* Profiles Menu */}
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>Profiles</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarRadioGroup
                    value={selectedPerson}
                    onChange={(e: CustomEvent<{ value: string | null }>) => {
                      if (e.detail?.value) {
                        setSelectedPerson(e.detail.value);
                      }
                    }}
                  >
                    <FlutterShadcnMenubarRadioItem value="andy">
                      Andy
                    </FlutterShadcnMenubarRadioItem>
                    <FlutterShadcnMenubarRadioItem value="benoit">
                      Benoit
                    </FlutterShadcnMenubarRadioItem>
                    <FlutterShadcnMenubarRadioItem value="luis">
                      Luis
                    </FlutterShadcnMenubarRadioItem>
                  </FlutterShadcnMenubarRadioGroup>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem inset onClick={() => handleAction('editProfiles')}>
                    Edit...
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem inset onClick={() => handleAction('addProfile')}>
                    Add Profile...
                  </FlutterShadcnMenubarItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>
            </FlutterShadcnMenubar>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Simple Menubar</h2>
            <p className="text-sm text-gray-600 mb-4">
              A minimal menubar with basic items and shortcuts.
            </p>
            <FlutterShadcnMenubar>
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>File</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarItem shortcut="⌘N" onClick={() => handleAction('new')}>
                    New
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem shortcut="⌘O" onClick={() => handleAction('open')}>
                    Open
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarItem shortcut="⌘S" onClick={() => handleAction('save')}>
                    Save
                  </FlutterShadcnMenubarItem>
                  <FlutterShadcnMenubarSeparator />
                  <FlutterShadcnMenubarItem onClick={() => handleAction('exit')}>
                    Exit
                  </FlutterShadcnMenubarItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>Help</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarItem onClick={() => handleAction('about')}>
                    About
                  </FlutterShadcnMenubarItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>
            </FlutterShadcnMenubar>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Menubar with Status Bar Toggle</h2>
            <p className="text-sm text-gray-600 mb-4">
              Demonstrates checkbox items to toggle visibility of UI elements.
            </p>
            <FlutterShadcnMenubar>
              <FlutterShadcnMenubarMenu>
                <FlutterShadcnMenubarTrigger>View</FlutterShadcnMenubarTrigger>
                <FlutterShadcnMenubarContent>
                  <FlutterShadcnMenubarCheckboxItem
                    checked={showStatusBar}
                    shortcut="⌘B"
                    onChange={() => setShowStatusBar(!showStatusBar)}
                  >
                    Status Bar
                  </FlutterShadcnMenubarCheckboxItem>
                  <FlutterShadcnMenubarCheckboxItem
                    checked={showBookmarksBar}
                    onChange={() => setShowBookmarksBar(!showBookmarksBar)}
                  >
                    Bookmarks Bar
                  </FlutterShadcnMenubarCheckboxItem>
                  <FlutterShadcnMenubarCheckboxItem
                    checked={showFullUrls}
                    onChange={() => setShowFullUrls(!showFullUrls)}
                  >
                    Full URLs
                  </FlutterShadcnMenubarCheckboxItem>
                </FlutterShadcnMenubarContent>
              </FlutterShadcnMenubarMenu>
            </FlutterShadcnMenubar>
            {showStatusBar && (
              <div className="mt-3 p-3 bg-gray-100 rounded-lg border">
                <p className="text-sm text-gray-600">Status bar is visible</p>
              </div>
            )}
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
