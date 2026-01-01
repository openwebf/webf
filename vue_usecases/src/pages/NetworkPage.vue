<script setup lang="ts">
import { reactive } from 'vue';

interface RequestResult {
  status: number;
  statusText: string;
  data: any;
  headers?: { [key: string]: string };
  duration: number;
}

const results = reactive<Record<string, RequestResult | string | undefined>>({});
const isLoading = reactive<Record<string, boolean | undefined>>({});

function updateResult(key: string, result: RequestResult | string) {
  results[key] = result;
}

function setLoading(key: string, loading: boolean) {
  isLoading[key] = loading;
}

function parseXHRHeaders(headerString: string): Record<string, string> {
  const headers: Record<string, string> = {};
  for (const line of headerString.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    const colonIndex = trimmed.indexOf(':');
    if (colonIndex < 0) continue;
    const key = trimmed.slice(0, colonIndex).trim();
    const value = trimmed.slice(colonIndex + 1).trim();
    if (!key) continue;
    headers[key] = value;
  }
  return headers;
}

async function testGetRequest() {
  setLoading('get', true);
  const startTime = Date.now();
  try {
    const response = await fetch('https://dummyjson.com/products/1', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    });
    const data = await response.json();
    updateResult('get', {
      status: response.status,
      statusText: response.statusText,
      data,
      duration: Date.now() - startTime,
    });
  } catch (error) {
    updateResult('get', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('get', false);
  }
}

async function testPostRequest() {
  setLoading('post', true);
  const startTime = Date.now();
  try {
    const postData = {
      title: 'WebF Vue Demo Post',
      body: 'This is a test post from the WebF Vue demonstration app.',
      userId: 1,
      timestamp: new Date().toISOString(),
    };

    const response = await fetch('https://dummyjson.com/products/add', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(postData),
    });

    const data = await response.json();
    updateResult('post', {
      status: response.status,
      statusText: response.statusText,
      data,
      duration: Date.now() - startTime,
    });
  } catch (error) {
    updateResult('post', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('post', false);
  }
}

async function testPutRequest() {
  setLoading('put', true);
  const startTime = Date.now();
  try {
    const putData = {
      title: 'Updated WebF Demo Post',
      body: 'This post has been updated using a PUT request from the WebF Vue demo.',
      userId: 1,
      lastModified: new Date().toISOString(),
    };

    const response = await fetch('https://dummyjson.com/products/1', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(putData),
    });

    const data = await response.json();
    updateResult('put', {
      status: response.status,
      statusText: response.statusText,
      data,
      duration: Date.now() - startTime,
    });
  } catch (error) {
    updateResult('put', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('put', false);
  }
}

