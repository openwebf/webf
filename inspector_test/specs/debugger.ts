import { InitializedEvent } from '@vscode/debugadapter';
import { client as WebSocketClient, connection } from 'websocket';
import { ConfigurationDoneRequest, ContinueRequest, EvaluateRequest, NextRequest, ScopesRequest, SetBreakpointsRequest, sleep, StackTraceRequest, StepInRequest, StepOutRequest, VariablesRequest, wrapVScodeExtension } from './utils';
import { DebugProtocol } from 'vscode-debugprotocol';
import { DebuggerTestRunner } from './test_runner';

async function sendRequest(connection: connection) {
  return new Promise((resolve, reject) => {

  });
  const request = wrapVScodeExtension(new InitializedEvent());
  connection.send(JSON.stringify(request));
}

describe('Debugger Test', () => {
  beforeEach(async () => {
    await globalThis.reRestartApp();
  });

  it('evaluate scripts and return int', async () => {
    const runner = new DebuggerTestRunner();
    await runner.createConnection();
    const request = new EvaluateRequest({
      expression: '1 + 1'
    });
    const response = await runner.sendRequest(request);
    expect(response.success).toBe(true);
    expect(response.body.result).toBe('2');
    expect(response.body.type).toBe('integer');
    expect(response.body.variablesReference).toBe(0);
  });

  it('set breakpoint before run should be stopped at the breakpoint', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 72,
          column: 0
        }]
      });
      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support get stack frame when paused', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 72,
          column: 0
        }]
      });
      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;

        const body = stackTraceResponse.body!;
        expect(body!.totalFrames).toBe(3);
        expect(body.stackFrames).toEqual([
          {
            id: 2147483647,
            name: 'jib',
            source: { path: '/assets/bundle.js', sources: [], checksums: [] },
            line: 72,
            column: 19,
            canRestart: false
          },
          {
            id: 2147483648,
            name: '<anonymous>',
            source: { path: '/assets/bundle.js', sources: [], checksums: [] },
            line: 77,
            column: 8,
            canRestart: false
          },
          {
            id: 2147483649,
            name: '<eval>',
            source: { path: '/assets/bundle.js', sources: [], checksums: [] },
            line: 78,
            column: 1,
            canRestart: false
          }
        ]);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support get scopes when paused', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 72,
          column: 0
        }]
      });
      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        expect(scopesResponse.success).toBe(true);
        const scopeBody = scopesResponse.body;
        expect(scopeBody.scopes).toEqual([
          { name: 'Local', variablesReference: 8589934589, expensive: false },
          { name: 'Closure', variablesReference: 8589934590, expensive: false },
          { name: 'Global', variablesReference: 8589934588, expensive: true }
        ]);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support inspect local variables when paused', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 72,
          column: 0
        }]
      });
      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          {
            name: 'this',
            value: 'Blub',
            type: 'object',
            variablesReference: 32768
          },
          { name: 'bbbb', value: 'NaN', type: 'float', variablesReference: 0 }
        ]);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support expand objects by variableReference when paused', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 72,
          column: 0
        }]
      });
      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        const thisObject = vars.body.variables[0];
        const thisProps = await runner.sendRequest(new VariablesRequest({
          variablesReference: thisObject.variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(thisProps.body.variables).toEqual([
          { name: 'peeps', value: '3', type: 'integer', variablesReference: 0 },
          {
            name: 'data',
            value: '{arr: Array(10), f: {..}}',
            type: 'object',
            variablesReference: 32771
          },
          {
            name: '[[Prototype]]',
            value: 'object',
            type: '{constructor: ƒ Blub (), jib: ƒ jib ()}',
            // @ts-ignore
            presentationHint: { attributes: [], visibility: 'internal', lazy: false },
            variablesReference: 32774
          }
        ]);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support expand objects by variableReference when runnings', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      await runner.sendRequest(new ConfigurationDoneRequest());
      await sleep(1);
      const evalRequest = new EvaluateRequest({
        expression: 'let a = { name: 1};',
        frameId: 0
      });
      await runner.sendRequest(evalRequest) as DebugProtocol.EvaluateResponse;
      const response = await runner.sendRequest(new EvaluateRequest({
        expression: 'a',
        frameId: 0
      })) as DebugProtocol.EvaluateResponse;
      const reference = response.body.variablesReference;
      const varRequest = new VariablesRequest({
        variablesReference: reference
      })
      const varResponse = await runner.sendRequest(varRequest) as DebugProtocol.VariablesResponse;
      expect(varResponse.body.variables).toEqual([
        { name: 'name', value: '1', type: 'integer', variablesReference: 0 },
        {
          name: '[[Prototype]]',
          value: 'object',
          type: '',
          // @ts-ignore
          presentationHint: { attributes: [], visibility: 'internal', lazy: false },
          variablesReference: 2
        }
      ]);
      resolve();
    });
  });

  it('should support expand object inner properties by variableReference when paused', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 72,
          column: 0
        }]
      });
      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
          const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
            threadId: threadId!
          })) as DebugProtocol.StackTraceResponse;
          const body = stackTraceResponse.body!;
          runner.setStackFrames(body.stackFrames);
          const scopesResponse = await runner.sendRequest(new ScopesRequest({
            frameId: body.stackFrames[0].id
          })) as DebugProtocol.ScopesResponse;
          const vars = await runner.sendRequest(new VariablesRequest({
            variablesReference: scopesResponse.body.scopes[0].variablesReference
          })) as DebugProtocol.VariablesResponse;
          const thisObject = vars.body.variables[0];
          const thisProps = await runner.sendRequest(new VariablesRequest({
            variablesReference: thisObject.variablesReference
          })) as DebugProtocol.VariablesResponse;
          const thisPropProps = await runner.sendRequest(new VariablesRequest({
            variablesReference: thisProps.body.variables[1].variablesReference
          })) as DebugProtocol.VariablesResponse;
          expect(thisPropProps.body.variables).toEqual([
            {
              name: 'arr',
              value: 'Array(10)',
              type: 'array',
              variablesReference: 32769
            },
            {
              name: 'f',
              value: '{a: {..}}',
              type: 'object',
              variablesReference: 32770
            },
            {
              name: '[[Prototype]]',
              value: 'object',
              type: '',
              // @ts-ignore
              presentationHint: { attributes: [], visibility: 'internal', lazy: false },
              variablesReference: 32776
            }
          ]);
          resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support expand object inner props by variableReference when runnings', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      await runner.sendRequest(new ConfigurationDoneRequest());
      await sleep(1);
      const evalRequest = new EvaluateRequest({
        expression: 'let a = { obj: { age: 10, name: 1} };',
        frameId: 0
      });
      await runner.sendRequest(evalRequest) as DebugProtocol.EvaluateResponse;
      const response = await runner.sendRequest(new EvaluateRequest({
        expression: 'a',
        frameId: 0
      }));
      const varResponse = await runner.sendRequest(new VariablesRequest({
        variablesReference: response.body.variablesReference
      })) as DebugProtocol.VariablesResponse;
      const varPropResponse = await runner.sendRequest(new VariablesRequest({
        variablesReference: varResponse.body.variables[0].variablesReference
      }));
      expect(varPropResponse.body.variables).toEqual([
        { name: 'age', value: '10', type: 'integer', variablesReference: 0 },
        { name: 'name', value: '1', type: 'integer', variablesReference: 0 },
        {
          name: '[[Prototype]]',
          value: 'object',
          type: '',
          presentationHint: { attributes: [], visibility: 'internal', lazy: false },
          variablesReference: 3
        }
      ]);
      resolve();
    });
  });

  it('should support continue to next breakpoints', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 31,
          column: 0
        }]
      });

      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          {
            name: 'e',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          }
        ]);
        await runner.sendRequest(new SetBreakpointsRequest({
          source: {
            name: 'bundle.js',
            path: '/assets/bundle.js'
          },
          breakpoints: [{
            line: 71,
            column: 0
          }]
        }));
        await runner.sendRequest(new ContinueRequest({
          threadId: threadId!
        }));
      });
      runner.listenerForEventAtBreakpoints(1, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          {
            name: 'this',
            value: 'Blub',
            type: 'object',
            variablesReference: 32768
          },
          { name: 'bbbb', value: 'NaN', type: 'float', variablesReference: 0 }
        ]);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support next operation command', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 5,
          column: 0
        }]
      });

      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          { name: 't', value: '3', type: 'integer', variablesReference: 0 },
          {
            name: 'a',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'b',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'c',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'arr2',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'arr',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'i',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'noob',
            value: 'ƒ noob ()',
            type: 'function',
            variablesReference: 32768
          }
        ]);
        await runner.sendRequest(new NextRequest({
          threadId: threadId!
        }));
      });
      runner.listenerForEventAtBreakpoints(1, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          { name: 't', value: '3', type: 'integer', variablesReference: 0 },
          { name: 'a', value: '55', type: 'integer', variablesReference: 0 },
          {
            name: 'b',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'c',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'arr2',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'arr',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'i',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'noob',
            value: 'ƒ noob ()',
            type: 'function',
            variablesReference: 32768
          }
        ]);
        await runner.sendRequest(new NextRequest({
          threadId: threadId!
        }));
      });
      runner.listenerForEventAtBreakpoints(2, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          { name: 't', value: '3', type: 'integer', variablesReference: 0 },
          { name: 'a', value: '55', type: 'integer', variablesReference: 0 },
          { name: 'b', value: '33', type: 'integer', variablesReference: 0 },
          {
            name: 'c',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'arr2',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'arr',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'i',
            value: 'undefined',
            type: 'undefined',
            variablesReference: 0
          },
          {
            name: 'noob',
            value: 'ƒ noob ()',
            type: 'function',
            variablesReference: 32768
          }
        ]);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support stepIn operation command', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 70,
          column: 0
        }]
      });

      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        await runner.sendRequest(new StepInRequest({
          threadId: threadId!
        }));
      });
      runner.listenerForEventAtBreakpoints(1, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        expect(stackTraceResponse.body.stackFrames[0].name).toEqual('bar');
        expect(stackTraceResponse.body.stackFrames[0].line).toEqual(31);
        expect(stackTraceResponse.body.stackFrames[0].column).toEqual(7);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });

  it('should support stepOut operation command', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();
      const setBreakPointRequest = new SetBreakpointsRequest({
        source: {
          name: 'bundle.js',
          path: '/assets/bundle.js'
        },
        breakpoints: [{
          line: 70,
          column: 0
        }]
      });

      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        await runner.sendRequest(new StepInRequest({
          threadId: threadId!
        }));
      });
      runner.listenerForEventAtBreakpoints(1, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        expect(stackTraceResponse.body.stackFrames[0].name).toEqual('bar');
        expect(stackTraceResponse.body.stackFrames[0].line).toEqual(31);
        expect(stackTraceResponse.body.stackFrames[0].column).toEqual(7);
        await runner.sendRequest(new StepOutRequest({
          threadId: threadId!
        }));
      });
      runner.listenerForEventAtBreakpoints(2, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        expect(stackTraceResponse.body.stackFrames[0].name).toEqual('jib');
        expect(stackTraceResponse.body.stackFrames[0].line).toEqual(71);
        expect(stackTraceResponse.body.stackFrames[0].column).toEqual(11);
        resolve();
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });
});

