#!/usr/bin/env node

const express = require('express');
const path = require('path');
const fs = require('fs');
const open = require('open');
const chokidar = require('chokidar');
const WebSocket = require('ws');
const http = require('http');
const multer = require('multer');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 8080;
const distPath = path.join(__dirname, '..', 'dist');
const snapshotsPath = path.join(__dirname, '..', 'snapshots');

// Ensure snapshots directory exists
if (!fs.existsSync(snapshotsPath)) {
  fs.mkdirSync(snapshotsPath, { recursive: true });
}

// Configure multer for snapshot uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Create test-specific directory
    const testScope = process.env.TEST_SCOPE || 'default';
    const testDir = path.join(snapshotsPath, testScope);
    if (!fs.existsSync(testDir)) {
      fs.mkdirSync(testDir, { recursive: true });
    }
    cb(null, testDir);
  },
  filename: function (req, file, cb) {
    // Use the original filename from the client
    cb(null, file.originalname);
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Serve static files from dist directory
app.use(express.static(distPath));

// WebSocket for live reload
wss.on('connection', (ws) => {
  console.log('Client connected for live reload');
  
  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

// Watch for file changes and notify clients
const watcher = chokidar.watch(distPath, {
  ignored: /^\\./, 
  persistent: true
});

watcher.on('change', (filePath) => {
  console.log('File changed:', path.relative(distPath, filePath));
  
  // Notify all connected clients
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({ type: 'reload' }));
    }
  });
});

// API endpoint for snapshot uploads
app.post('/api/snapshot', upload.single('snapshot'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No snapshot file provided' });
  }
  
  const { testName, timestamp } = req.body;
  const testScope = process.env.TEST_SCOPE || 'default';
  const relativeFilePath = path.join(testScope, req.file.filename);
  
  console.log(`📸 Snapshot saved: ${relativeFilePath}`);
  console.log(`   Test: ${testName}`);
  console.log(`   Size: ${(req.file.size / 1024).toFixed(2)} KB`);
  
  res.json({ 
    status: 'saved',
    filename: req.file.filename,
    path: relativeFilePath,
    size: req.file.size
  });
});

// API endpoint for retrieving snapshots
app.get('/api/snapshots', (req, res) => {
  const testScope = process.env.TEST_SCOPE || 'default';
  const testDir = path.join(snapshotsPath, testScope);
  
  if (!fs.existsSync(testDir)) {
    return res.json({ snapshots: [] });
  }
  
  const files = fs.readdirSync(testDir)
    .filter(file => file.endsWith('.png'))
    .map(file => {
      const filePath = path.join(testDir, file);
      const stats = fs.statSync(filePath);
      return {
        filename: file,
        path: path.join(testScope, file),
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime
      };
    })
    .sort((a, b) => b.created.getTime() - a.created.getTime());
  
  res.json({ snapshots: files });
});

// Serve snapshots as static files
app.use('/snapshots', express.static(snapshotsPath));

// Add JSON body parser middleware for all routes
app.use(express.json());

// API endpoint for test results
app.post('/api/test-results', (req, res) => {
  const { results, scope, timestamp, status } = req.body;
  
  console.log(`\\n📊 Test Results for scope "${scope}":`);
  console.log(`📋 Status: ${status}`);
  console.log(`⏰ Timestamp: ${new Date(timestamp).toLocaleString()}`);
  
  if (results) {
    console.log(`✅ Passed: ${results.passed}`);
    console.log(`❌ Failed: ${results.failed}`);
    console.log(`⏭️  Skipped: ${results.skipped || 0}`);
    console.log(`⏱️  Duration: ${results.duration}ms`);
  }
  
  if (results.failures && results.failures.length > 0) {
    console.log(`\\n📋 Failures:`);
    results.failures.forEach((failure, index) => {
      console.log(`  ${index + 1}. ${failure.description}`);
      console.log(`     ${failure.message}`);
      if (failure.stack) {
        console.log(`     ${failure.stack.split('\\n')[0]}`);
      }
    });
  }
  
  console.log('');
  
  res.json({ status: 'received' });
});

// API endpoint for getting test configuration
app.get('/api/config', (req, res) => {
  try {
    const configPath = path.join(__dirname, '..', 'config.json5');
    const config = fs.readFileSync(configPath, 'utf8');
    res.json({ config });
  } catch (error) {
    res.status(500).json({ error: 'Failed to load configuration' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: Date.now(),
    scope: process.env.TEST_SCOPE || 'default'
  });
});

// Catch-all handler: send back React's index.html file
app.get('*', (req, res) => {
  const indexPath = path.join(distPath, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).send(`
      <html>
        <head><title>WebF Chrome Test Runner</title></head>
        <body>
          <h1>Test Bundle Not Found</h1>
          <p>Please run <code>npm run build</code> first to generate the test bundle.</p>
          <p>Current working directory: ${process.cwd()}</p>
          <p>Looking for: ${indexPath}</p>
        </body>
      </html>
    `);
  }
});

server.listen(PORT, () => {
  console.log(`🚀 WebF Chrome Test Server running at http://localhost:${PORT}`);
  console.log(`📁 Serving files from: ${distPath}`);
  console.log(`🔄 Live reload enabled`);
  console.log(`📋 Test scope: ${process.env.TEST_SCOPE || 'default'}`);
  
  // Automatically open browser
  if (process.env.NODE_ENV !== 'production') {
    setTimeout(() => {
      open(`http://localhost:${PORT}`);
    }, 1000);
  }
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\\n🛑 Shutting down test server...');
  watcher.close();
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});

process.on('SIGTERM', () => {
  console.log('\\n🛑 Received SIGTERM, shutting down gracefully...');
  watcher.close();
  server.close(() => {
    process.exit(0);
  });
});