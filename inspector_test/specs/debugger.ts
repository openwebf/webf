import { client as WebSocketClient } from 'websocket';
import { buildRequest, checkEvent } from './utils';

describe('Debugger Test', () => {
  fit('test debug server connection', (done) => {
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
      connection.on('message', (message) => {
        if (message.type === 'utf8') {
          console.log('msg', message.utf8Data);
          let event = JSON.parse(message.utf8Data);
          checkEvent(event, 'StoppedEvent');
          connection.close();
          done();
        }
      });
      connection.send(JSON.stringify(buildRequest('initialize', {
        'clientID': 'inspector_test'
      })));
    });
    client.connect(globalThis.DEBUG_HOST_SERVER);
  });

  // it('set breakpoints and continue', (done) => {
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

  //         // connection.send(buildBreakpointMessage(
  //         //   'assets://assets/bundle.js',
  //         //   [{
  //         //     line: 10,
  //         //     column: 0
  //         //   }]
  //         // ));
  //         // connection.send(buildStopOnException())
  //         // connection.send(buildContinue());
  //       }
  //     });
  //     connection.send(JSON.stringify({ vscode: true, data: null}));
  //   });
  //   client.connect(globalThis.DEBUG_HOST_SERVER);
  // });
});
