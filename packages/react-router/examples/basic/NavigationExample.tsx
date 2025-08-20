import React from 'react';
import { Routes, Route, useNavigate, useRouteContext, useLocation } from '@openwebf/react-router';

// Navigation Menu component
function NavigationMenu() {
  const { navigate, canPop, pop } = useNavigate();
  const location = useLocation();
  
  const handleBack = () => {
    if (canPop()) {
      pop();
    } else {
      console.log('Cannot go back, already at root');
    }
  };
  
  return (
    <nav style={{ padding: '10px', borderBottom: '1px solid #ccc' }}>
      <h3>Current Path: {location.pathname}</h3>
      <button onClick={() => navigate('/')}>Home</button>
      <button onClick={() => navigate('/about')}>About</button>
      <button onClick={() => navigate('/contact')}>Contact</button>
      <button onClick={handleBack} disabled={!canPop()}>
        Back {!canPop() && '(disabled)'}
      </button>
    </nav>
  );
}

// Home page
function HomePage() {
  const { navigate, popAndPush, pushAndRemoveUntil } = useNavigate();
  
  const handleNavigateWithState = () => {
    navigate('/about', { 
      state: { 
        message: 'Hello from Home!',
        timestamp: new Date().toISOString()
      }
    });
  };
  
  const handlePopAndPush = async () => {
    await popAndPush('/contact', { from: 'home-pop-push' });
  };
  
  const handlePushAndRemoveUntil = async () => {
    // Push contact and remove all routes until home
    await pushAndRemoveUntil('/contact', '/', { cleared: true });
  };
  
  return (
    <div>
      <NavigationMenu />
      <h1>Home Page</h1>
      <p>Welcome to the home page!</p>
      <button onClick={handleNavigateWithState}>
        Go to About with State
      </button>
      <button onClick={handlePopAndPush}>
        Pop & Push to Contact
      </button>
      <button onClick={handlePushAndRemoveUntil}>
        Push Contact & Clear History
      </button>
    </div>
  );
}

// About page
function AboutPage() {
  const { navigate, popUntil, maybePop } = useNavigate();
  const location = useLocation();
  
  const handleReplaceNavigation = () => {
    navigate('/contact', { 
      replace: true,
      state: { replacedFrom: 'about' }
    });
  };
  
  const handlePopToHome = () => {
    popUntil('/');
  };
  
  const handleMaybePop = () => {
    const popped = maybePop({ message: 'Going back from About' });
    if (!popped) {
      console.log('Could not pop - no previous route');
    }
  };
  
  return (
    <div>
      <NavigationMenu />
      <h1>About Page</h1>
      <p>Learn more about us!</p>
      
      {location.state?.message && (
        <div style={{ padding: '10px', background: '#f0f0f0' }}>
          <p>Received state from location:</p>
          <pre>{JSON.stringify(location.state, null, 2)}</pre>
        </div>
      )}
      
      <button onClick={handleReplaceNavigation}>
        Replace with Contact (no back history)
      </button>
      <button onClick={handlePopToHome}>
        Pop Until Home
      </button>
      <button onClick={handleMaybePop}>
        Maybe Pop (safe back)
      </button>
    </div>
  );
}

// Contact page
function ContactPage() {
  const navigate = useNavigate();
  const { params } = useRouteContext();
  
  return (
    <div>
      <NavigationMenu />
      <h1>Contact Page</h1>
      <p>Get in touch with us!</p>
      
      {params?.replacedFrom && (
        <p style={{ color: 'blue' }}>
          You were redirected from: {params.replacedFrom}
        </p>
      )}
      
      <div style={{ marginTop: '20px' }}>
        <button onClick={() => navigate('/')}>Go Home</button>
        <button onClick={() => navigate('/about', { state: { from: 'contact' } })}>
          Go to About with State
        </button>
      </div>
    </div>
  );
}

// Main App with navigation examples
export default function NavigationExample() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/about" element={<AboutPage />} />
      <Route path="/contact" element={<ContactPage />} />
    </Routes>
  );
}