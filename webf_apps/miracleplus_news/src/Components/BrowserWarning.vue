<template>
  <div class="browser-warning">
    <div class="warning-container">
      <div class="icon">⚠️</div>
      <h1>WebF Enterprise Required</h1>
      <p class="description">
        This is NOT a traditional web demo. To view this MiraclePlus News app, you must have WebF Enterprise (>= 0.22.0) installed in your Flutter app.
      </p>
      <div class="info-section">
        <h2>What is WebF?</h2>
        <p>
          WebF enables you to build Flutter apps using web technologies (HTML, CSS, JavaScript) with frameworks like Vue.js. 
          This is NOT for building web applications - it's for building native Flutter applications using familiar web development tools.
        </p>
        <p style="margin-top: 12px;">
          This news app showcases a full-featured content platform built with Vue.js and rendered as native Flutter widgets.
        </p>
      </div>
      <div class="how-to-section">
        <h2>Quick Start - View the App:</h2>
        <pre class="code-block">import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

void main() {
  // Initialize WebF Controller Manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 2,
    maxAttachedInstances: 1,
  ));
  
  runApp(MaterialApp(
    home: Scaffold(
      body: WebF.fromControllerName(
        controllerName: 'news',
        bundle: WebFBundle.fromUrl('https://miracleplus-news.vercel.app/'),
      ),
    ),
  ));
}</pre>
      </div>
      <div class="links-section">
        <h2 style="font-size: 18px; margin-bottom: 16px;">Resources:</h2>
        <div style="display: flex; gap: 12px; flex-wrap: wrap; justify-content: center;">
          <a href="https://openwebf.com" target="_blank" rel="noopener noreferrer">
            WebF Enterprise
          </a>
          <a href="https://github.com/openwebf/webf" target="_blank" rel="noopener noreferrer">
            WebF GitHub
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BrowserWarning'
}
</script>

<style scoped>
.browser-warning {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #f2f2f7;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  overflow-y: auto;
}

@media (prefers-color-scheme: dark) {
  .browser-warning {
    background-color: #1c1c1e;
    color: #ffffff;
  }
}

.warning-container {
  max-width: 600px;
  width: 100%;
  background-color: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  text-align: center;
  max-height: 90vh;
  overflow-y: auto;
}

@media (prefers-color-scheme: dark) {
  .warning-container {
    background-color: #2c2c2e;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  }
}

.icon {
  font-size: 36px;
  margin-bottom: 12px;
}

h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: #000000;
}

@media (prefers-color-scheme: dark) {
  h1 {
    color: #ffffff;
  }
}

.description {
  font-size: 16px;
  color: #666666;
  margin: 0 0 20px 0;
  line-height: 1.4;
}

@media (prefers-color-scheme: dark) {
  .description {
    color: #999999;
  }
}

.info-section,
.how-to-section {
  text-align: left;
  margin: 20px 0;
}

h2 {
  font-size: 20px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: #000000;
}

@media (prefers-color-scheme: dark) {
  h2 {
    color: #ffffff;
  }
}

.info-section p,
.how-to-section p {
  font-size: 16px;
  line-height: 1.6;
  color: #333333;
  margin: 0;
}

@media (prefers-color-scheme: dark) {
  .info-section p,
  .how-to-section p {
    color: #cccccc;
  }
}

ol {
  margin: 12px 0 0 0;
  padding-left: 24px;
}

li {
  font-size: 16px;
  line-height: 1.8;
  color: #333333;
  margin-bottom: 8px;
}

@media (prefers-color-scheme: dark) {
  li {
    color: #cccccc;
  }
}

.links-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e5e5e7;
}

@media (prefers-color-scheme: dark) {
  .links-section {
    border-top-color: #3a3a3c;
  }
}

.links-section p {
  font-size: 16px;
  margin: 0 0 12px 0;
  color: #666666;
}

@media (prefers-color-scheme: dark) {
  .links-section p {
    color: #999999;
  }
}

a {
  display: inline-block;
  color: #007aff;
  text-decoration: none;
  font-size: 16px;
  font-weight: 500;
  padding: 12px 24px;
  border: 2px solid #007aff;
  border-radius: 8px;
  transition: all 0.2s ease;
}

a:hover {
  background-color: #007aff;
  color: #ffffff;
}

.code-block {
  background: #f5f5f7;
  padding: 12px;
  border-radius: 8px;
  overflow-x: auto;
  font-size: 13px;
  line-height: 1.4;
  text-align: left;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
}

@media (prefers-color-scheme: dark) {
  .code-block {
    background: #1c1c1e;
    color: #ffffff;
  }
}

@media (max-width: 640px) {
  .warning-container {
    padding: 24px;
  }
  
  h1 {
    font-size: 24px;
  }
  
  .description {
    font-size: 16px;
  }
  
  h2 {
    font-size: 18px;
  }
  
  .info-section p,
  .how-to-section p,
  li {
    font-size: 14px;
  }
}
</style>