async function testDeleteRequest() {
  setLoading('delete', true);
  const startTime = Date.now();
  try {
    const response = await fetch('https://dummyjson.com/products/1', {
      method: 'DELETE',
      headers: { Accept: 'application/json' },
    });

    updateResult('delete', {
      status: response.status,
      statusText: response.statusText,
      data: response.status === 200 ? 'Resource deleted successfully' : 'Deletion failed',
      duration: Date.now() - startTime,
    });
  } catch (error) {
    updateResult('delete', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('delete', false);
  }
}

async function testXHRRequest() {
  setLoading('xhr', true);
  const startTime = Date.now();
  try {
    const result = await new Promise<RequestResult>((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', 'https://dummyjson.com/products/1');
      xhr.setRequestHeader('Accept', 'application/json');

      xhr.onreadystatechange = () => {
        if (xhr.readyState !== XMLHttpRequest.DONE) return;
        const duration = Date.now() - startTime;
        const status = xhr.status;
        const statusText = xhr.statusText || (status >= 200 && status < 300 ? 'OK' : 'Error');
        const headers = parseXHRHeaders(xhr.getAllResponseHeaders() || '');

        let data: unknown = xhr.responseText;
        try {
          data = JSON.parse(xhr.responseText);
        } catch {
          // keep raw responseText
        }

        resolve({
          status,
          statusText,
          data,
          headers,
          duration,
        });
      };

      xhr.onerror = () => reject(new Error('Network error'));
      xhr.onabort = () => reject(new Error('Request aborted'));
      xhr.send();
    });

    updateResult('xhr', result);
  } catch (error) {
    updateResult('xhr', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('xhr', false);
  }
}

async function testFormDataRequest() {
  setLoading('formdata', true);
  const startTime = Date.now();
  try {
    const formData = new FormData();
    formData.append('title', 'WebF Form Data Demo');
    formData.append('description', 'Testing FormData upload from WebF Vue app');
    formData.append('category', 'demo');
    formData.append('timestamp', new Date().toISOString());

    const textFile = new Blob(['This is a demo file content from WebF Vue app'], { type: 'text/plain' });
    formData.append('file', textFile, 'demo.txt');

    const response = await fetch('https://postman-echo.com/post', { method: 'POST', body: formData });
    const data = await response.json();
    updateResult('formdata', {
      status: response.status,
      statusText: response.statusText,
      data,
      duration: Date.now() - startTime,
    });
  } catch (error) {
    updateResult('formdata', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('formdata', false);
  }
}

async function testCustomHeaders() {
  setLoading('headers', true);
  const startTime = Date.now();
  try {
    const response = await fetch('https://postman-echo.com/headers', {
      method: 'GET',
      headers: {
        'X-Custom-Header': 'WebF-Vue-Demo',
        'X-Request-ID': `webf-${Date.now()}`,
        'X-Client-Version': '1.0.0',
        Authorization: 'Bearer demo-token-12345',
        'User-Agent': 'WebF-Vue-Demo/1.0.0',
        Accept: 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    });

    const data = await response.json();
    updateResult('headers', {
      status: response.status,
      statusText: response.statusText,
      data,
      duration: Date.now() - startTime,
    });
  } catch (error) {
    updateResult('headers', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('headers', false);
  }
}

async function testConcurrentRequests() {
  setLoading('concurrent', true);
  const startTime = Date.now();
  try {
    const requests = [
      fetch('https://dummyjson.com/products/1'),
      fetch('https://dummyjson.com/products/2'),
      fetch('https://dummyjson.com/products/3'),
      fetch('https://dummyjson.com/users/1'),
      fetch('https://dummyjson.com/users/2'),
    ];

    const responses = await Promise.all(requests);
    const data = await Promise.all(responses.map((r) => r.json()));
    const duration = Date.now() - startTime;

    updateResult('concurrent', {
      status: 200,
      statusText: 'OK',
      data: {
        totalRequests: requests.length,
        results: data,
        timing: `${requests.length} requests completed in ${duration}ms`,
      },
      headers: {},
      duration,
    });
  } catch (error) {
    updateResult('concurrent', `Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
  } finally {
    setLoading('concurrent', false);
  }
}

const tests: Array<{ key: string; title: string; desc: string; run: () => void | Promise<void> }> = [
  { key: 'get', title: 'GET JSON', desc: 'Fetch a product via GET', run: testGetRequest },
  { key: 'post', title: 'POST JSON', desc: 'Create a resource via POST', run: testPostRequest },
  { key: 'put', title: 'PUT JSON', desc: 'Update a resource via PUT', run: testPutRequest },
  { key: 'delete', title: 'DELETE', desc: 'Delete a resource via DELETE', run: testDeleteRequest },
  { key: 'xhr', title: 'XHR (GET)', desc: 'GET the same JSON via XMLHttpRequest', run: testXHRRequest },
  { key: 'formdata', title: 'FormData', desc: 'Upload a form with a file blob', run: testFormDataRequest },
  { key: 'headers', title: 'Custom Headers', desc: 'Send custom headers and inspect echo', run: testCustomHeaders },
  { key: 'concurrent', title: 'Concurrent', desc: 'Run multiple fetches in parallel', run: testConcurrentRequests },
];

function formatResult(result: RequestResult | string | undefined) {
  if (!result) return '';
  if (typeof result === 'string') return result;
  return JSON.stringify(
    {
      status: result.status,
      statusText: result.statusText,
      durationMs: result.duration,
      headers: result.headers,
      data: result.data,
    },
    null,
    2,
  );
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">Network</h1>
      <p class="text-fg-secondary mb-6">
        Demos for Fetch, XHR, FormData, headers, and concurrent requests. These require network access at runtime.
      </p>

      <div class="flex flex-col gap-4">
        <div v-for="t in tests" :key="t.key" class="bg-surface-secondary border border-line rounded-xl p-4">
          <div class="flex items-start gap-3">
            <div class="flex-1">
              <div class="text-lg font-medium text-fg-primary">{{ t.title }}</div>
              <div class="text-sm text-fg-secondary">{{ t.desc }}</div>
            </div>
            <button
              class="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-50"
              :disabled="isLoading[t.key]"
              @click="t.run"
            >
              {{ isLoading[t.key] ? 'Running...' : 'Run' }}
            </button>
          </div>

          <div v-if="results[t.key]" class="mt-4">
            <div class="text-sm text-fg-secondary mb-2">Result</div>
            <pre class="m-0 text-xs whitespace-pre-wrap rounded border border-line bg-surface p-3 overflow-auto">{{ formatResult(results[t.key]) }}</pre>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
