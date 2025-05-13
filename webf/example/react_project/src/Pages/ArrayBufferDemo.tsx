import React, { useState } from 'react';

export default function ArrayBufferDemo() {
  const [status, setStatus] = useState('');
  const [loading, setLoading] = useState(false);

  const handleUpload = async () => {
    try {
      setLoading(true);
      setStatus('Fetching image...');
      
      // Fetch the test image as ArrayBuffer
      const response = await fetch('http://andycall.oss-cn-beijing.aliyuncs.com/images/cat.png');
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = new Uint8Array([]);
      const arrayBuffer = data.buffer;
      
      // const buffer = await response.arrayBuffer();
      setStatus('Image fetched! Size: ' + arrayBuffer.byteLength + ' bytes');
      
      // Send the ArrayBuffer to the Dart module
      // @ts-ignore
      const result = await window.webf.invokeModuleAsync('TestBlob', 'uploadFile', arrayBuffer);
      
      setStatus('Upload success! Response: ' + result);
    } catch (error) {
      console.error('Error:', error);
      setStatus('Error: ' + (error instanceof Error ? error.message : String(error)));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="array-buffer-demo">
      <h1>ArrayBuffer Demo</h1>
      
      <div className="demo-container">
        <img src="/assets/test-bl.png" alt="Test image" className="test-image" />
        
        <button 
          className="upload-button" 
          onClick={handleUpload}
          disabled={loading}
        >
          {loading ? 'Processing...' : 'Upload Image using ArrayBuffer'}
        </button>
        
        {status && <p className="status-message">{status}</p>}
      </div>
    </div>
  );
}