import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

interface RequestResult {
  status: number;
  statusText: string;
  data: any;
  headers?: {[key: string]: string};
  duration: number;
}

export const NetworkPage: React.FC = () => {
  const [results, setResults] = useState<{[key: string]: RequestResult | string}>({});
  const [isLoading, setIsLoading] = useState<{[key: string]: boolean}>({});

  const updateResult = (key: string, result: RequestResult | string) => {
    setResults(prev => ({...prev, [key]: result}));
  };

  const setLoading = (key: string, loading: boolean) => {
    setIsLoading(prev => ({...prev, [key]: loading}));
  };

  // GET Request Example
  const testGetRequest = async () => {
    setLoading('get', true);
    const startTime = Date.now();
    try {
      const response = await fetch('https://dummyjson.com/products/1', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      const data = await response.json();
      console.log('data', data);
      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: response.status,
        statusText: response.statusText,
        data: data,
        duration
      };

      updateResult('get', result);
    } catch (error) {
      console.log('error', error);
      updateResult('get', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('get', false);
    }
  };

  // POST Request with JSON
  const testPostRequest = async () => {
    setLoading('post', true);
    const startTime = Date.now();
    try {
      const postData = {
        title: 'WebF React Demo Post',
        body: 'This is a test post from the WebF React demonstration app.',
        userId: 1,
        timestamp: new Date().toISOString()
      };

      const response = await fetch('https://dummyjson.com/products/add', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(postData)
      });

      const data = await response.json();
      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: response.status,
        statusText: response.statusText,
        data: data,
        duration
      };

      updateResult('post', result);
    } catch (error) {
      updateResult('post', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('post', false);
    }
  };

  // PUT Request Example
  const testPutRequest = async () => {
    setLoading('put', true);
    const startTime = Date.now();
    try {
      const putData = {
        title: 'Updated WebF Demo Post',
        body: 'This post has been updated using a PUT request from the WebF React demo.',
        userId: 1,
        lastModified: new Date().toISOString()
      };

      const response = await fetch('https://dummyjson.com/products/1', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(putData)
      });

      const data = await response.json();
      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: response.status,
        statusText: response.statusText,
        data: data,
        duration
      };

      updateResult('put', result);
    } catch (error) {
      updateResult('put', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('put', false);
    }
  };

  // DELETE Request Example
  const testDeleteRequest = async () => {
    setLoading('delete', true);
    const startTime = Date.now();
    try {
      const response = await fetch('https://dummyjson.com/products/1', {
        method: 'DELETE',
        headers: {
          'Accept': 'application/json'
        }
      });

      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: response.status,
        statusText: response.statusText,
        data: response.status === 200 ? 'Resource deleted successfully' : 'Deletion failed',
        duration
      };

      updateResult('delete', result);
    } catch (error) {
      updateResult('delete', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('delete', false);
    }
  };

  // FormData Request Example
  const testFormDataRequest = async () => {
    setLoading('formdata', true);
    const startTime = Date.now();
    try {
      const formData = new FormData();
      formData.append('title', 'WebF Form Data Demo');
      formData.append('description', 'Testing FormData upload from WebF React app');
      formData.append('category', 'demo');
      formData.append('timestamp', new Date().toISOString());

      // Add a simple text file
      const textFile = new Blob(['This is a demo file content from WebF React app'], { type: 'text/plain' });
      formData.append('file', textFile, 'demo.txt');

      const response = await fetch('https://postman-echo.com/post', {
        method: 'POST',
        body: formData
      });

      const data = await response.json();
      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: response.status,
        statusText: response.statusText,
        data: data,
        duration
      };

      updateResult('formdata', result);
    } catch (error) {
      updateResult('formdata', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('formdata', false);
    }
  };


  // Custom Headers Request
  const testCustomHeaders = async () => {
    setLoading('headers', true);
    const startTime = Date.now();
    try {
      const response = await fetch('https://postman-echo.com/headers', {
        method: 'GET',
        headers: {
          'X-Custom-Header': 'WebF-React-Demo',
          'X-Request-ID': `webf-${Date.now()}`,
          'X-Client-Version': '1.0.0',
          'Authorization': 'Bearer demo-token-12345',
          'User-Agent': 'WebF-React-Demo/1.0.0',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9'
        }
      });

      const data = await response.json();
      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: response.status,
        statusText: response.statusText,
        data: data,
        duration
      };

      updateResult('headers', result);
    } catch (error) {
      updateResult('headers', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('headers', false);
    }
  };

  // Concurrent Requests Example
  const testConcurrentRequests = async () => {
    setLoading('concurrent', true);
    const startTime = Date.now();
    try {
      const requests = [
        fetch('https://dummyjson.com/products/1'),
        fetch('https://dummyjson.com/products/2'),
        fetch('https://dummyjson.com/products/3'),
        fetch('https://dummyjson.com/users/1'),
        fetch('https://dummyjson.com/users/2')
      ];

      const responses = await Promise.all(requests);
      const data = await Promise.all(responses.map(r => r.json()));
      const duration = Date.now() - startTime;

      const result: RequestResult = {
        status: 200,
        statusText: 'OK',
        data: {
          totalRequests: requests.length,
          results: data,
          timing: `${requests.length} requests completed in ${duration}ms`
        },
        headers: {},
        duration
      };

      updateResult('concurrent', result);
    } catch (error) {
      updateResult('concurrent', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading('concurrent', false);
    }
  };

  const renderResult = (key: string) => {
    const result = results[key];
    if (!result) return null;

    if (typeof result === 'string') {
      return (
        <div className="mt-3 bg-surface border border-line rounded p-3">
          <div className="text-sm font-medium text-fg-primary mb-1">Result:</div>
          <div className="text-sm text-red-600">{result}</div>
        </div>
      );
    }

    return (
      <div className="mt-3">
        <div className="flex items-center justify-between text-sm mb-1">
          <div className="flex items-center gap-2">
            <span className={`px-2 py-0.5 rounded text-white text-xs font-semibold ${result.status >= 200 && result.status < 300 ? 'bg-emerald-500' : 'bg-red-500'}`}>{result.status}</span>
            <span className="text-fg-secondary">{result.statusText}</span>
          </div>
          <div className="text-fg-secondary">{result.duration}ms</div>
        </div>
        <pre className="text-sm bg-surface border border-line rounded p-2 overflow-auto">{JSON.stringify(result.data, null, 2)}</pre>
      </div>
    );
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Network Requests Showcase</h1>
          <div className="flex flex-col gap-6">
            
            {/* GET Request */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">GET Request</div>
              <div className="text-sm text-fg-secondary mb-3">Fetch data from a REST API endpoint</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.get ? 'animate-pulse' : ''}`}
                  onClick={testGetRequest}
                  disabled={isLoading.get}
                >
                  {isLoading.get ? 'Loading...' : 'Test GET Request'}
                </button>
                {renderResult('get')}
              </div>
            </div>

            {/* POST Request */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">POST Request with JSON</div>
              <div className="text-sm text-fg-secondary mb-3">Send JSON data to create a new resource</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.post ? 'animate-pulse' : ''}`}
                  onClick={testPostRequest}
                  disabled={isLoading.post}
                >
                  {isLoading.post ? 'Sending...' : 'Test POST Request'}
                </button>
                {renderResult('post')}
              </div>
            </div>

            {/* PUT Request */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">PUT Request</div>
              <div className="text-sm text-fg-secondary mb-3">Update an existing resource with new data</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.put ? 'animate-pulse' : ''}`}
                  onClick={testPutRequest}
                  disabled={isLoading.put}
                >
                  {isLoading.put ? 'Updating...' : 'Test PUT Request'}
                </button>
                {renderResult('put')}
              </div>
            </div>

            {/* DELETE Request */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">DELETE Request</div>
              <div className="text-sm text-fg-secondary mb-3">Remove a resource from the server</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-red-600 text-white hover:bg-red-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.delete ? 'animate-pulse' : ''}`}
                  onClick={testDeleteRequest}
                  disabled={isLoading.delete}
                >
                  {isLoading.delete ? 'Deleting...' : 'Test DELETE Request'}
                </button>
                {renderResult('delete')}
              </div>
            </div>

            {/* FormData Request */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">FormData Request</div>
              <div className="text-sm text-fg-secondary mb-3">Send form data including files using FormData</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.formdata ? 'animate-pulse' : ''}`}
                  onClick={testFormDataRequest}
                  disabled={isLoading.formdata}
                >
                  {isLoading.formdata ? 'Uploading...' : 'Test FormData Request'}
                </button>
                {renderResult('formdata')}
              </div>
            </div>

            {/* Custom Headers */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Custom Headers</div>
              <div className="text-sm text-fg-secondary mb-3">Send requests with custom headers for authentication and metadata</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.headers ? 'animate-pulse' : ''}`}
                  onClick={testCustomHeaders}
                  disabled={isLoading.headers}
                >
                  {isLoading.headers ? 'Sending...' : 'Test Custom Headers'}
                </button>
                {renderResult('headers')}
              </div>
            </div>

            {/* Concurrent Requests */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Concurrent Requests</div>
              <div className="text-sm text-fg-secondary mb-3">Execute multiple requests simultaneously for better performance</div>
              <div className="bg-surface border border-line rounded p-3">
                <button
                  className={`px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-60 disabled:cursor-not-allowed ${isLoading.concurrent ? 'animate-pulse' : ''}`}
                  onClick={testConcurrentRequests}
                  disabled={isLoading.concurrent}
                >
                  {isLoading.concurrent ? 'Processing...' : 'Test Concurrent Requests'}
                </button>
                {renderResult('concurrent')}
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
