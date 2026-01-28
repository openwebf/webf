import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnDropdownMenu,
  FlutterShadcnDropdownMenuTrigger,
  FlutterShadcnDropdownMenuContent,
  FlutterShadcnDropdownMenuItem,
  FlutterShadcnDropdownMenuSeparator,
  FlutterShadcnDropdownMenuLabel,
  FlutterShadcnButton,
} from '@openwebf/react-shadcn-ui';

export const ShadcnDropdownPage: React.FC = () => {
  const handleAction = (action: string) => {
    console.log(`Action: ${action}`);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Dropdown Menu</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Dropdown</h2>
            <FlutterShadcnDropdownMenu>
              <FlutterShadcnDropdownMenuTrigger>
                <FlutterShadcnButton variant="outline">Open Menu</FlutterShadcnButton>
              </FlutterShadcnDropdownMenuTrigger>
              <FlutterShadcnDropdownMenuContent>
                <FlutterShadcnDropdownMenuItem onClick={() => handleAction('profile')}>
                  Profile
                </FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem onClick={() => handleAction('settings')}>
                  Settings
                </FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem onClick={() => handleAction('billing')}>
                  Billing
                </FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuSeparator />
                <FlutterShadcnDropdownMenuItem onClick={() => handleAction('logout')}>
                  Logout
                </FlutterShadcnDropdownMenuItem>
              </FlutterShadcnDropdownMenuContent>
            </FlutterShadcnDropdownMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Labels</h2>
            <FlutterShadcnDropdownMenu>
              <FlutterShadcnDropdownMenuTrigger>
                <FlutterShadcnButton>My Account</FlutterShadcnButton>
              </FlutterShadcnDropdownMenuTrigger>
              <FlutterShadcnDropdownMenuContent>
                <FlutterShadcnDropdownMenuLabel>My Account</FlutterShadcnDropdownMenuLabel>
                <FlutterShadcnDropdownMenuSeparator />
                <FlutterShadcnDropdownMenuItem>Profile</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Billing</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Team</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Subscription</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuSeparator />
                <FlutterShadcnDropdownMenuLabel>Help</FlutterShadcnDropdownMenuLabel>
                <FlutterShadcnDropdownMenuSeparator />
                <FlutterShadcnDropdownMenuItem>Documentation</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Support</FlutterShadcnDropdownMenuItem>
              </FlutterShadcnDropdownMenuContent>
            </FlutterShadcnDropdownMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">File Actions</h2>
            <FlutterShadcnDropdownMenu>
              <FlutterShadcnDropdownMenuTrigger>
                <FlutterShadcnButton variant="secondary">File</FlutterShadcnButton>
              </FlutterShadcnDropdownMenuTrigger>
              <FlutterShadcnDropdownMenuContent>
                <FlutterShadcnDropdownMenuItem>New File</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>New Folder</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuSeparator />
                <FlutterShadcnDropdownMenuItem>Open</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Save</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Save As...</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuSeparator />
                <FlutterShadcnDropdownMenuItem>Export</FlutterShadcnDropdownMenuItem>
                <FlutterShadcnDropdownMenuItem>Print</FlutterShadcnDropdownMenuItem>
              </FlutterShadcnDropdownMenuContent>
            </FlutterShadcnDropdownMenu>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Row Actions</h2>
            <div className="border rounded-lg">
              {['document.pdf', 'image.png', 'data.csv'].map((file, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 border-b last:border-b-0"
                >
                  <span className="text-sm">{file}</span>
                  <FlutterShadcnDropdownMenu>
                    <FlutterShadcnDropdownMenuTrigger>
                      <FlutterShadcnButton variant="ghost" size="sm">
                        ...
                      </FlutterShadcnButton>
                    </FlutterShadcnDropdownMenuTrigger>
                    <FlutterShadcnDropdownMenuContent>
                      <FlutterShadcnDropdownMenuItem>View</FlutterShadcnDropdownMenuItem>
                      <FlutterShadcnDropdownMenuItem>Download</FlutterShadcnDropdownMenuItem>
                      <FlutterShadcnDropdownMenuItem>Rename</FlutterShadcnDropdownMenuItem>
                      <FlutterShadcnDropdownMenuSeparator />
                      <FlutterShadcnDropdownMenuItem>Delete</FlutterShadcnDropdownMenuItem>
                    </FlutterShadcnDropdownMenuContent>
                  </FlutterShadcnDropdownMenu>
                </div>
              ))}
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">User Menu</h2>
            <div className="flex items-center gap-4 p-4 border rounded-lg">
              <div className="flex-1">
                <p className="font-medium">John Doe</p>
                <p className="text-sm text-gray-500">john@example.com</p>
              </div>
              <FlutterShadcnDropdownMenu>
                <FlutterShadcnDropdownMenuTrigger>
                  <div className="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center cursor-pointer">
                    JD
                  </div>
                </FlutterShadcnDropdownMenuTrigger>
                <FlutterShadcnDropdownMenuContent>
                  <FlutterShadcnDropdownMenuLabel>john@example.com</FlutterShadcnDropdownMenuLabel>
                  <FlutterShadcnDropdownMenuSeparator />
                  <FlutterShadcnDropdownMenuItem>Profile</FlutterShadcnDropdownMenuItem>
                  <FlutterShadcnDropdownMenuItem>Settings</FlutterShadcnDropdownMenuItem>
                  <FlutterShadcnDropdownMenuItem>Keyboard shortcuts</FlutterShadcnDropdownMenuItem>
                  <FlutterShadcnDropdownMenuSeparator />
                  <FlutterShadcnDropdownMenuItem>Log out</FlutterShadcnDropdownMenuItem>
                </FlutterShadcnDropdownMenuContent>
              </FlutterShadcnDropdownMenu>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
