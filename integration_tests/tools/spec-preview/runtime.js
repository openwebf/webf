/**
 * WebF Test Runtime
 * 
 * Standalone runtime that provides all necessary test utilities for both browser and WebF environments.
 * This runtime is injected before user test code and ensures consistent behavior across:
 * - Browser preview (with mocked WebF APIs)
 * - Actual WebF runtime (via debug server URL)
 * 
 * Includes all implementations from integration_tests/runtime/global.ts
 */

(function(global) {
  'use strict';

  // Ensure document.body exists (BODY getter)
  Object.defineProperty(global, 'BODY', {
    get() {
      return document.body;
    }
  });

  // Set default background color for snapshots (from reset.ts)
  if (typeof document !== 'undefined' && document.documentElement) {
    document.documentElement.style.backgroundColor = 'white';
  }

  // Helper functions from global.ts
  global.setElementStyle = function(dom, object) {
    if (object == null) return;
    for (let key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  };

  global.setAttributes = function(dom, object) {
    for (const key in object) {
      if (object.hasOwnProperty(key)) {
        dom.setAttribute(key, object[key]);
      }
    }
  };

  global.test = function(fn, title) {
    it(title, fn);
  };

  global.ftest = function(fn, title) {
    fit(title, fn);
  };

  global.xtest = function(fn, title) {
    xit(title, fn);
  };

  global.assert_equals = function(a, b, message) {
    if(typeof a != typeof b) {
      fail(message);
      return;
    }
    if (b !== b) {
      // NaN case 
      expect(a !== a).toBe(true, message);
      return;
    }
    expect(a).toBe(b, message);
  };

  global.assert_class_string = function(classObject, result) {
    expect(classObject.constructor.name).toBe(result);
  };

  global.assert_true = function(value, message) {
    expect(value).toBe(true, message);
  };

  global.assert_throws_exactly = function(error, fn) {
    expect(fn).toThrow(error);
  };

  global.assert_throws = function(error, fn) {
    expect(fn).toThrow();
  };

  global.assert_not_equals = function(a, b, message) {
    expect(a !== b).toBe(true, message);
  };

  global.assert_false = function(value, message) {
    expect(value).toBe(false, message);
  };

  global.assert_approx_equals = function(actual, expected, epsilon, description) {
    description = description + ", actual value is " + actual;
    assert_true(typeof actual === "number", description);

    if (isFinite(actual) || isFinite(expected)) {
      assert_true(Math.abs(actual - expected) <= epsilon, description);
    } else {
      assert_equals(actual, expected);
    }
  };

  global.format_value = function(v) {
    return JSON.stringify(v);
  };

  global.assert_array_equals = function(value, result, message) {
    expect([].slice.call(value)).toEqual(result, message);
  };

  // Sleep utility
  const originalTimeout = global.setTimeout;
  global.sleep = function(second) {
    return new Promise(done => originalTimeout(done, second * 1000));
  };

  global.nextFrames = function(count = 0) {
    return new Promise((resolve, reject) => {
      function frame() {
        if (count == 0) {
          resolve();
          return;
        }
        count--;
        requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    });
  };

  global.setElementProps = function(el, props) {
    let keys = Object.keys(props);
    for (let key of keys) {
      if (key === 'style') {
        setElementStyle(el, props[key]);
      } else {
        el[key] = props[key];
      }
    }
  };

  global.createElement = function(tag, props, child) {
    const el = document.createElement(tag);
    setElementProps(el, props);
    if (Array.isArray(child)) {
      child.forEach(c => el.appendChild(c));
    } else if (child) {
      el.appendChild(child);
    }
    return el;
  };

  global.createElementWithStyle = function(tag, style, child) {
    const el = document.createElement(tag);
    setElementStyle(el, style);
    if (Array.isArray(child)) {
      child.forEach(c => el.appendChild(c));
    } else if (child) {
      el.appendChild(child);
    }
    return el;
  };

  global.createViewElement = function(extraStyle, child) {
    return createElement(
      'div',
      {
        style: {
          display: 'flex',
          position: 'relative',
          flexDirection: 'column',
          flexShrink: 0,
          alignContent: 'flex-start',
          border: '0 solid black',
          margin: 0,
          padding: 0,
          minWidth: 0,
          ...extraStyle,
        },
      },
      child
    );
  };

  global.createText = function(content) {
    return document.createTextNode(content);
  };

  // Cubic bezier for animations
  class Cubic {
    constructor(a, b, c, d) {
      this.a = a;
      this.b = b;
      this.c = c;
      this.d = d;
    }

    _evaluateCubic(a, b, m) {
      return 3 * a * (1 - m) * (1 - m) * m +
        3 * b * (1 - m) * m * m +
        m * m * m;
    }

    transformInternal(t) {
      let start = 0.0;
      let end = 1.0;
      while (true) {
        let midpoint = (start + end) / 2;
        let estimate = this._evaluateCubic(this.a, this.c, midpoint);
        if (Math.abs((t - estimate)) < 0.001)
          return this._evaluateCubic(this.b, this.d, midpoint);
        if (estimate < t)
          start = midpoint;
        else
          end = midpoint;
      }
    }
  }

  const ease = new Cubic(0.25, 0.1, 0.25, 1.0);

  // Pointer change constants
  global.PointerChange = {
    add: 0,
    down: 1,
    move: 2,
    up: 3,
    remove: 4
  };

  global.PointerSignalKind = {
    none: 0,
    scroll: 1
  };

  // Simulate pointer (WebF specific, mocked in browser)
  if (typeof global.simulatePointer === 'undefined') {
    global.simulatePointer = async function() {
      if (global.webf && global.webf.methodChannel && global.webf.methodChannel.invokeMethod) {
        // Real WebF implementation
        return global.webf.methodChannel.invokeMethod('simulatePointer', arguments);
      } else {
        console.log('Pointer simulation (mocked in browser)');
        return Promise.resolve();
      }
    };
  }

  // Simulate mouse click action
  global.simulateClick = async function(x, y, pointer = 0) {
    await global.simulatePointer([
      [x, y, global.PointerChange.add],
      [x, y, global.PointerChange.down],
      [x, y, global.PointerChange.up],
      [x, y, global.PointerChange.remove]
    ], pointer);
  };

  // Simulate mouse swipe action
  global.simulateSwipe = async function(startX, startY, endX, endY, duration, pointer = 0) {
    let params = [];
    let pointerMoveDelay = 0.016;
    let totalCount = duration / pointerMoveDelay;
    let diffXPerFrame = (endX - startX) / totalCount;
    let diffYPerFrame = (endY - startY) / totalCount;

    let previousX = startX;
    let previousY = startY;
    for (let i = 0; i < totalCount; i++) {
      let progress = i / totalCount;
      let diffX = diffXPerFrame * 100 * ease.transformInternal(progress);
      let diffY = diffYPerFrame * 100 * ease.transformInternal(progress);

      params.push([startX + diffX, startY + diffY, global.PointerChange.move, global.PointerSignalKind.scroll, startX + diffX - previousX, startY + diffY - previousY]);

      previousX = startX + diffX;
      previousY = startY + diffY;
    }

    await global.simulatePointer(params, pointer);
  };

  // Simulate point down action
  global.simulatePointDown = async function(x, y, pointer = 0) {
    return new Promise(async (resolve) => {
      requestAnimationFrame(async () => {
        await global.simulatePointer([
          [x, y, global.PointerChange.down],
        ], pointer);
        resolve();
      });
    });
  };

  global.simulatePointMove = async function(x, y, pointer = 0) {
    return new Promise((resolve) => {
      requestAnimationFrame(async () => {
        await global.simulatePointer([
          [x, y, global.PointerChange.move],
        ], pointer);
        resolve();
      });
    });
  };

  global.simulatePointAdd = async function(x, y, pointer = 0) {
    return new Promise(resolve => {
      requestAnimationFrame(async () => {
        await global.simulatePointer([
          [x, y, global.PointerChange.add],
        ], pointer);
        resolve();
      });
    });
  };

  global.simulatePointRemove = async function(x, y, pointer = 0) {
    return new Promise(resolve => {
      requestAnimationFrame(async () => {
        await global.simulatePointer([
          [x, y, global.PointerChange.remove],
        ], pointer);
        resolve();
      });
    });
  };

  // Simulate point up action
  global.simulatePointUp = async function(x, y, pointer = 0) {
    return new Promise(resolve => {
      requestAnimationFrame(async () => {
        await global.simulatePointer([
          [x, y, global.PointerChange.up]
        ], pointer);
        resolve();
      });
    });
  };

  // Image load helpers
  global.onDoubleImageLoad = function(img1, img2, onLoadCallback) {
    let count = 0;
    async function onLoad() {
      count++;
      if (count >= 2) {
        await onLoadCallback();
      }
    }
    img1.addEventListener('load', onLoad);
    img2.addEventListener('load', onLoad);
  };

  global.onTripleImageLoad = function(img1, img2, img3, onLoadCallback) {
    let count = 0;
    async function onLoad() {
      count++;
      if (count >= 3) {
        await onLoadCallback();
      }
    }
    img1.addEventListener('load', onLoad);
    img2.addEventListener('load', onLoad);
    img3.addEventListener('load', onLoad);
  };

  global.onFourfoldImageLoad = function(img1, img2, img3, img4, onLoadCallback) {
    let count = 0;
    async function onLoad() {
      count++;
      if (count >= 4) {
        await onLoadCallback();
      }
    }
    img1.addEventListener('load', onLoad);
    img2.addEventListener('load', onLoad);
    img3.addEventListener('load', onLoad);
    img4.addEventListener('load', onLoad);
  };

  global.onImageLoad = function(img, onLoadCallback) {
    img.addEventListener('load', onLoadCallback);
  };

  global.append = function(parent, child) {
    parent.appendChild(child);
  };

  // Snapshot functions
  global.snapshot = async function(target, filename, postfix) {
    if (global.__webf_sync_buffer__) {
      global.__webf_sync_buffer__();
    }
    return new Promise((resolve, reject) => {
      requestAnimationFrame(async () => {
        try {
          if (typeof target == 'number') {
            await sleep(target);
            target = null;
          }
          const element = target || document.documentElement;
          if (element.toBlob && global.expectAsync) {
            await expectAsync(element.toBlob(1.0)).toMatchSnapshot(filename, postfix);
          } else {
            console.log('Snapshot called (mocked in browser)');
          }
          resolve();
        } catch (e) {
          reject(e);
        }
      });
    });
  };

  global.snapshotBody = async function(target, filename, postfix) {
    if (global.__webf_sync_buffer__) {
      global.__webf_sync_buffer__();
    }
    return new Promise((resolve, reject) => {
      requestAnimationFrame(async () => {
        try {
          if (typeof target == 'number') {
            await sleep(target);
          }
          if (document.body.toBlob && global.expectAsync) {
            await expectAsync(document.body.toBlob(1.0)).toMatchSnapshot(filename, postfix);
          } else {
            console.log('Snapshot body called (mocked in browser)');
          }
          resolve();
        } catch (e) {
          reject(e);
        }
      });
    });
  };

  global.waitForOnScreen = async function(target) {
    return new Promise((resolve, reject) => {
      target.addEventListener('onscreen', () => {
        resolve();
      });
    });
  };

  global.waitForFrame = async function() {
    return new Promise((resolve, reject) => {
      requestAnimationFrame(() => resolve());
    });
  };

  // Snapshot blob caching
  let snapshotBlob = undefined;

  global.getSnapshot = async function(target) {
    await nextFrames();
    return target && target.toBlob ? target.toBlob(1.0) : document.documentElement.toBlob(1.0);
  };

  global.cacheSnapshot = async function(target) {
    snapshotBlob = await getSnapshot(target);
  };

  global.matchCacheSnapshot = async function(target) {
    if (!snapshotBlob) {
      throw new Error('Must be call cacheSnapshot before matchCacheSnapshot');
    }
    await expectAsync(getSnapshot()).toMatchSnapshot(snapshotBlob);
  };

  // Test computed value helper
  global.test_computed_value = function(property, specified, computed = specified) {
    const target = document.getElementById('target');
    expect(target).not.toBeNull();
    target?.style?.setProperty(property, '');
    target?.style?.setProperty(property, specified);

    let readValue = getComputedStyle(target)[property];
    expect(readValue).toEqual(computed);
  };

  // Resize viewport (WebF specific)
  global.resizeViewport = function(width = -1, height = -1) {
    if (global.webf && global.webf.methodChannel && global.webf.methodChannel.invokeMethod) {
      return webf.methodChannel.invokeMethod('resizeViewport', width, height).then(() => {
        return nextFrames();
      });
    } else {
      console.log('Resize viewport called (mocked in browser)');
      return Promise.resolve();
    }
  };

  // WebF method channel mock for browser
  if (typeof global.webf === 'undefined') {
    global.webf = {
      methodChannel: {
        invokeMethod: async function(method, ...args) {
          console.log(`WebF method channel: ${method}`, args);
          return Promise.resolve();
        }
      }
    };
  }

  // Test runner implementation for multiple environments:
  // 1. Browser - No Jasmine, use mock implementation
  // 2. WebF Example - No Jasmine, use mock implementation  
  // 3. WebF Integration Playground - Has Jasmine, let it handle execution
  
  // Detect environment type
  const hasJasmine = typeof global.jasmine !== 'undefined';
  const hasWebF = typeof global.webf !== 'undefined';
  const hasSimulatePointer = typeof global.simulatePointer !== 'undefined';
  
  if (hasJasmine && hasSimulatePointer) {
    // WebF Integration Playground - has Jasmine and native APIs
    console.log('WebF Integration Playground detected - using native Jasmine');
    // Tests will execute automatically via Jasmine
  } else if (!hasJasmine) {
    // Browser or WebF Example environment - no Jasmine
    const testResults = [];
    
    global.describe = function(name, fn) {
      console.group('Test Suite: ' + name);
      try {
        fn();
      } catch (e) {
        console.error('Suite error:', e);
      }
      console.groupEnd();
    };
    
    global.it = global.fit = function(name, fn, timeout) {
      console.log('Running test: ' + name);
      
      // Handle async tests with done callback
      if (fn.length > 0) {
        const timer = setTimeout(() => {
          console.error('✗ ' + name + ' (timeout after 5000ms)');
          if (global.addTestResult) {
            global.addTestResult(name, 'fail', 'Test timeout after 5000ms');
          }
        }, timeout || 5000);
        
        const done = () => {
          clearTimeout(timer);
          console.log('✓ ' + name);
          if (global.addTestResult) {
            global.addTestResult(name, 'pass');
          }
        };
        
        try {
          const result = fn(done);
          // Handle promise-based tests
          if (result && typeof result.then === 'function') {
            result.then(() => {
              clearTimeout(timer);
              console.log('✓ ' + name);
              if (global.addTestResult) {
                global.addTestResult(name, 'pass');
              }
            }).catch(err => {
              clearTimeout(timer);
              console.error('✗ ' + name, err);
              if (global.addTestResult) {
                global.addTestResult(name, 'fail', err.toString());
              }
            });
          }
        } catch (err) {
          clearTimeout(timer);
          console.error('✗ ' + name, err);
          if (global.addTestResult) {
            global.addTestResult(name, 'fail', err.toString());
          }
        }
      } else {
        // Synchronous test
        try {
          const result = fn();
          if (result && typeof result.then === 'function') {
            result.then(() => {
              console.log('✓ ' + name);
              if (global.addTestResult) {
                global.addTestResult(name, 'pass');
              }
            }).catch(err => {
              console.error('✗ ' + name, err);
              if (global.addTestResult) {
                global.addTestResult(name, 'fail', err.toString());
              }
            });
          } else {
            console.log('✓ ' + name);
            if (global.addTestResult) {
              global.addTestResult(name, 'pass');
            }
          }
        } catch (err) {
          console.error('✗ ' + name, err);
          if (global.addTestResult) {
            global.addTestResult(name, 'fail', err.toString());
          }
        }
      }
    };
    
    global.xit = function(name, fn) {
      console.log('⊘ ' + name + ' (skipped)');
      if (global.addTestResult) {
        global.addTestResult(name, 'skip');
      }
    };

    global.beforeEach = function(fn) {
      console.log('beforeEach registered');
    };

    global.afterEach = function(fn) {
      console.log('afterEach registered');
      // Reset snapshot blob after each test
      snapshotBlob = undefined;
    };

    global.beforeAll = function(fn) {
      console.log('beforeAll registered');
    };

    global.afterAll = function(fn) {
      console.log('afterAll registered');
    };
  }

  // Expect implementation (basic)
  if (typeof global.expect === 'undefined') {
    global.expect = function(actual) {
      return {
        toBe: function(expected, message) {
          if (actual !== expected) {
            const error = message || `Expected ${expected} but got ${actual}`;
            throw new Error(error);
          }
        },
        toEqual: function(expected, message) {
          if (JSON.stringify(actual) !== JSON.stringify(expected)) {
            const error = message || `Expected ${JSON.stringify(expected)} but got ${JSON.stringify(actual)}`;
            throw new Error(error);
          }
        },
        toBeNull: function(message) {
          if (actual !== null) {
            const error = message || `Expected null but got ${actual}`;
            throw new Error(error);
          }
        },
        toThrow: function(expectedError) {
          let threw = false;
          let actualError;
          try {
            actual();
          } catch (e) {
            threw = true;
            actualError = e;
          }
          if (!threw) {
            throw new Error('Expected function to throw');
          }
          if (expectedError && actualError !== expectedError) {
            throw new Error(`Expected to throw ${expectedError} but threw ${actualError}`);
          }
        },
        not: {
          toBe: function(expected, message) {
            if (actual === expected) {
              const error = message || `Expected not ${expected} but got ${actual}`;
              throw new Error(error);
            }
          },
          toBeNull: function(message) {
            if (actual === null) {
              const error = message || 'Expected not null but got null';
              throw new Error(error);
            }
          }
        }
      };
    };

    global.fail = function(message) {
      throw new Error(message || 'Test failed');
    };
  }

  // ExpectAsync for snapshot testing
  if (typeof global.expectAsync === 'undefined') {
    global.expectAsync = function(promise) {
      return {
        toMatchSnapshot: async function(filename, postfix) {
          await promise;
          console.log('Snapshot matched (mocked)');
        }
      };
    };
  }

  // Log final runtime initialization status
  // Variables hasJasmine, hasWebF, hasSimulatePointer are already defined above
  if (typeof global.jasmine !== 'undefined' && typeof global.simulatePointer !== 'undefined') {
    console.log('WebF test runtime initialized (Integration Playground with Jasmine)');
  } else if (typeof global.webf !== 'undefined' && typeof global.jasmine === 'undefined') {
    console.log('WebF test runtime initialized (Example environment - using mock runner)');
  } else {
    console.log('WebF test runtime initialized (Browser environment - using mock runner)');
  }

})(typeof window !== 'undefined' ? window : global);