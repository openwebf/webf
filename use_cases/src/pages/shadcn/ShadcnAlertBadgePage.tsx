import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnAlert,
  FlutterShadcnAlertTitle,
  FlutterShadcnAlertDescription,
  FlutterShadcnBadge,
} from '@openwebf/react-shadcn-ui';

export const ShadcnAlertBadgePage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Alert & Badge</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Alerts</h2>
            <div className="space-y-4">
              <FlutterShadcnAlert>
                <FlutterShadcnAlertTitle>Default Alert</FlutterShadcnAlertTitle>
                <FlutterShadcnAlertDescription>
                  This is a default alert. You can add any message here.
                </FlutterShadcnAlertDescription>
              </FlutterShadcnAlert>

              <FlutterShadcnAlert variant="destructive">
                <FlutterShadcnAlertTitle>Error</FlutterShadcnAlertTitle>
                <FlutterShadcnAlertDescription>
                  Your session has expired. Please log in again.
                </FlutterShadcnAlertDescription>
              </FlutterShadcnAlert>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Alert Examples</h2>
            <div className="space-y-4">
              <FlutterShadcnAlert>
                <FlutterShadcnAlertTitle>Heads up!</FlutterShadcnAlertTitle>
                <FlutterShadcnAlertDescription>
                  You can add components and dependencies to your app using the cli.
                </FlutterShadcnAlertDescription>
              </FlutterShadcnAlert>

              <FlutterShadcnAlert variant="destructive">
                <FlutterShadcnAlertTitle>Delete Account</FlutterShadcnAlertTitle>
                <FlutterShadcnAlertDescription>
                  This action cannot be undone. This will permanently delete your account and remove your data from our servers.
                </FlutterShadcnAlertDescription>
              </FlutterShadcnAlert>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Badges</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnBadge>Default</FlutterShadcnBadge>
              <FlutterShadcnBadge variant="secondary">Secondary</FlutterShadcnBadge>
              <FlutterShadcnBadge variant="destructive">Destructive</FlutterShadcnBadge>
              <FlutterShadcnBadge variant="outline">Outline</FlutterShadcnBadge>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Badge Use Cases</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-2">
                <span className="text-sm">Status:</span>
                <FlutterShadcnBadge>Active</FlutterShadcnBadge>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm">Priority:</span>
                <FlutterShadcnBadge variant="destructive">High</FlutterShadcnBadge>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm">Version:</span>
                <FlutterShadcnBadge variant="outline">v1.0.0</FlutterShadcnBadge>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm">Category:</span>
                <FlutterShadcnBadge variant="secondary">Documentation</FlutterShadcnBadge>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Badges in Context</h2>
            <div className="space-y-3 p-4 border rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium">Authentication</p>
                  <p className="text-sm text-gray-500">User login and registration</p>
                </div>
                <FlutterShadcnBadge>Completed</FlutterShadcnBadge>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium">Dashboard</p>
                  <p className="text-sm text-gray-500">Analytics and reporting</p>
                </div>
                <FlutterShadcnBadge variant="secondary">In Progress</FlutterShadcnBadge>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium">Payment</p>
                  <p className="text-sm text-gray-500">Stripe integration</p>
                </div>
                <FlutterShadcnBadge variant="outline">Pending</FlutterShadcnBadge>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium">Security Audit</p>
                  <p className="text-sm text-gray-500">Critical vulnerability found</p>
                </div>
                <FlutterShadcnBadge variant="destructive">Urgent</FlutterShadcnBadge>
              </div>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
