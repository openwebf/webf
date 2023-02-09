import EventEmitter from "events";
import { DebugProtocol } from "vscode-debugprotocol";
import { client as WebSocketClient, connection } from 'websocket';
import { wrapVScodeExtension } from "./utils";

let _seq = 0;

interface PendingResponse {
  resolve: Function;
  reject: Function;
}

type StoppedEventHandler = (event: DebugProtocol.StoppedEvent) => Promise<void>;

export class DebuggerTestRunner extends EventEmitter {
  public connection: connection;
  public pendingRequests: Map<number, PendingResponse>;
  private stackFrames: DebugProtocol.StackFrame[];
  private breakpoint_index: number;
  private breakpoint_handlers: StoppedEventHandler[];
  constructor() {
    super();
    this.pendingRequests = new Map();
    this.breakpoint_index = 0;
    this.breakpoint_handlers = [];
    this.stackFrames = [];
    this.on('stopped', this._handleStoppedEvent);
  }

  private _handleStoppedEvent(event: DebugProtocol.StoppedEvent) {
    if (event.body.reason !== 'entry') {
      
      console.assert(!!this.breakpoint_handlers[this.breakpoint_index], `Stopped event handler at index ${this.breakpoint_index} does not exist.`);
      this.breakpoint_handlers[this.breakpoint_index](event);
      this.breakpoint_index++;
    }
  }

  async handleResponse(response: DebugProtocol.Response) {
    let seq = response.request_seq;
    let pending = this.pendingRequests.get(seq);
    if (!pending) {
      return;
    }
    this.pendingRequests.delete(seq);
    pending.resolve(response);
  }

  async handleEvent(event: DebugProtocol.Event) {
    this.emit(event.event, event);
  }

  async createConnection() {
    return new Promise<void>((resolve, reject) => {
      const client = new WebSocketClient();
      client.on('connect', connection => {
        connection.on('message', (message) => {
          if (message.type === 'utf8') {
            let json = JSON.parse(message.utf8Data);
            if (json.type === 'response') {
              this.handleResponse(json);
            } else if (json.type === 'event') {
              this.handleEvent(json);
            }
          }
        });
        this.connection = connection;
        resolve();
      });
      client.connect(globalThis.DEBUG_HOST_SERVER);
    });
  }

  async sendRequest(request: DebugProtocol.Request): Promise<DebugProtocol.Response> {
    return new Promise((resolve, reject) => {
      this.pendingRequests.set(request.seq, {
        resolve,
        reject
      });
      this.connection.send(JSON.stringify(wrapVScodeExtension(request)));
    });
  }

  async setStackFrames(stackFrames: DebugProtocol.StackFrame[]) {
    this.stackFrames = stackFrames;
  }

  async listenerForEventAtBreakpoints(breakPointHitIndex: number, handler: StoppedEventHandler) {
    this.breakpoint_handlers[breakPointHitIndex] = handler;
  }

}


