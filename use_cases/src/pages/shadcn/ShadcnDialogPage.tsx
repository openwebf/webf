import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnDialog,
  FlutterShadcnDialogHeader,
  FlutterShadcnDialogTitle,
  FlutterShadcnDialogDescription,
  FlutterShadcnDialogContent,
  FlutterShadcnDialogFooter,
  FlutterShadcnSheet,
  FlutterShadcnSheetHeader,
  FlutterShadcnSheetTitle,
  FlutterShadcnSheetDescription,
  FlutterShadcnSheetContent,
  FlutterShadcnButton,
  FlutterShadcnInput,
} from '@openwebf/react-shadcn-ui';

export const ShadcnDialogPage: React.FC = () => {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [alertDialogOpen, setAlertDialogOpen] = useState(false);
  const [sheetOpen, setSheetOpen] = useState(false);

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Dialog & Sheet</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Dialog</h2>
            <p className="text-sm text-gray-600 mb-4">
              A modal dialog that interrupts the user with important content.
            </p>
            <FlutterShadcnButton onClick={() => setDialogOpen(true)}>
              Open Dialog
            </FlutterShadcnButton>

            <FlutterShadcnDialog open={dialogOpen} onClose={() => setDialogOpen(false)}>
              <FlutterShadcnDialogContent>
                <FlutterShadcnDialogHeader>
                  <FlutterShadcnDialogTitle>Edit profile</FlutterShadcnDialogTitle>
                  <FlutterShadcnDialogDescription>
                    Make changes to your profile here. Click save when you're done.
                  </FlutterShadcnDialogDescription>
                </FlutterShadcnDialogHeader>
                <div className="space-y-4 py-4">
                  <div>
                    <label className="text-sm font-medium">Name</label>
                    <FlutterShadcnInput placeholder="Enter your name" />
                  </div>
                  <div>
                    <label className="text-sm font-medium">Username</label>
                    <FlutterShadcnInput placeholder="@username" />
                  </div>
                </div>
                <FlutterShadcnDialogFooter>
                  <FlutterShadcnButton variant="outline" onClick={() => setDialogOpen(false)}>
                    Cancel
                  </FlutterShadcnButton>
                  <FlutterShadcnButton onClick={() => setDialogOpen(false)}>
                    Save changes
                  </FlutterShadcnButton>
                </FlutterShadcnDialogFooter>
              </FlutterShadcnDialogContent>
            </FlutterShadcnDialog>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Alert Dialog</h2>
            <p className="text-sm text-gray-600 mb-4">
              A modal dialog for important warnings that require confirmation.
            </p>
            <FlutterShadcnButton variant="destructive" onClick={() => setAlertDialogOpen(true)}>
              Delete Account
            </FlutterShadcnButton>

            <FlutterShadcnDialog open={alertDialogOpen} onClose={() => setAlertDialogOpen(false)}>
              <FlutterShadcnDialogContent>
                <FlutterShadcnDialogHeader>
                  <FlutterShadcnDialogTitle>Are you absolutely sure?</FlutterShadcnDialogTitle>
                  <FlutterShadcnDialogDescription>
                    This action cannot be undone. This will permanently delete your
                    account and remove your data from our servers.
                  </FlutterShadcnDialogDescription>
                </FlutterShadcnDialogHeader>
                <FlutterShadcnDialogFooter>
                  <FlutterShadcnButton variant="outline" onClick={() => setAlertDialogOpen(false)}>
                    Cancel
                  </FlutterShadcnButton>
                  <FlutterShadcnButton variant="destructive" onClick={() => setAlertDialogOpen(false)}>
                    Delete
                  </FlutterShadcnButton>
                </FlutterShadcnDialogFooter>
              </FlutterShadcnDialogContent>
            </FlutterShadcnDialog>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Sheet (Bottom Sheet)</h2>
            <p className="text-sm text-gray-600 mb-4">
              A panel that slides in from the edge of the screen.
            </p>
            <FlutterShadcnButton variant="outline" onClick={() => setSheetOpen(true)}>
              Open Sheet
            </FlutterShadcnButton>

            <FlutterShadcnSheet open={sheetOpen} side="bottom" onClose={() => setSheetOpen(false)}>
              <FlutterShadcnSheetContent>
                <FlutterShadcnSheetHeader>
                  <FlutterShadcnSheetTitle>Edit Settings</FlutterShadcnSheetTitle>
                  <FlutterShadcnSheetDescription>
                    Make changes to your settings here.
                  </FlutterShadcnSheetDescription>
                </FlutterShadcnSheetHeader>
                <div className="space-y-4 py-4">
                  <div>
                    <label className="text-sm font-medium">Theme</label>
                    <FlutterShadcnInput placeholder="Select theme" />
                  </div>
                  <div>
                    <label className="text-sm font-medium">Language</label>
                    <FlutterShadcnInput placeholder="Select language" />
                  </div>
                </div>
                <div className="flex gap-2">
                  <FlutterShadcnButton variant="outline" onClick={() => setSheetOpen(false)}>
                    Cancel
                  </FlutterShadcnButton>
                  <FlutterShadcnButton onClick={() => setSheetOpen(false)}>
                    Save
                  </FlutterShadcnButton>
                </div>
              </FlutterShadcnSheetContent>
            </FlutterShadcnSheet>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
