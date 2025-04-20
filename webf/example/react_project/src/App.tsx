import React from 'react';
import './App.css';
import { WebFRouterLink } from './CustomElements/RouterLink';
import LandingPage from './Pages/LandingPage';
import ArrayBufferDemo from './Pages/ArrayBufferDemo';

function App() {
  return (
    <div className="App">
      <WebFRouterLink path="/">
        <LandingPage />
      </WebFRouterLink>
      <WebFRouterLink path="/array-buffer-demo">
        <ArrayBufferDemo />
      </WebFRouterLink>
    </div>
  );
}

export default App;