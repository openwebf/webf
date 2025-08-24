import React, { useState, useEffect, useRef, useCallback } from 'react';
import { fetchSpecContent, compileTypeScript, updateTestPage } from '../api/client';
import CodeMirror from '@uiw/react-codemirror';
import { javascript } from '@codemirror/lang-javascript';
import { oneDark } from '@codemirror/theme-one-dark';
import { EditorView } from '@codemirror/view';
import { autocompletion } from '@codemirror/autocomplete';
import { searchKeymap } from '@codemirror/search';
import { keymap } from '@codemirror/view';

interface CodePanelProps {
  specFile: string;
  isOpen: boolean;
  onClose: () => void;
}

interface TestCase {
  name: string;
  fn: () => void;
}

const fontOptions = [
  { label: 'Alibaba-PuHuiTi (Default)', value: "'Alibaba-PuHuiTi', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" },
  { label: 'AlibabaSans', value: "'AlibabaSans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" },
  { label: 'System Default', value: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif" },
  { label: 'Arial', value: "Arial, sans-serif" },
  { label: 'Helvetica', value: "'Helvetica Neue', Helvetica, Arial, sans-serif" },
  { label: 'Times New Roman', value: "'Times New Roman', Times, serif" },
  { label: 'Georgia', value: "Georgia, serif" },
  { label: 'Verdana', value: "Verdana, Geneva, sans-serif" },
  { label: 'Tahoma', value: "Tahoma, Geneva, sans-serif" },
  { label: 'Trebuchet MS', value: "'Trebuchet MS', Helvetica, sans-serif" },
  { label: 'Lucida Grande', value: "'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif" },
  { label: 'Palatino', value: "'Palatino Linotype', 'Book Antiqua', Palatino, serif" },
  { label: 'Garamond', value: "Garamond, serif" },
  { label: 'Comic Sans MS', value: "'Comic Sans MS', cursive" },
  { label: 'Courier New', value: "'Courier New', Courier, monospace" },
  { label: 'Monaco', value: "Monaco, monospace" },
];

const CodePanel: React.FC<CodePanelProps> = ({ specFile, isOpen, onClose }) => {
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentTestIndex, setCurrentTestIndex] = useState(0);
  const [totalTests, setTotalTests] = useState(0);
  const [testCases, setTestCases] = useState<TestCase[]>([]);
  const [testPageUrl, setTestPageUrl] = useState<string | null>(null);
  const [urlCopied, setUrlCopied] = useState(false);
  const [urlUpdating, setUrlUpdating] = useState(false);
  const [selectedFont, setSelectedFont] = useState<string>(fontOptions[0].value);
  const [isDarkTheme, setIsDarkTheme] = useState<boolean>(true);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const updateTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (isOpen && specFile) {
      loadSpecContent();
      // Reset URL when opening a different file
      setTestPageUrl(null);
      setUrlCopied(false);
    }
  }, [isOpen, specFile]);

  // Re-run code when font changes
  useEffect(() => {
    if (code && iframeRef.current) {
      runCode(code, true);
    }
  }, [selectedFont]);

  // Update WebF test page when current test index changes
  useEffect(() => {
    if (testPageUrl && code) {
      updateWebFContentDebounced(code);
    }
  }, [currentTestIndex]);

  const loadSpecContent = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await fetchSpecContent(specFile);
      setCode(data.content);
      // Run code after loading
      runCode(data.content);
      // Update the WebF test page if URL was already shown
      if (testPageUrl) {
        try {
          await updateTestPage(data.content, selectedFont, currentTestIndex);
        } catch (err) {
          console.error('Failed to update WebF test page:', err);
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load spec file');
    } finally {
      setLoading(false);
    }
  };

  const runCode = async (codeToRun?: string, updateUrl: boolean = false) => {
    const sourceCode = codeToRun || code;
    
    try {
      const compiledCode = await compileTypeScript(sourceCode);
      
      const html = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=360, height=640">
    <style>
        /* Global box-sizing reset */
        *, *::before, *::after {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            padding: 0;
            background: white;
            font-family: ${selectedFont};
            font-size: 16px;
        }
        
        /* Default user agent styles */
        p { margin: 1em 0; }
        h1 { font-size: 2em; margin: 0.67em 0; font-weight: bold; }
        h2 { font-size: 1.5em; margin: 0.83em 0; font-weight: bold; }
        h3 { font-size: 1.17em; margin: 1em 0; font-weight: bold; }
        
        /* Load fonts - AlibabaSans */
        @font-face {
            font-family: 'AlibabaSans';
            src: url('/fonts/AlibabaSans-Regular.otf') format('opentype');
            font-weight: 400;
        }
        @font-face {
            font-family: 'AlibabaSans';
            src: url('/fonts/AlibabaSans-Bold.otf') format('opentype');
            font-weight: 700;
        }
        
        /* Load fonts - Alibaba-PuHuiTi */
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Regular.ttf') format('truetype');
            font-weight: 400;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Light.ttf') format('truetype');
            font-weight: 300;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Medium.ttf') format('truetype');
            font-weight: 500;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Bold.ttf') format('truetype');
            font-weight: 700;
        }
        @font-face {
            font-family: 'Alibaba-PuHuiTi';
            src: url('/fonts/Alibaba-PuHuiTi-Heavy.ttf') format('truetype');
            font-weight: 900;
        }
        
        /* Test controls */
        .test-controls {
            position: fixed;
            bottom: 10px;
            right: 10px;
            background: white;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            z-index: 1000;
        }
        
        .test-info {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }
        
        .test-nav {
            display: flex;
            gap: 10px;
        }
        
        .nav-btn {
            padding: 6px 12px;
            border: 1px solid #007bff;
            background: white;
            color: #007bff;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .nav-btn:hover {
            background: #007bff;
            color: white;
        }
        
        .nav-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="test-controls">
        <div class="test-info">
            Test <span id="currentTest">1</span> of <span id="totalTests">0</span>
        </div>
        <div class="test-nav">
            <button class="nav-btn" id="prevBtn" onclick="window.parent.postMessage({type: 'prev'}, '*')">Previous</button>
            <button class="nav-btn" id="nextBtn" onclick="window.parent.postMessage({type: 'next'}, '*')">Next</button>
            <button class="nav-btn" onclick="window.parent.postMessage({type: 'runAll'}, '*')">Run All</button>
        </div>
    </div>
    <div class="test-content" id="test-content"></div>
    <script>
        let testCases = [];
        let currentTestIndex = 0;
        
        // Mock Jasmine functions
        window.describe = function(name, fn) { 
            // Collect tests first
            fn(); 
        };
        
        window.it = window.fit = function(name, fn) {
            testCases.push({ name, fn });
        };
        
        window.xit = function() {}; // Skip
        window.beforeEach = window.afterEach = function() {};
        window.expect = function(actual) {
            return {
                toBe: function() {},
                toEqual: function() {},
                toBeGreaterThan: function() {},
                toBeLessThan: function() {}
            };
        };
        
        // Mock snapshot function
        window.snapshot = async function() { 
            console.log('Snapshot captured');
            return Promise.resolve();
        };
        
        // Mock other common functions
        window.sleep = function(s) { return new Promise(function(r) { setTimeout(r, s * 1000); }); };
        window.requestAnimationFrame = window.requestAnimationFrame || function(cb) { return setTimeout(cb, 16); };
        
        // Add BODY global
        Object.defineProperty(window, 'BODY', {
            get: function() { return document.body; }
        });
        
        // Store original functions to avoid circular references
        var originalCreateElement = document.createElement.bind(document);
        var originalCreateTextNode = document.createTextNode.bind(document);
        
        // Add createElement helper
        window.createElement = function(tag, attrs, children) {
            var el = originalCreateElement(tag);
            if (attrs) {
                Object.keys(attrs).forEach(function(key) {
                    if (key === 'style' && typeof attrs[key] === 'object') {
                        Object.assign(el.style, attrs[key]);
                    } else {
                        el.setAttribute(key, attrs[key]);
                    }
                });
            }
            if (children) {
                children.forEach(function(child) {
                    if (typeof child === 'string') {
                        el.appendChild(originalCreateTextNode(child));
                    } else {
                        el.appendChild(child);
                    }
                });
            }
            return el;
        };
        
        // Add createText helper
        window.createText = function(content) {
            return originalCreateTextNode(content);
        };
        
        // Function to run a specific test
        function runTest(index) {
            if (index < 0 || index >= testCases.length) return;
            
            currentTestIndex = index;
            const test = testCases[index];
            const content = document.getElementById('test-content');
            
            // Clear ALL content from the page except the test controls
            content.innerHTML = '';
            // Also clean up any elements that tests might have added to body
            const elementsToRemove = [];
            for (let i = 0; i < document.body.children.length; i++) {
                const child = document.body.children[i];
                // Keep only the test controls and test content divs
                if (!child.classList.contains('test-controls') && child.id !== 'test-content') {
                    elementsToRemove.push(child);
                }
            }
            elementsToRemove.forEach(function(el) {
                el.remove();
            });
            
            // Reset body styles that tests might have modified
            var fontFamily = "${selectedFont.replace(/"/g, '\\"')}";
            document.body.style.cssText = 'margin: 0; padding: 0; background: white; font-family: ' + fontFamily + '; font-size: 16px;';
            
            try {
                // Handle async tests
                if (test.fn.length > 0) {
                    const done = function() {
                        console.log('Test completed');
                        updateUI();
                    };
                    test.fn(done);
                } else {
                    test.fn();
                    updateUI();
                }
            } catch (e) {
                content.innerHTML += '<div style="color: red; padding: 20px;">Error: ' + e.message + '</div>';
                console.error('Test error:', e);
            }
        }
        
        function updateUI() {
            document.getElementById('currentTest').textContent = currentTestIndex + 1;
            document.getElementById('totalTests').textContent = testCases.length;
            document.getElementById('prevBtn').disabled = currentTestIndex === 0;
            document.getElementById('nextBtn').disabled = currentTestIndex >= testCases.length - 1;
            
            // Send test info to parent
            window.parent.postMessage({
                type: 'testInfo',
                currentIndex: currentTestIndex,
                totalTests: testCases.length,
                testCases: testCases.map(function(t) { return t.name; })
            }, '*');
        }
        
        // Listen for navigation commands
        window.addEventListener('message', function(e) {
            if (e.data.type === 'prev' && currentTestIndex > 0) {
                runTest(currentTestIndex - 1);
            } else if (e.data.type === 'next' && currentTestIndex < testCases.length - 1) {
                runTest(currentTestIndex + 1);
            } else if (e.data.type === 'runAll') {
                runAllTests();
            } else if (e.data.type === 'runTest' && typeof e.data.index === 'number') {
                runTest(e.data.index);
            }
        });
        
        async function runAllTests() {
            const content = document.getElementById('test-content');
            content.innerHTML = '<h2>Running all tests...</h2>';
            
            for (let i = 0; i < testCases.length; i++) {
                const test = testCases[i];
                content.innerHTML += '<div style="margin: 20px 0; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">';
                content.innerHTML += '<h4>' + test.name + '</h4>';
                
                try {
                    const testContent = document.createElement('div');
                    document.body.appendChild(testContent);
                    
                    if (test.fn.length > 0) {
                        await new Promise(function(resolve) {
                            test.fn(function() { resolve(); });
                        });
                    } else {
                        test.fn();
                    }
                    
                    content.innerHTML += '<div style="color: green;">✓ Passed</div>';
                    content.innerHTML += testContent.innerHTML;
                    document.body.removeChild(testContent);
                } catch (e) {
                    content.innerHTML += '<div style="color: red;">✗ Failed: ' + e.message + '</div>';
                }
                
                content.innerHTML += '</div>';
            }
        }
        
        // Collect tests from compiled code
        try {
            ${compiledCode}
            
            // Update UI and run first test
            updateUI();
            if (testCases.length > 0) {
                runTest(0);
            } else {
                document.getElementById('test-content').innerHTML = '<div style="color: #666; padding: 20px;">No tests found in this file.</div>';
            }
        } catch (e) {
            document.getElementById('test-content').innerHTML = '<div style="color: red; padding: 20px;">Error: ' + e.message + '</div>';
            console.error(e);
        }
    </script>
