import React, { useState } from 'react';
import './App.css';
import { WebFRouterLink } from './CustomElements/RouterLink';
import LandingPage from './Pages/LandingPage';
import ArrayBufferDemo from './Pages/ArrayBufferDemo';
import ModalPopupDemo from './Pages/ModalPopupDemo';

function App() {
  let [inputValue, updateValue] = useState('');
  return (
    <div className="App">
      <WebFRouterLink path="/">
        <LandingPage />
        <input
        type="checkbox"
          value={inputValue}
          onChange={() => console.log('checked', inputValue)}
        />
      </WebFRouterLink>
      <WebFRouterLink path="/array-buffer-demo">
        <ArrayBufferDemo />
      </WebFRouterLink>
      <WebFRouterLink path="/modal-popup-demo">
        <ModalPopupDemo />
      </WebFRouterLink>
      <WebFRouterLink path="/flutter">

      </WebFRouterLink>
    </div>
  );
}

export default App;