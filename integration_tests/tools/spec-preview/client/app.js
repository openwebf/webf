class SpecPreview {
  constructor() {
    this.editor = null;
    this.compiledCode = null;
    this.init();
  }

  init() {
    this.initCodeEditor();
    this.setupEventListeners();
    this.loadDefaultCode();
  }

  initCodeEditor() {
    const textarea = document.getElementById('code-editor');
    this.editor = CodeMirror.fromTextArea(textarea, {
      mode: 'javascript',
      theme: 'monokai',
      lineNumbers: true,
      lineWrapping: true,
      indentUnit: 2,
      tabSize: 2,
      autoCloseBrackets: true,
      matchBrackets: true,
      showCursorWhenSelecting: true,
      extraKeys: {
        'Cmd-S': () => this.compileCode(),
        'Ctrl-S': () => this.compileCode(),
        'Cmd-Enter': () => this.runInBrowser(),
        'Ctrl-Enter': () => this.runInBrowser(),
      }
    });

    // Track if content has changed for auto-compile
    let contentChanged = false;
    this.editor.on('change', () => {
      contentChanged = true;
      // Update compile button to indicate auto-compile will happen
      const compileBtn = document.getElementById('compile-btn');
      if (contentChanged && compileBtn) {
        compileBtn.textContent = '⚙️ Compile (auto on blur)';
        compileBtn.classList.add('pending');
      }
    });

    // Auto-compile on blur when content has changed
    this.editor.on('blur', () => {
      if (contentChanged) {
        this.compileCode(true); // true = auto-compile
        contentChanged = false;
      }
    });
  }

  setupEventListeners() {
    // Button actions
    document.getElementById('copy-btn').addEventListener('click', () => this.copyCode());
    document.getElementById('compile-btn').addEventListener('click', () => this.compileCode());
    document.getElementById('run-browser-btn').addEventListener('click', () => this.runInBrowser());
    document.getElementById('copy-webf-url-btn').addEventListener('click', () => this.copyWebFUrl());
    document.getElementById('clear-output-btn').addEventListener('click', () => this.clearOutput());
    document.getElementById('reload-preview-btn').addEventListener('click', () => this.reloadPreview());
    document.getElementById('open-external-btn').addEventListener('click', () => this.openExternal());

    // Keyboard shortcuts
    document.addEventListener('keydown', (e) => {
      if ((e.metaKey || e.ctrlKey) && e.shiftKey) {
        switch(e.key) {
          case 'B':
            e.preventDefault();
            this.runInBrowser();
            break;
          case 'W':
            e.preventDefault();
            this.copyWebFUrl();
            break;
          case 'C':
            e.preventDefault();
            this.compileCode();
            break;
        }
      }
    });
  }

  loadDefaultCode() {
    const defaultCode = `describe('Sample Test', () => {
  it('should create and style an element', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'red';
    div.textContent = 'Hello WebF!';
    
    document.body.appendChild(div);
    
    expect(div.offsetWidth).toBe(100);
    expect(div.offsetHeight).toBe(100);
    
    // Uncomment to take a snapshot
    // await snapshot();
  });
});`;
    
    this.editor.setValue(defaultCode);
    this.addOutput('Ready to compile and run your spec', 'info');
  }

  async compileCode(isAutoCompile = false) {
    const code = this.editor.getValue();
    
    if (!code) {
      if (!isAutoCompile) {
        this.showToast('No code to compile', 'warning');
      }
      return;
    }
    
    // Reset compile button state
    const compileBtn = document.getElementById('compile-btn');
    if (compileBtn) {
      compileBtn.textContent = '⚙️ Compile';
      compileBtn.classList.remove('pending');
    }
    
    this.clearOutput();
    this.addOutput(isAutoCompile ? 'Auto-compiling...' : 'Compiling...', 'info');
    
    try {
      const response = await fetch('/api/compile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code })
      });
      
      const data = await response.json();
      
      if (data.success) {
        this.compiledCode = data.code;
        this.addOutput('Compilation successful!', 'success');
        this.addOutput(`Compiled code size: ${(data.code.length / 1024).toFixed(2)} KB`, 'info');
        
        // Enable run buttons
        document.getElementById('run-browser-btn').disabled = false;
        document.getElementById('copy-webf-url-btn').disabled = false;
        
        // Show WebF URL section
        const urlSection = document.getElementById('webf-url-section');
        const urlDisplay = document.getElementById('webf-url-display');
        const debugUrl = `${window.location.protocol}//${window.location.hostname}:${window.location.port}/kraken_debug_server.js`;
        
        urlSection.style.display = 'block';
        urlDisplay.textContent = debugUrl;
        
        // Add copy button handler for URL section
        document.getElementById('copy-url-btn').onclick = () => {
          navigator.clipboard.writeText(debugUrl).then(() => {
            this.showToast('WebF URL copied to clipboard', 'success');
          }).catch(() => {
            this.showToast('Failed to copy URL', 'error');
          });
        };
        
        this.showToast(isAutoCompile ? 'Auto-compiled successfully' : 'Compilation successful', 'success');
        
        // If auto-compile, also note that WebF debug server is updated
        if (isAutoCompile) {
          this.addOutput('WebF debug server updated with new code', 'info');
        }
      } else {
        this.addOutput(`Compilation failed: ${data.error}`, 'error');
        if (data.details) {
          this.addOutput(data.details, 'error');
        }
        this.showToast('Compilation failed', 'error');
      }
    } catch (error) {
      this.addOutput(`Error: ${error.message}`, 'error');
      this.showToast('Compilation error', 'error');
      console.error('Compilation error:', error);
    }
  }

  async runInBrowser() {
    if (!this.compiledCode) {
      this.showToast('Please compile the code first', 'warning');
      return;
    }
    
    this.addOutput('Running in browser...', 'info');
    
    try {
      const response = await fetch('/api/run/browser', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code: this.compiledCode })
      });
      
      const data = await response.json();
      
      if (data.success) {
        // Show preview with loading state
        const iframe = document.getElementById('preview-iframe');
        const placeholder = document.getElementById('preview-placeholder');
        
        // Add loading state
        iframe.className = 'preview-iframe loading';
        iframe.style.display = 'block';
        placeholder.style.display = 'none';
        
        // Set up load handlers
        iframe.onload = () => {
          iframe.className = 'preview-iframe success';
          this.addOutput('✓ Tests running in browser', 'success');
          
          // Remove success state after 2 seconds
          setTimeout(() => {
            iframe.className = 'preview-iframe';
          }, 2000);
        };
        
        iframe.onerror = () => {
          iframe.className = 'preview-iframe error';
          this.addOutput('✗ Failed to load preview', 'error');
        };
        
        iframe.src = data.url;
        
        this.addOutput('Loading browser preview...', 'info');
        this.showToast('Running in browser', 'success');
      } else {
        this.addOutput(`Failed to run: ${data.error}`, 'error');
        this.showToast('Failed to run in browser', 'error');
      }
    } catch (error) {
      this.addOutput(`Error: ${error.message}`, 'error');
      this.showToast('Runtime error', 'error');
      console.error('Runtime error:', error);
    }
  }

  async copyWebFUrl() {
    if (!this.compiledCode) {
      this.showToast('Please compile the code first', 'warning');
      return;
    }
    
    try {
      const response = await fetch('/api/webf/url');
      const data = await response.json();
      
      if (data.success) {
        navigator.clipboard.writeText(data.url).then(() => {
          this.addOutput(`WebF Debug URL copied: ${data.url}`, 'success');
          this.addOutput('Use this URL in your WebF environment or development tools', 'info');
          this.showToast('WebF URL copied to clipboard', 'success');
        }).catch(() => {
          // Fallback: show URL for manual copying
          this.addOutput(`WebF Debug URL: ${data.url}`, 'success');
          this.addOutput('Copy this URL to use in WebF', 'info');
          this.showToast('Copy the URL from the output', 'warning');
        });
      }
    } catch (error) {
      this.addOutput(`Error: ${error.message}`, 'error');
      this.showToast('Failed to get WebF URL', 'error');
      console.error('WebF URL error:', error);
    }
  }

  copyCode() {
    const code = this.editor.getValue();
    
    if (!code) {
      this.showToast('No code to copy', 'warning');
      return;
    }
    
    navigator.clipboard.writeText(code).then(() => {
      this.showToast('Code copied to clipboard', 'success');
    }).catch(() => {
      this.showToast('Failed to copy code', 'error');
    });
  }

  reloadPreview() {
    const iframe = document.getElementById('preview-iframe');
    if (iframe.src) {
      iframe.src = iframe.src;
      this.showToast('Preview reloaded', 'success');
    }
  }

  openExternal() {
    const iframe = document.getElementById('preview-iframe');
    if (iframe.src) {
      window.open(iframe.src, '_blank');
    } else {
      this.showToast('No preview to open', 'warning');
    }
  }

  clearOutput() {
    const container = document.getElementById('output-container');
    container.innerHTML = '';
  }

  addOutput(message, type = 'info') {
    const container = document.getElementById('output-container');
    
    // Remove placeholder if it exists
    const placeholder = container.querySelector('.output-placeholder');
    if (placeholder) {
      placeholder.remove();
    }
    
    const logEntry = document.createElement('div');
    logEntry.className = `output-log ${type}`;
    
    const timestamp = new Date().toLocaleTimeString();
    logEntry.textContent = `[${timestamp}] ${message}`;
    
    container.appendChild(logEntry);
    container.scrollTop = container.scrollHeight;
  }

  showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type}`;
    
    // Show toast
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Hide after 3 seconds
    setTimeout(() => {
      toast.classList.remove('show');
    }, 3000);
  }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  new SpecPreview();
});