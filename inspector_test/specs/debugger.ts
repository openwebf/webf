import { InitializedEvent } from '@vscode/debugadapter';
import { client as WebSocketClient } from 'websocket';
import { wrapVScodeExtension, Request, Event, EvaluateRequest, EvaluateResponse } from './utils';

describe('Debugger Test', () => {
  beforeEach(async () => {
    await globalThis.reRestartApp();
  });

  it('test debug server connection', (done) => {
    const client = new WebSocketClient();
    client.on('connect', connection => {
      console.log('Debug Server connected');
      connection.on('message', (message) => {
        if (message.type === 'utf8') {
          console.log('msg', message.utf8Data);
          let event = JSON.parse(message.utf8Data);
          connection.close();
          console.log('call done1..');
          done();
        }
      });
      const request = wrapVScodeExtension(new InitializedEvent());
      connection.send(JSON.stringify(request));
    });
    client.connect(globalThis.DEBUG_HOST_SERVER);
  });

  it('evaluate scripts and return int', (done) => {
    const client = new WebSocketClient();
    client.on('connect', connection => {
      console.log('Debug Server connected');
      let sended = false;
      connection.on('message', (message) => {
        if (message.type === 'utf8') {
          let response: EvaluateResponse = JSON.parse(message.utf8Data);
          if (sended && response.type === 'response') {
            expect(response.request_seq).toBe(request.data.seq);
            expect(response.success).toBe(true);
            expect(response.body.result).toBe('2');
            expect(response.body.type).toBe('integer');
            done();
          }
        }
      });
      const request = wrapVScodeExtension(new EvaluateRequest({
        expression: '1 + 1'
      }));
      connection.send(JSON.stringify(request));
      sended = true;
    });
    client.connect(globalThis.DEBUG_HOST_SERVER);
  });
});
