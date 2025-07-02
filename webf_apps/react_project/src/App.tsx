import React, { useState } from 'react';
import './App.css';
import { Routes, Route } from '@openwebf/react-router';
import LandingPage from './Pages/LandingPage';
import ArrayBufferDemo from './Pages/ArrayBufferDemo';
import ModalPopupDemo from './Pages/ModalPopupDemo';

function App() {
  let [inputValue, updateValue] = useState('');
  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<div>
          <div
          id="target"
            style={{
              borderBottom: '1px dashed red'
            }}
          >
            test
          </div>
          {/* <LandingPage />
          <input
            type="checkbox"
            value={inputValue}
            onChange={() => console.log('checked', inputValue)}
          /> */}
        </div>}></Route>
        {/* <Route path="/array-buffer-demo" element={<ArrayBufferDemo />}></Route>
        <Route path="/modal-popup-demo" element={<ModalPopupDemo />} /> */}
      </Routes>
    </div>
  );
}

export default App;