import React from 'react';
import {
  BrowserRouter,
  Routes,
  Route,
  Link,
  useNavigate,
  useLocation
} from '@openwebf/react-router';

function Navigation() {
  const location = useLocation();
  
  return (
    <nav style={{ marginBottom: '20px' }}>
      <Link to="/" style={{ marginRight: '10px', fontWeight: location.pathname === '/' ? 'bold' : 'normal' }}>
        Home
      </Link>
      <Link to="/about" style={{ marginRight: '10px', fontWeight: location.pathname === '/about' ? 'bold' : 'normal' }}>
        About
      </Link>
      <Link to="/contact" style={{ fontWeight: location.pathname === '/contact' ? 'bold' : 'normal' }}>
        Contact
      </Link>
    </nav>
  );
}

function Home() {
  const navigate = useNavigate();
  
  return (
    <div>
      <h1>Home Page</h1>
      <p>Welcome to the home page!</p>
      <button onClick={() => navigate('/about', { state: { from: 'home' } })}>
        Go to About (with state)
      </button>
    </div>
  );
}

function About() {
  const location = useLocation();
  const navigate = useNavigate();
  
  return (
    <div>
      <h1>About Page</h1>
      <p>This is the about page.</p>
      {location.state?.from && (
        <p>You came from: {location.state.from}</p>
      )}
      <button onClick={() => navigate(-1)}>Go Back</button>
    </div>
  );
}

function Contact() {
  const navigate = useNavigate();
  
  return (
    <div>
      <h1>Contact Page</h1>
      <p>Contact us at: example@email.com</p>
      <button onClick={() => navigate('/', { replace: true })}>
        Go to Home (replace)
      </button>
    </div>
  );
}

export default function SimpleApp() {
  return (
    <BrowserRouter>
      <div style={{ padding: '20px' }}>
        <Navigation />
        
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}