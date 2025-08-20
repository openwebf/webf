import React from 'react';
import {
  Router,
  Routes,
  Route,
  Link,
  useNavigate,
  useLocation,
  useParams,
  WebFRouterLink
} from '@openwebf/react-router';

// Navigation component that appears on all pages
function Navigation() {
  const location = useLocation();
  
  return (
    <nav>
      <ul>
        <li className={location.pathname === '/' ? 'active' : ''}>
          <Link to="/">Home</Link>
        </li>
        <li className={location.pathname === '/about' ? 'active' : ''}>
          <Link to="/about">About</Link>
        </li>
        <li className={location.pathname === '/users' ? 'active' : ''}>
          <Link to="/users">Users</Link>
        </li>
        <li className={location.pathname === '/contact' ? 'active' : ''}>
          <Link to="/contact">Contact</Link>
        </li>
      </ul>
    </nav>
  );
}

// Home component
function Home() {
  const navigate = useNavigate();

  const handleNavigate = () => {
    navigate('/about', { state: { from: 'home' } });
  };

  return (
    <div>
      <Navigation />
      <h1>Home</h1>
      <p>Welcome to the home page!</p>
      <button onClick={handleNavigate}>Go to About (programmatically)</button>
    </div>
  );
}

// About component
function About() {
  const location = useLocation();
  
  return (
    <div>
      <Navigation />
      <h1>About</h1>
      <p>This is the about page.</p>
      {location.state?.from && (
        <p>You came from: {location.state.from}</p>
      )}
    </div>
  );
}

// User profile component
function UserProfile() {
  const { id } = useParams<{ id: string }>();
  
  return (
    <div>
      <h2>User Profile</h2>
      <p>User ID: {id}</p>
    </div>
  );
}

// Users component
function Users() {
  return (
    <div>
      <Navigation />
      <h1>Users</h1>
      <nav>
        <ul>
          <li><Link to="/users/1">User 1</Link></li>
          <li><Link to="/users/2">User 2</Link></li>
          <li><Link to="/users/3">User 3</Link></li>
        </ul>
      </nav>
      {/* Note: Nested routes in WebF need separate WebFRouterLink elements */}
    </div>
  );
}

// Contact component
function Contact() {
  const navigate = useNavigate();

  const handleReplace = () => {
    navigate('/', { replace: true });
  };

  return (
    <div>
      <Navigation />
      <h1>Contact</h1>
      <p>Contact us at: example@email.com</p>
      <button onClick={handleReplace}>
        Replace with Home (won't add to history)
      </button>
    </div>
  );
}

// Not Found component
function NotFound() {
  return (
    <div>
      <Navigation />
      <h1>404 - Not Found</h1>
      <p>The page you're looking for doesn't exist.</p>
      <Link to="/">Go back to Home</Link>
    </div>
  );
}

// Main App component - WebF pattern
export default function AppWebFPattern() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/users" element={<Users />} />
        <Route path="/users/:id" element={<UserProfile />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  );
}

// Alternative: Direct WebFRouterLink usage (similar to react_project example)
export function AppDirectWebFRouterLink() {
  return (
    <Router>
      <div className="App">
        <WebFRouterLink path="/">
          <Home />
        </WebFRouterLink>
        <WebFRouterLink path="/about">
          <About />
        </WebFRouterLink>
        <WebFRouterLink path="/users">
          <Users />
        </WebFRouterLink>
        <WebFRouterLink path="/users/1">
          <UserProfile />
        </WebFRouterLink>
        <WebFRouterLink path="/users/2">
          <UserProfile />
        </WebFRouterLink>
        <WebFRouterLink path="/users/3">
          <UserProfile />
        </WebFRouterLink>
        <WebFRouterLink path="/contact">
          <Contact />
        </WebFRouterLink>
      </div>
    </Router>
  );
}