import React from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <div className="relative" onClick={() => console.log('clicked')}>
        <img
          alt="Video Thumbnail"
          className="border-border-secondary max-w-[299px] max-h-[160px] w-auto h-auto object-contain rounded-lg border"
          src={'http://andycall.oss-accelerate.aliyuncs.com/images/loading.png'}
        />
        <div className="w-full h-full absolute flex items-center justify-center top-0">
          <span>Icon</span>
        </div>
      </div>
    </div>
  );
}

export default App;
