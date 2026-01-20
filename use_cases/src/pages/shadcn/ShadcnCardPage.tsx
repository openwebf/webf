import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnCard,
  FlutterShadcnCardHeader,
  FlutterShadcnCardTitle,
  FlutterShadcnCardDescription,
  FlutterShadcnCardContent,
  FlutterShadcnCardFooter,
  FlutterShadcnButton,
  FlutterShadcnInput,
} from '@openwebf/react-shadcn-ui';

export const ShadcnCardPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-gray-50">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Cards</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Card</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <FlutterShadcnCardTitle>Card Title</FlutterShadcnCardTitle>
                <FlutterShadcnCardDescription>
                  This is a basic card with a title and description.
                </FlutterShadcnCardDescription>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <p>Card content goes here. You can put any content inside the card.</p>
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Card with Footer</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <FlutterShadcnCardTitle>Create Project</FlutterShadcnCardTitle>
                <FlutterShadcnCardDescription>
                  Deploy your new project in one-click.
                </FlutterShadcnCardDescription>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium">Name</label>
                    <FlutterShadcnInput placeholder="Project name" />
                  </div>
                  <div>
                    <label className="text-sm font-medium">Description</label>
                    <FlutterShadcnInput placeholder="Project description" />
                  </div>
                </div>
              </FlutterShadcnCardContent>
              <FlutterShadcnCardFooter>
                <div className="flex justify-between w-full">
                  <FlutterShadcnButton variant="outline">Cancel</FlutterShadcnButton>
                  <FlutterShadcnButton>Create</FlutterShadcnButton>
                </div>
              </FlutterShadcnCardFooter>
            </FlutterShadcnCard>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Notification Card</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <FlutterShadcnCardTitle>Notifications</FlutterShadcnCardTitle>
                <FlutterShadcnCardDescription>
                  You have 3 unread messages.
                </FlutterShadcnCardDescription>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 p-2 bg-gray-50 rounded">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">New message from John</p>
                      <p className="text-xs text-gray-500">2 minutes ago</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 p-2 bg-gray-50 rounded">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Your order has shipped</p>
                      <p className="text-xs text-gray-500">1 hour ago</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 p-2 bg-gray-50 rounded">
                    <div className="w-2 h-2 bg-gray-300 rounded-full"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Meeting reminder</p>
                      <p className="text-xs text-gray-500">Yesterday</p>
                    </div>
                  </div>
                </div>
              </FlutterShadcnCardContent>
              <FlutterShadcnCardFooter>
                <FlutterShadcnButton variant="outline" className="w-full">
                  Mark all as read
                </FlutterShadcnButton>
              </FlutterShadcnCardFooter>
            </FlutterShadcnCard>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Card Grid</h2>
            <div className="grid grid-cols-2 gap-4">
              <FlutterShadcnCard>
                <FlutterShadcnCardHeader>
                  <FlutterShadcnCardTitle>Total Revenue</FlutterShadcnCardTitle>
                </FlutterShadcnCardHeader>
                <FlutterShadcnCardContent>
                  <p className="text-2xl font-bold">$45,231.89</p>
                  <p className="text-xs text-green-500">+20.1% from last month</p>
                </FlutterShadcnCardContent>
              </FlutterShadcnCard>
              <FlutterShadcnCard>
                <FlutterShadcnCardHeader>
                  <FlutterShadcnCardTitle>Active Users</FlutterShadcnCardTitle>
                </FlutterShadcnCardHeader>
                <FlutterShadcnCardContent>
                  <p className="text-2xl font-bold">+2350</p>
                  <p className="text-xs text-green-500">+180.1% from last month</p>
                </FlutterShadcnCardContent>
              </FlutterShadcnCard>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
