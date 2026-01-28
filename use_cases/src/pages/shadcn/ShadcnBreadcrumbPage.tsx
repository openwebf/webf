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
  FlutterShadcnBreadcrumbEllipsis,
  FlutterShadcnBreadcrumbDropdown,
  FlutterShadcnBreadcrumbDropdownItem,
} from '@openwebf/react-shadcn-ui';

export const ShadcnBreadcrumbPage: React.FC = () => {
  const handleLinkClick = (path: string) => {
    console.log(`Navigate to: ${path}`);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Breadcrumb</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Breadcrumb</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                  Home
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/components')}>
                  Components
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbPage>Breadcrumb</FlutterShadcnBreadcrumbPage>
              </FlutterShadcnBreadcrumbItem>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Custom Separators</h2>
            <p className="text-sm text-gray-500 mb-3">
              Use different separator styles: slash, arrow, dash, dot, or custom text
            </p>
            <div className="space-y-4">
              <div>
                <p className="text-xs text-gray-400 mb-1">Slash separator:</p>
                <FlutterShadcnBreadcrumb separator="slash">
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                      Home
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/docs')}>
                      Docs
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbPage>Page</FlutterShadcnBreadcrumbPage>
                  </FlutterShadcnBreadcrumbItem>
                </FlutterShadcnBreadcrumb>
              </div>
              <div>
                <p className="text-xs text-gray-400 mb-1">Arrow separator:</p>
                <FlutterShadcnBreadcrumb separator="arrow">
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                      Home
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/docs')}>
                      Docs
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbPage>Page</FlutterShadcnBreadcrumbPage>
                  </FlutterShadcnBreadcrumbItem>
                </FlutterShadcnBreadcrumb>
              </div>
              <div>
                <p className="text-xs text-gray-400 mb-1">Dot separator:</p>
                <FlutterShadcnBreadcrumb separator="dot">
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                      Home
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/docs')}>
                      Docs
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbPage>Page</FlutterShadcnBreadcrumbPage>
                  </FlutterShadcnBreadcrumbItem>
                </FlutterShadcnBreadcrumb>
              </div>
              <div>
                <p className="text-xs text-gray-400 mb-1">Custom text separator:</p>
                <FlutterShadcnBreadcrumb separator="→">
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                      Home
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/docs')}>
                      Docs
                    </FlutterShadcnBreadcrumbLink>
                  </FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbItem>
                    <FlutterShadcnBreadcrumbPage>Page</FlutterShadcnBreadcrumbPage>
                  </FlutterShadcnBreadcrumbItem>
                </FlutterShadcnBreadcrumb>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Ellipsis</h2>
            <p className="text-sm text-gray-500 mb-3">
              Use ellipsis to indicate collapsed breadcrumb items
            </p>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                  Home
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbEllipsis />
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/components')}>
                  Components
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbPage>Breadcrumb</FlutterShadcnBreadcrumbPage>
              </FlutterShadcnBreadcrumbItem>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Dropdown</h2>
            <p className="text-sm text-gray-500 mb-3">
              Click the ellipsis to show a dropdown menu with hidden items
            </p>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                  Home
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbDropdown>
                  <FlutterShadcnBreadcrumbEllipsis />
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/docs')}>
                    Documentation
                  </FlutterShadcnBreadcrumbDropdownItem>
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/themes')}>
                    Themes
                  </FlutterShadcnBreadcrumbDropdownItem>
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/github')}>
                    GitHub
                  </FlutterShadcnBreadcrumbDropdownItem>
                </FlutterShadcnBreadcrumbDropdown>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/components')}>
                  Components
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbPage>Breadcrumb</FlutterShadcnBreadcrumbPage>
              </FlutterShadcnBreadcrumbItem>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">E-commerce Example</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                  Store
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/electronics')}>
                  Electronics
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/electronics/phones')}>
                  Phones
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbPage>iPhone 15 Pro</FlutterShadcnBreadcrumbPage>
              </FlutterShadcnBreadcrumbItem>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Dashboard with Dropdown</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/dashboard')}>
                  Dashboard
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbDropdown>
                  <FlutterShadcnBreadcrumbEllipsis />
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/dashboard/analytics')}>
                    Analytics
                  </FlutterShadcnBreadcrumbDropdownItem>
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/dashboard/reports')}>
                    Reports
                  </FlutterShadcnBreadcrumbDropdownItem>
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/dashboard/users')}>
                    Users
                  </FlutterShadcnBreadcrumbDropdownItem>
                </FlutterShadcnBreadcrumbDropdown>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/dashboard/settings')}>
                  Settings
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbPage>Profile</FlutterShadcnBreadcrumbPage>
              </FlutterShadcnBreadcrumbItem>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">File System Example</h2>
            <FlutterShadcnBreadcrumb>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                  Root
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbDropdown>
                  <FlutterShadcnBreadcrumbEllipsis />
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/home')}>
                    home
                  </FlutterShadcnBreadcrumbDropdownItem>
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/var')}>
                    var
                  </FlutterShadcnBreadcrumbDropdownItem>
                  <FlutterShadcnBreadcrumbDropdownItem onClick={() => handleLinkClick('/usr')}>
                    usr
                  </FlutterShadcnBreadcrumbDropdownItem>
                </FlutterShadcnBreadcrumbDropdown>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/users/john')}>
                  john
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/users/john/documents')}>
                  Documents
                </FlutterShadcnBreadcrumbLink>
              </FlutterShadcnBreadcrumbItem>
              <FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbPage>report.pdf</FlutterShadcnBreadcrumbPage>
              </FlutterShadcnBreadcrumbItem>
            </FlutterShadcnBreadcrumb>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">In Page Header</h2>
            <div className="p-4 border rounded-lg">
              <FlutterShadcnBreadcrumb>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/')}>
                    Home
                  </FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbLink onClick={() => handleLinkClick('/blog')}>
                    Blog
                  </FlutterShadcnBreadcrumbLink>
                </FlutterShadcnBreadcrumbItem>
                <FlutterShadcnBreadcrumbItem>
                  <FlutterShadcnBreadcrumbPage>Getting Started with WebF</FlutterShadcnBreadcrumbPage>
                </FlutterShadcnBreadcrumbItem>
              </FlutterShadcnBreadcrumb>
              <h1 className="text-2xl font-bold mt-4">Getting Started with WebF</h1>
              <p className="text-gray-600 mt-2">Learn how to build cross-platform apps using web technologies.</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Backwards Compatible (with List)</h2>
            <p className="text-sm text-gray-500 mb-3">
              Using the BreadcrumbList wrapper for backwards compatibility
            </p>
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
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
