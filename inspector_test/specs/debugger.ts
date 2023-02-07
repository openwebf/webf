import { InitializedEvent } from '@vscode/debugadapter';
import { client as WebSocketClient, connection } from 'websocket';
import { ConfigurationDoneRequest, EvaluateRequest, ScopesRequest, SetBreakpointsRequest, StackTraceRequest, VariablesRequest, wrapVScodeExtension } from './utils';
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
      runner.on('stopped', (event: DebugProtocol.StoppedEvent) => {
        if (event.body.reason === 'breakpoint') {
          resolve();
        }
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
      runner.on('stopped', async(event: DebugProtocol.StoppedEvent) => {
        if (event.body.reason === 'breakpoint') {
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
        }
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
      runner.on('stopped', async(event: DebugProtocol.StoppedEvent) => {
        if (event.body.reason === 'breakpoint') {
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
        }
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
      runner.on('stopped', async(event: DebugProtocol.StoppedEvent) => {
        if (event.body.reason === 'breakpoint') {
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
        }
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
      runner.on('stopped', async(event: DebugProtocol.StoppedEvent) => {
        if (event.body.reason === 'breakpoint') {
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
        }
      });
      await runner.sendRequest(setBreakPointRequest);
      await runner.sendRequest(new ConfigurationDoneRequest());
    });
  });
});
