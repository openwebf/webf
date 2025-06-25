import React from 'react';
import { useRoutes, useNavigate, useLocation } from '@openwebf/react-router';

// Page components
function Home() {
  const { navigate } = useNavigate();
  const location = useLocation();
  
  return (
    <div>
      <h1>Home Page</h1>
      <p>Current path: {location.pathname}</p>
      <button onClick={() => navigate('/about', { state: { from: 'home' } })}>
        Go to About
      </button>
    </div>
  );
}

function About() {
  const { navigate } = useNavigate();
  const location = useLocation();
  
  return (
    <div>
      <h1>About Page</h1>
      <p>Current path: {location.pathname}</p>
      {location.state?.from && (
        <p>Navigated from: {location.state.from}</p>
      )}
      <button onClick={() => navigate('/users')}>Go to Users</button>
    </div>
  );
}

function Users() {
  const { navigate } = useNavigate();
  
  return (
    <div>
      <h1>Users Page</h1>
      <p>User list would go here</p>
      <button onClick={() => navigate('/contact')}>Go to Contact</button>
    </div>
  );
}

function Contact() {
  const { navigate } = useNavigate();
  
  return (
    <div>
      <h1>Contact Page</h1>
      <p>Contact form would go here</p>
      <button onClick={() => navigate('/', { replace: true })}>
        Go Home (Replace)
      </button>
    </div>
  );
}

// Main App using useRoutes hook
export default function UseRoutesExample() {
  // Define routes as configuration objects
  const routeConfig = [
    {
      path: '/',
      element: <Home />
    },
    {
      path: '/about',
      element: <About />
    },
    {
      path: '/users',
      element: <Users />
    },
    {
      path: '/contact',
      element: <Contact />,
      prerender: true  // This route will be pre-rendered
    }
  ];
  
  // Generate route elements using useRoutes
  const routes = useRoutes(routeConfig);
  
  return (
    <div style={{ padding: '20px' }}>
      <h2>UseRoutes Example</h2>
      <p>This example demonstrates using route configuration objects instead of JSX</p>
      <hr />
      {routes}
    </div>
  );
}

// Alternative approach with dynamic route configuration
export function DynamicRoutesExample() {
  const [isAuthenticated] = React.useState(true);
  
  // Dynamic route configuration based on authentication
  const routeConfig = React.useMemo(() => {
    const baseRoutes = [
      { path: '/', element: <Home /> },
      { path: '/about', element: <About /> }
    ];
    
    if (isAuthenticated) {
      return [
        ...baseRoutes,
        { path: '/users', element: <Users /> },
        { path: '/contact', element: <Contact /> }
      ];
    }
    
    return baseRoutes;
  }, [isAuthenticated]);
  
  const routes = useRoutes(routeConfig);
  
  return (
    <div style={{ padding: '20px' }}>
      <h2>Dynamic Routes Example</h2>
      <p>Routes change based on authentication status</p>
      <hr />
      {routes}
    </div>
  );
}