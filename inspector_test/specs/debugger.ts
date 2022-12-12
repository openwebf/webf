import { client as WebSocketClient } from 'websocket';

describe('Debugger Test', () => {
  it('test debug server connection', (done) => {
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
          let data = JSON.parse(message.utf8Data);
          expect(data.type).toBe('event');
          expect(data.event.type).toBe('StoppedEvent');
          connection.close();
          done();
        }
      });
      connection.send(JSON.stringify({ vscode: true, data: null}));
    });
    client.connect(globalThis.DEBUG_HOST_SERVER);
  });
});
