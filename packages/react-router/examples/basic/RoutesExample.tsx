import React from 'react';
import { Routes, Route, useRouteData, useRouteConfig, useRouteContext, useNavigate } from '@openwebf/react-router';

// Shared user context type
interface UserContext {
  user: {
    id: string;
    name: string;
    role: string;
  };
  theme: 'light' | 'dark';
}

// Home component using shared route data and route context
function Home() {
  const { user, theme } = useRouteData<UserContext>();
  const { path, params } = useRouteContext();
  
  return (
    <div style={{ background: theme === 'dark' ? '#333' : '#fff', color: theme === 'dark' ? '#fff' : '#333' }}>
      <h1>Welcome {user.name}!</h1>
      <p>Current path: {path}</p>
      <p>Your role: {user.role}</p>
      {params && <p>Route params: {JSON.stringify(params)}</p>}
    </div>
  );
}

// Profile component using shared route data
function Profile() {
  const { user, theme } = useRouteData<UserContext>();
  const config = useRouteConfig();
  
  return (
    <div style={{ 
      background: theme === 'dark' ? '#333' : '#fff', 
      color: theme === 'dark' ? '#fff' : '#333',
      transition: config.enableTransitions ? `all ${config.transitionDuration}ms` : 'none'
    }}>
      <h1>User Profile</h1>
      <p>ID: {user.id}</p>
      <p>Name: {user.name}</p>
      <p>Role: {user.role}</p>
    </div>
  );
}

// Settings component using shared route data and navigation
function Settings() {
  const { theme } = useRouteData<UserContext>();
  const navigate = useNavigate();
  
  const handleNavigateToProfile = () => {
    navigate('/profile', { state: { from: 'settings' } });
  };
  
  const handleNavigateHome = () => {
    navigate('/', { replace: true });
  };
  
  const handleGoBack = () => {
    navigate(-1);
  };
  
  return (
    <div style={{ background: theme === 'dark' ? '#333' : '#fff', color: theme === 'dark' ? '#fff' : '#333' }}>
      <h1>Settings</h1>
      <p>Current theme: {theme}</p>
      <p>Configure your preferences here</p>
      
      <div style={{ marginTop: '20px' }}>
        <button onClick={handleNavigateToProfile}>Go to Profile</button>
        <button onClick={handleNavigateHome}>Replace with Home</button>
        <button onClick={handleGoBack}>Go Back</button>
      </div>
    </div>
  );
}

// Main App component demonstrating Routes with shared context
export default function RoutesExample() {
  // Simulated user data and theme
  const currentUser = {
    id: '123',
    name: 'John Doe',
    role: 'admin'
  };
  
  const currentTheme: 'light' | 'dark' = 'light';
  
  // Shared data that all routes can access
  const sharedData: UserContext = {
    user: currentUser,
    theme: currentTheme
  };
  
  // Route configuration
  const routeConfig = {
    enableTransitions: true,
    transitionDuration: 300
  };
  
  return (
    <Routes sharedData={sharedData} config={routeConfig}>
      <Route path="/" element={<Home />} />
      <Route path="/profile" element={<Profile />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  );
}