describe('Debugger keywords', () => {
  beforeEach(async () => {
    process.env.ENTRY_PATH = 'assets:///assets/test_debugger.js'
    await globalThis.reRestartApp();
  });

  it('should stopped at the debugger keywords', async () => {
    return new Promise<void>(async (resolve) => {
      const runner = new DebuggerTestRunner();
      await runner.createConnection();

      runner.listenerForEventAtBreakpoints(0, async (event: DebugProtocol.StoppedEvent) => {
        const threadId = event.body.threadId;
        const stackTraceResponse = await runner.sendRequest(new StackTraceRequest({
          threadId: threadId!
        })) as DebugProtocol.StackTraceResponse;
        const body = stackTraceResponse.body!;
        runner.setStackFrames(body.stackFrames);
        const scopesResponse = await runner.sendRequest(new ScopesRequest({
          frameId: body.stackFrames[0].id
        })) as DebugProtocol.ScopesResponse;
        const vars = await runner.sendRequest(new VariablesRequest({
          variablesReference: scopesResponse.body.scopes[0].variablesReference
        })) as DebugProtocol.VariablesResponse;
        expect(vars.body.variables).toEqual([
          {
            name: 'this',
            value: 'Blub',
            type: 'object',
            variablesReference: 32768
          },
          { name: 'bbbb', value: 'NaN', type: 'float', variablesReference: 0 }
        ]);
        resolve();
      });

      await runner.sendRequest(new ConfigurationDoneRequest());
    });

  });
});
