import React, { MouseEventHandler, useState } from 'react';
import logo from './logo.svg';
import './App.css';
import { WebFRouterLink } from './CustomElements/RouterLink';
import { WebFTouchArea } from './CustomElements/WebFTouchArea';
import Home from './Pages/Home';

function App() {
  return (
    <div className="App">
      <WebFRouterLink path="/home">
        <div>This is Home</div>
        <WebFTouchArea
          onTouchStart={(e) => console.log('touchstart', e.target.outerHTML)}
          onTouchMove={(e) => console.log('touch move')}
          onTouchEnd={(e) => console.log('touchend')}
        >
          <div>Touch Here</div>
        </WebFTouchArea>
      </WebFRouterLink>
      <WebFRouterLink path="/page">
        <div>This is Page</div>
      </WebFRouterLink>
    </div>
  );
}

export default App;