</body>
</html>`;
      
      if (iframeRef.current) {
        iframeRef.current.srcdoc = html;
      }
      
      // Update WebF test page if requested
      if (updateUrl && testPageUrl) {
        try {
          await updateTestPage(sourceCode, selectedFont, currentTestIndex);
        } catch (err) {
          console.error('Failed to update WebF test page:', err);
        }
      }
    } catch (err) {
      alert('Compilation error: ' + (err instanceof Error ? err.message : 'Unknown error'));
      console.error(err);
    }
  };

  const generateWebFUrl = async () => {
    try {
      const result = await updateTestPage(code, selectedFont, currentTestIndex);
      const constantUrl = result.url; // This will always be /test-page/current
      setTestPageUrl(constantUrl);
      
      // Copy to clipboard
      navigator.clipboard.writeText(constantUrl).catch(() => {
        // Ignore clipboard errors silently
      });
    } catch (err) {
      alert('Failed to generate WebF URL: ' + (err instanceof Error ? err.message : 'Unknown error'));
    }
  };

  const updateWebFContentDebounced = useCallback((newCode: string) => {
    // Clear any existing timeout
    if (updateTimeoutRef.current) {
      clearTimeout(updateTimeoutRef.current);
    }
    
    // Only update content if we already have shown the URL (user has clicked WebF URL button)
    if (testPageUrl) {
      setUrlUpdating(true);
      updateTimeoutRef.current = setTimeout(async () => {
        try {
          await updateTestPage(newCode, selectedFont, currentTestIndex);
        } catch (err) {
          console.error('Failed to update WebF test page:', err);
        } finally {
          setUrlUpdating(false);
        }
      }, 1000); // Wait 1 second after user stops typing
    }
  }, [testPageUrl, selectedFont, currentTestIndex]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.type === 'testInfo') {
        setCurrentTestIndex(event.data.currentIndex);
        setTotalTests(event.data.totalTests);
        setTestCases(event.data.testCases.map((name: string) => ({ name, fn: () => {} })));
      } else if (event.data.type === 'prev' || event.data.type === 'next' || event.data.type === 'runAll' || event.data.type === 'runTest') {
        // Forward navigation messages back to the iframe
        if (iframeRef.current && iframeRef.current.contentWindow) {
          iframeRef.current.contentWindow.postMessage(event.data, '*');
        }
      }
    };

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
      // Clean up any pending timeout
      if (updateTimeoutRef.current) {
        clearTimeout(updateTimeoutRef.current);
      }
    };
  }, []);

  return (
    <div className={`code-panel ${isOpen ? 'open' : ''}`}>
      <div className="code-panel-header">
        <div>
          <div className="code-panel-title">Test Spec Editor</div>
          {totalTests > 0 && (
            <div className="test-summary">
              Test {currentTestIndex + 1} of {totalTests}
              {testCases[currentTestIndex] && ` - ${testCases[currentTestIndex].name}`}
            </div>
          )}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <select 
            className="font-selector"
            value={selectedFont}
            onChange={(e) => {
              setSelectedFont(e.target.value);
              // The useEffect will handle re-running the code
            }}
            title="Select font family for preview"
          >
            {fontOptions.map(option => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
          <button 
            className="theme-toggle-btn" 
            onClick={() => setIsDarkTheme(!isDarkTheme)}
            title={isDarkTheme ? "Switch to light theme" : "Switch to dark theme"}
          >
            {isDarkTheme ? '☀️' : '🌙'}
          </button>
          <button className="run-btn" onClick={() => runCode()}>Run</button>
          <button className="webf-btn" onClick={generateWebFUrl} title="Get WebF URL">
            WebF URL
          </button>
          <button className="close-btn" onClick={onClose}>&times;</button>
        </div>
      </div>
      <div className="code-panel-body">
        <div className="code-editor-container">
          {loading ? (
            <div className="loading">Loading spec file...</div>
          ) : error ? (
            <div className="error">Error: {error}</div>
          ) : (
            <CodeMirror
              value={code}
              height="100%"
              theme={isDarkTheme ? oneDark : undefined}
              basicSetup={{
                lineNumbers: true,
                highlightActiveLineGutter: true,
                highlightSpecialChars: true,
                history: true,
                foldGutter: true,
                drawSelection: true,
                dropCursor: true,
                allowMultipleSelections: true,
                indentOnInput: true,
                syntaxHighlighting: true,
                bracketMatching: true,
                closeBrackets: true,
                autocompletion: true,
                rectangularSelection: true,
                highlightSelectionMatches: true,
                searchKeymap: true,
              }}
              extensions={[
                javascript({ typescript: true }),
                autocompletion(),
                keymap.of(searchKeymap),
                EditorView.lineWrapping,
                EditorView.theme({
                  "&": {
                    fontSize: "13px",
                  },
                  ".cm-content": {
                    padding: "15px",
                    fontFamily: "'Monaco', 'Menlo', 'Ubuntu Mono', monospace",
                  },
                  ".cm-focused .cm-cursor": {
                    borderLeftColor: "#528bff",
                  },
                  ".cm-focused .cm-selectionBackground, ::selection": {
                    backgroundColor: isDarkTheme ? "#3e4451" : "#b3d4fc",
                  },
                  ".cm-gutters": {
                    backgroundColor: isDarkTheme ? "#282c34" : "#f7f7f7",
                    color: isDarkTheme ? "#5c6370" : "#999",
                    border: "none",
                  },
                  ".cm-activeLineGutter": {
                    backgroundColor: isDarkTheme ? "#2c313c" : "#e8e8e8",
                  },
                  ".cm-foldGutter .cm-gutterElement": {
                    padding: "0 3px",
                  },
                  ".cm-line": {
                    paddingLeft: "0",
                  },
                }),
              ]}
              onChange={(value) => {
                setCode(value);
                setUrlCopied(false);
                // Auto-update WebF content if URL exists
                updateWebFContentDebounced(value);
              }}
            />
          )}
        </div>
        <div className="preview-container">
          <div className="preview-header">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%' }}>
              <div>
                Live Preview
                {totalTests > 0 && (
                  <span style={{ marginLeft: '10px', fontSize: '12px', color: '#999' }}>
                    (Use controls in preview to navigate tests)
                  </span>
                )}
              </div>
              {testPageUrl && (
                <div className="webf-url-display" title="Click to copy">
                  <span className="url-label">WebF URL:</span>
                  {urlUpdating ? (
                    <span className="url-updating">Updating...</span>
                  ) : (
                    <>
                      <code 
                        className="url-text" 
                        onClick={() => {
                          navigator.clipboard.writeText(testPageUrl).then(() => {
                            setUrlCopied(true);
                            setTimeout(() => setUrlCopied(false), 2000);
                          });
                        }}
                      >
                        {testPageUrl}
                      </code>
                      {urlCopied && <span className="copy-feedback">Copied!</span>}
                    </>
                  )}
                </div>
              )}
            </div>
          </div>
          <iframe ref={iframeRef} className="preview-iframe" />
        </div>
      </div>
    </div>
  );
};

export default CodePanel;