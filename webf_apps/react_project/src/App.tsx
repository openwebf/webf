import React, { useState } from 'react';
import './App.css';
import { Routes, Route } from '@openwebf/react-router';
import LandingPage from './Pages/LandingPage';
import ArrayBufferDemo from './Pages/ArrayBufferDemo';
import ModalPopupDemo from './Pages/ModalPopupDemo';
import Home from './Home';

function App() {
  let [inputValue, updateValue] = useState('');
  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<Home />}></Route>
        {/* <Route path="/array-buffer-demo" element={<ArrayBufferDemo />}></Route>
        <Route path="/modal-popup-demo" element={<ModalPopupDemo />} /> */}
      </Routes>
    </div>
  );
}

export default App;