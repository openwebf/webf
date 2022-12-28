import { client as WebSocketClient } from 'websocket';
import { wrapVScodeExtension, Request, Event, EvaluateRequest, EvaluateResponse } from './utils';

describe('Debugger Test', () => {
  // it('test debug server connection', (done) => {
  //   const client = new WebSocketClient();
  //   client.on('connect', connection => {
  //     console.log('Debug Server connected');
  //     connection.on('error', function (error) {
  //       console.log("Connection Error: " + error.toString());
  //       done.fail();
  //     });
  //     connection.on('close', function () {
  //       console.log('echo-protocol Connection Closed');
  //       done.fail();
  //     });
  //     connection.on('message', (message) => {
  //       if (message.type === 'utf8') {
  //         console.log('msg', message.utf8Data);
  //         let event = JSON.parse(message.utf8Data);
  //         checkEvent(event, 'StoppedEvent');
  //         connection.close();
  //         done();
  //       }
  //     });
  //     connection.send(JSON.stringify(buildRequest('initialize', {
  //       'clientID': 'inspector_test'
  //     })));
  //   });
  //   client.connect(globalThis.DEBUG_HOST_SERVER);
  // });

  fit('evaluate scripts and return int', (done) => {
    const client = new WebSocketClient();
    client.on('connect', connection => {
      console.log('Debug Server connected');
      connection.on('error', function (error) {
        console.log("Connection Error: " + error.toString());
        done.fail();
      });
      connection.on('close', function () {
        console.log('echo-protocol Connection Closed');
        done.fail();
      });
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
