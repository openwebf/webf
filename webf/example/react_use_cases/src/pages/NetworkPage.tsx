import React, { useState, useRef } from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './NetworkPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

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
  const fileInputRef = useRef<HTMLInputElement>(null);

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
      const response = await fetch('https://jsonplaceholder.typicode.com/posts/1', {
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

      const response = await fetch('https://jsonplaceholder.typicode.com/posts', {
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
        id: 1,
        title: 'Updated WebF Demo Post',
        body: 'This post has been updated using a PUT request from the WebF React demo.',
        userId: 1,
        lastModified: new Date().toISOString()
      };

      const response = await fetch('https://jsonplaceholder.typicode.com/posts/1', {
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
      const response = await fetch('https://jsonplaceholder.typicode.com/posts/1', {
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

      const response = await fetch('https://httpbin.org/post', {
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
      const response = await fetch('https://httpbin.org/headers', {
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
        fetch('https://jsonplaceholder.typicode.com/posts/1'),
        fetch('https://jsonplaceholder.typicode.com/posts/2'),
        fetch('https://jsonplaceholder.typicode.com/posts/3'),
        fetch('https://jsonplaceholder.typicode.com/users/1'),
        fetch('https://jsonplaceholder.typicode.com/users/2')
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
        <div className={styles.resultContainer}>
          <div className={styles.resultLabel}>Result:</div>
          <div className={styles.errorText}>{result}</div>
        </div>
      );
    }

    return (
      <div className={styles.resultContainer}>
        <div className={styles.resultMeta}>
          <div className={styles.statusBadge}>
            <span className={`${styles.statusCode} ${result.status >= 200 && result.status < 300 ? styles.success : styles.error}`}>
              {result.status}
            </span>
            <span className={styles.statusText}>{result.statusText}</span>
          </div>
          <div className={styles.duration}>{result.duration}ms</div>
        </div>
        <div className={styles.resultData}>
          <pre>{JSON.stringify(result.data, null, 2)}</pre>
        </div>
      </div>
    );
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Network Requests Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* GET Request */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>GET Request</div>
              <div className={styles.itemDesc}>Fetch data from a REST API endpoint</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isLoading.get ? styles.loading : ''}`}
                  onClick={testGetRequest}
                  disabled={isLoading.get}
                >
                  {isLoading.get ? 'Loading...' : 'Test GET Request'}
                </button>
                {renderResult('get')}
              </div>
            </div>

            {/* POST Request */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>POST Request with JSON</div>
              <div className={styles.itemDesc}>Send JSON data to create a new resource</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isLoading.post ? styles.loading : ''}`}
                  onClick={testPostRequest}
                  disabled={isLoading.post}
                >
                  {isLoading.post ? 'Sending...' : 'Test POST Request'}
                </button>
                {renderResult('post')}
              </div>
            </div>

            {/* PUT Request */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>PUT Request</div>
              <div className={styles.itemDesc}>Update an existing resource with new data</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isLoading.put ? styles.loading : ''}`}
                  onClick={testPutRequest}
                  disabled={isLoading.put}
                >
                  {isLoading.put ? 'Updating...' : 'Test PUT Request'}
                </button>
                {renderResult('put')}
              </div>
            </div>

            {/* DELETE Request */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>DELETE Request</div>
              <div className={styles.itemDesc}>Remove a resource from the server</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${styles.deleteButton} ${isLoading.delete ? styles.loading : ''}`}
                  onClick={testDeleteRequest}
                  disabled={isLoading.delete}
                >
                  {isLoading.delete ? 'Deleting...' : 'Test DELETE Request'}
                </button>
                {renderResult('delete')}
              </div>
            </div>

            {/* FormData Request */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>FormData Request</div>
              <div className={styles.itemDesc}>Send form data including files using FormData</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isLoading.formdata ? styles.loading : ''}`}
                  onClick={testFormDataRequest}
                  disabled={isLoading.formdata}
                >
                  {isLoading.formdata ? 'Uploading...' : 'Test FormData Request'}
                </button>
                {renderResult('formdata')}
              </div>
            </div>

            {/* Custom Headers */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Headers</div>
              <div className={styles.itemDesc}>Send requests with custom headers for authentication and metadata</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isLoading.headers ? styles.loading : ''}`}
                  onClick={testCustomHeaders}
                  disabled={isLoading.headers}
                >
                  {isLoading.headers ? 'Sending...' : 'Test Custom Headers'}
                </button>
                {renderResult('headers')}
              </div>
            </div>

            {/* Concurrent Requests */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Concurrent Requests</div>
              <div className={styles.itemDesc}>Execute multiple requests simultaneously for better performance</div>
              <div className={styles.actionContainer}>
                <button 
                  className={`${styles.actionButton} ${isLoading.concurrent ? styles.loading : ''}`}
                  onClick={testConcurrentRequests}
                  disabled={isLoading.concurrent}
                >
                  {isLoading.concurrent ? 'Processing...' : 'Test Concurrent Requests'}
                </button>
                {renderResult('concurrent')}
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};