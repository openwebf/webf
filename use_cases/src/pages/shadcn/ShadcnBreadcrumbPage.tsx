import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnBreadcrumb,
  FlutterShadcnBreadcrumbList,
  FlutterShadcnBreadcrumbItem,
  FlutterShadcnBreadcrumbLink,
  FlutterShadcnBreadcrumbPage,
  FlutterShadcnBreadcrumbSeparator,
} from '@openwebf/react-shadcn-ui';

export const ShadcnBreadcrumbPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Breadcrumb</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Breadcrumb</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbList>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/">Home</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/components">Components</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbPage>Breadcrumb</FlutterShadcnBreadcrumbPage>
                </FlutterShadcnBreadcrumbItem>
              </FlutterShadcnBreadcrumbList>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">E-commerce Example</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbList>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/">Store</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/electronics">Electronics</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/electronics/phones">Phones</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbPage>iPhone 15 Pro</FlutterShadcnBreadcrumbPage>
                </FlutterShadcnBreadcrumbItem>
              </FlutterShadcnBreadcrumbList>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Dashboard Example</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbList>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/dashboard">Dashboard</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/dashboard/settings">Settings</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbPage>Profile</FlutterShadcnBreadcrumbPage>
                </FlutterShadcnBreadcrumbItem>
              </FlutterShadcnBreadcrumbList>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">File System Example</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbList>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/">Root</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/users">Users</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/users/john">john</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink href="/users/john/documents">Documents</FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbSeparator />
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbPage>report.pdf</FlutterShadcnBreadcrumbPage>
                </FlutterShadcnBreadcrumbItem>
              </FlutterShadcnBreadcrumbList>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">In Page Header</h2>
            <div className="p-4 border rounded-lg">
              <FlutterShadcnBreadcrumb>
                <FlutterShadcnBreadcrumbList>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink href="/">Home</FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbSeparator />
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink href="/blog">Blog</FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbSeparator />
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbPage>Getting Started with WebF</FlutterShadcnBreadcrumbPage>
                  </FlutterShadcnBreadcrumbItem>
                </FlutterShadcnBreadcrumbList>
              </FlutterShadcnBreadcrumb>
              <h1 className="text-2xl font-bold mt-4">Getting Started with WebF</h1>
              <p className="text-gray-600 mt-2">Learn how to build cross-platform apps using web technologies.</p>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
