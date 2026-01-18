import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnTabs,
  FlutterShadcnTabsList,
  FlutterShadcnTabsTrigger,
  FlutterShadcnTabsContent,
  FlutterShadcnCard,
  FlutterShadcnCardHeader,
  FlutterShadcnCardTitle,
  FlutterShadcnCardDescription,
  FlutterShadcnCardContent,
  FlutterShadcnInput,
  FlutterShadcnButton,
} from '@openwebf/react-shadcn-ui';

export const ShadcnTabsPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Tabs</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Tabs</h2>
            <FlutterShadcnTabs defaultValue="account">
              <FlutterShadcnTabsList>
                <FlutterShadcnTabsTrigger value="account">Account</FlutterShadcnTabsTrigger>
                <FlutterShadcnTabsTrigger value="password">Password</FlutterShadcnTabsTrigger>
              </FlutterShadcnTabsList>
              <FlutterShadcnTabsContent value="account">
                <FlutterShadcnCard>
                  <FlutterShadcnCardHeader>
                    <FlutterShadcnCardTitle>Account</FlutterShadcnCardTitle>
                    <FlutterShadcnCardDescription>
                      Make changes to your account here. Click save when you're done.
                    </FlutterShadcnCardDescription>
                  </FlutterShadcnCardHeader>
                  <FlutterShadcnCardContent>
                    <div className="space-y-4">
                      <div>
                        <label className="text-sm font-medium">Name</label>
                        <FlutterShadcnInput value="Pedro Duarte" />
                      </div>
                      <div>
                        <label className="text-sm font-medium">Username</label>
                        <FlutterShadcnInput value="@peduarte" />
                      </div>
                      <FlutterShadcnButton>Save changes</FlutterShadcnButton>
                    </div>
                  </FlutterShadcnCardContent>
                </FlutterShadcnCard>
              </FlutterShadcnTabsContent>
              <FlutterShadcnTabsContent value="password">
                <FlutterShadcnCard>
                  <FlutterShadcnCardHeader>
                    <FlutterShadcnCardTitle>Password</FlutterShadcnCardTitle>
                    <FlutterShadcnCardDescription>
                      Change your password here. After saving, you'll be logged out.
                    </FlutterShadcnCardDescription>
                  </FlutterShadcnCardHeader>
                  <FlutterShadcnCardContent>
                    <div className="space-y-4">
                      <div>
                        <label className="text-sm font-medium">Current password</label>
                        <FlutterShadcnInput type="password" />
                      </div>
                      <div>
                        <label className="text-sm font-medium">New password</label>
                        <FlutterShadcnInput type="password" />
                      </div>
                      <FlutterShadcnButton>Save password</FlutterShadcnButton>
                    </div>
                  </FlutterShadcnCardContent>
                </FlutterShadcnCard>
              </FlutterShadcnTabsContent>
            </FlutterShadcnTabs>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Settings Tabs</h2>
            <FlutterShadcnTabs defaultValue="general">
              <FlutterShadcnTabsList>
                <FlutterShadcnTabsTrigger value="general">General</FlutterShadcnTabsTrigger>
                <FlutterShadcnTabsTrigger value="notifications">Notifications</FlutterShadcnTabsTrigger>
                <FlutterShadcnTabsTrigger value="security">Security</FlutterShadcnTabsTrigger>
              </FlutterShadcnTabsList>
              <FlutterShadcnTabsContent value="general">
                <div className="p-4 border rounded-lg mt-2">
                  <h3 className="font-medium mb-2">General Settings</h3>
                  <p className="text-sm text-gray-600">
                    Configure your general application settings here. This includes
                    language preferences, timezone, and display options.
                  </p>
                </div>
              </FlutterShadcnTabsContent>
              <FlutterShadcnTabsContent value="notifications">
                <div className="p-4 border rounded-lg mt-2">
                  <h3 className="font-medium mb-2">Notification Settings</h3>
                  <p className="text-sm text-gray-600">
                    Manage your notification preferences. Choose which notifications
                    you want to receive via email, push, or in-app.
                  </p>
                </div>
              </FlutterShadcnTabsContent>
              <FlutterShadcnTabsContent value="security">
                <div className="p-4 border rounded-lg mt-2">
                  <h3 className="font-medium mb-2">Security Settings</h3>
                  <p className="text-sm text-gray-600">
                    Manage your security settings including two-factor authentication,
                    session management, and connected devices.
                  </p>
                </div>
              </FlutterShadcnTabsContent>
            </FlutterShadcnTabs>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
