import React, { MouseEventHandler, useState } from 'react';
import logo from './logo.svg';
import './App.css';
import { createComponent } from './utils/CreateComponent';

// interface FlutterCupertinoButtonProps {
//   onClick: MouseEventHandler<HTMLUnknownElement>;
//   size: 'small' | 'large';
// }

// const FlutterCupertinoButton = createComponent({
//   tagName: 'flutter-cupertino-button',
//   displayName: 'FlutterCupertinoButton',
//   events: {
//     onClick: 'click'
//   }
// }) as React.ComponentType<FlutterCupertinoButtonProps & { children?: React.ReactNode; ref?: React.Ref<HTMLUnknownElement> }>

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
