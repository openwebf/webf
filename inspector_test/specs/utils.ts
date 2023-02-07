import { DebugProtocol } from 'vscode-debugprotocol';
let _seq = 0;

class ProtocolMessage {
  public seq: number;
  public type: string;
  constructor(type: string) {
    this.seq = _seq++;
    this.type = type;
  }
}

export class Request extends ProtocolMessage {
  public command: string;
  public arguments?: any;
  constructor(command: string, args?: any) {
    super('request');
    this.command = command;
    this.arguments = args;
  }
}

export class EvaluateRequest extends Request {
  constructor(args: DebugProtocol.EvaluateArguments) {
    super('evaluate');
    this.arguments = args;
  }
}

export class SetBreakpointsRequest extends Request {
  constructor(args: DebugProtocol.SetBreakpointsArguments) {
    super('setBreakpoints');
    this.arguments = args;
  }
}

export class StackTraceRequest extends Request {
  constructor(args: DebugProtocol.StackTraceArguments) {
    super('stackTrace');
    this.arguments = args;
  }
}

export class ScopesRequest extends Request {
  constructor(args: DebugProtocol.ScopesArguments) {
    super('scopes');
    this.arguments = args;
  }
}

export class VariablesRequest extends Request {
  constructor(args: DebugProtocol.VariablesArguments) {
    super('variables');
    this.arguments = args;
  }
}

export class ConfigurationDoneRequest extends Request {
  constructor() {
    super('configurationDone');
    this.arguments = {};
  }
}

export class Event extends ProtocolMessage {
  constructor(event: string, body?: any) {
    super('event');
    this.event = event;
    this.body = body;
  }

  /**
   * Type of event.
   */
  event: string;

  /**
   * Event-specific information.
   */
  body?: any;
}

export function wrapVScodeExtension<T>(data: T) {
  return {
    vscode: true,
    data: data
  }
}
