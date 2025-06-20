/**
 * Example WebF application demonstrating TypeScript usage
 */

/// <reference path="../index.d.ts" />

// Using global webf object
async function initializeApp() {
  console.log('Initializing WebF app...');
  
  // Check WebF availability
  if (typeof webf === 'undefined') {
    console.error('WebF is not available');
    return;
  }
  
  // Set up method channel handlers
  webf.methodChannel.addMethodCallHandler('showMessage', (args) => {
    const [message] = args;
    showNotification(message);
  });
  
  // Communicate with Flutter
  try {
    const result = await webf.methodChannel.invokeMethod('flutter', 'getDeviceInfo');
    console.log('Device info:', result);
  } catch (error) {
    console.error('Failed to get device info:', error);
  }
  
  // Set up navigation
  setupNavigation();
  
  // Initialize UI
  createUI();
}

function setupNavigation() {
  // Listen to navigation events
  webf.addWebfModuleListener('navigation', (event, data) => {
    console.log('Navigation event:', event.type, data);
  });
  
  // Handle back button
  window.addEventListener('popstate', (e) => {
    console.log('User navigated back');
  });
  
  // Setup hybrid navigation
  document.getElementById('home-btn')?.addEventListener('click', () => {
    webf.hybridHistory.pushNamed('/home');
  });
  
  document.getElementById('back-btn')?.addEventListener('click', () => {
    if (webf.hybridHistory.canPop()) {
      webf.hybridHistory.pop();
    }
  });
}

function createUI() {
  // Create main container
  const container = document.createElement('div');
  container.className = 'app-container';
  container.style.cssText = `
    display: flex;
    flex-direction: column;
    padding: 20px;
    font-family: system-ui;
  `;
  
  // Add header
  const header = document.createElement('h1');
  header.textContent = 'WebF TypeScript App';
  container.appendChild(header);
  
  // Add canvas for drawing
  const canvas = createCanvas();
  container.appendChild(canvas);
  
  // Add interactive elements
  const controls = createControls();
  container.appendChild(controls);
  
  // Add to body
  document.body.appendChild(container);
  
  // Setup resize observer
  observeResize(container);
}

function createCanvas(): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = 300;
  canvas.height = 200;
  canvas.style.border = '1px solid #ccc';
  
  const ctx = canvas.getContext('2d');
  if (ctx) {
    // Draw something
    ctx.fillStyle = '#4CAF50';
    ctx.fillRect(10, 10, 100, 50);
    
    ctx.strokeStyle = '#2196F3';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(200, 100, 50, 0, Math.PI * 2);
    ctx.stroke();
    
    ctx.fillStyle = '#333';
    ctx.font = '16px Arial';
    ctx.fillText('WebF Canvas', 10, 100);
  }
  
  return canvas;
}

function createControls(): HTMLElement {
  const controls = document.createElement('div');
  controls.style.marginTop = '20px';
  
  // Fetch data button
  const fetchBtn = document.createElement('button');
  fetchBtn.textContent = 'Fetch Data';
  fetchBtn.onclick = async () => {
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      showNotification(`Fetched: ${JSON.stringify(data)}`);
    } catch (error) {
      console.error('Fetch failed:', error);
    }
  };
  controls.appendChild(fetchBtn);
  
  // Storage demo
  const storageBtn = document.createElement('button');
  storageBtn.textContent = 'Test Storage';
  storageBtn.onclick = () => {
    const key = 'webf-test';
    const value = new Date().toISOString();
    
    // Local storage
    localStorage.setItem(key, value);
    console.log('Stored in localStorage:', value);
    
    // Async storage
    asyncStorage.setItem(key, value).then(() => {
      console.log('Stored in asyncStorage:', value);
    });
  };
  controls.appendChild(storageBtn);
  
  // WebSocket test
  const wsBtn = document.createElement('button');
  wsBtn.textContent = 'Connect WebSocket';
  wsBtn.onclick = () => {
    const ws = new WebSocket('wss://echo.websocket.org');
    
    ws.onopen = () => {
      console.log('WebSocket connected');
      ws.send('Hello from WebF!');
    };
    
    ws.onmessage = (event) => {
      showNotification(`WebSocket echo: ${event.data}`);
    };
    
    ws.onerror = () => {
      console.error('WebSocket error');
    };
  };
  controls.appendChild(wsBtn);
  
  return controls;
}

function observeResize(element: HTMLElement) {
  const observer = new ResizeObserver((entries) => {
    for (const entry of entries) {
      console.log('Element resized:', {
        width: entry.contentRect.width,
        height: entry.contentRect.height
      });
    }
  });
  
  observer.observe(element);
  
  // Schedule some work during idle time
  webf.requestIdleCallback((deadline) => {
    console.log('Idle callback fired, time remaining:', deadline.timeRemaining());
    
    // Do some non-critical work
    updateMetrics();
  }, { timeout: 2000 });
}

function showNotification(message: string) {
  const notification = document.createElement('div');
  notification.textContent = message;
  notification.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: #333;
    color: white;
    padding: 10px 20px;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  `;
  
  document.body.appendChild(notification);
  
  setTimeout(() => {
    notification.remove();
  }, 3000);
}

function updateMetrics() {
  // Use Performance API
  performance.mark('metrics-start');
  
  // Simulate some work
  const data = Array.from({ length: 1000 }, (_, i) => Math.random() * i);
  const sum = data.reduce((a, b) => a + b, 0);
  
  performance.mark('metrics-end');
  performance.measure('metrics-duration', 'metrics-start', 'metrics-end');
  
  const measures = performance.getEntriesByName('metrics-duration');
  if (measures.length > 0) {
    console.log('Metrics calculation took:', measures[0].duration, 'ms');
  }
}

// Media query handling
function setupResponsive() {
  const mq = matchMedia('(max-width: 768px)');
  
  function handleMediaChange(e: MediaQueryListEvent) {
    if (e.matches) {
      document.body.classList.add('mobile');
    } else {
      document.body.classList.remove('mobile');
    }
  }
  
  // Initial check
  handleMediaChange({ matches: mq.matches, media: mq.media } as MediaQueryListEvent);
  
  // Listen for changes
  mq.addListener(handleMediaChange);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
    setupResponsive();
  });
} else {
  initializeApp();
  setupResponsive();
}

// Export for module usage
export { initializeApp, createUI, setupNavigation };