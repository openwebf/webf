import React from 'react';
import {
  Router,
  useRoutes,
  Link,
  Outlet,
  RouteConfig
} from '@openwebf/react-router';

// Import components from App.tsx
import {
  Home,
  About,
  Users,
  UserProfile,
  Contact,
  NotFound,
  Layout
} from './App';

// Define routes configuration
const routes: RouteConfig[] = [
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        path: '/',
        element: <Home />
      },
      {
        path: '/about',
        element: <About />
      },
      {
        path: '/users',
        element: <Users />,
        children: [
          {
            path: '/users/:id',
            element: <UserProfile />
          }
        ]
      },
      {
        path: '/contact',
        element: <Contact />
      },
      {
        path: '*',
        element: <NotFound />
      }
    ]
  }
];

// App content using useRoutes
function AppContent() {
  const element = useRoutes(routes);
  return element;
}

// Main App component with useRoutes
export default function AppWithUseRoutes() {
  return (
    <Router>
      <AppContent />
    </Router>
  );
}