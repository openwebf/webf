
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

interface Response extends ProtocolMessage {
  type: 'response';

  /**
   * Sequence number of the corresponding request.
   */
  request_seq: number;

  /**
   * Outcome of the request.
   * If true, the request was successful and the `body` attribute may contain
   * the result of the request.
   * If the value is false, the attribute `message` contains the error in short
   * form and the `body` may contain additional information (see
   * `ErrorResponse.body.error`).
   */
  success: boolean;

  /**
   * The command requested.
   */
  command: string;

  /**
   * Contains the raw error in short form if `success` is false.
   * This raw error might be interpreted by the client and is not shown in the
   * UI.
   * Some predefined values exist.
   * Values:
   * 'cancelled': the request was cancelled.
   * 'notStopped': the request may be retried once the adapter is in a 'stopped'
   * state.
   * etc.
   */
  message?: 'cancelled' | 'notStopped' | string;

  /**
   * Contains request result if success is true and error details if success is
   * false.
   */
  body?: any;
}

interface ValueFormat {
  /**
   * Display the value in hex.
   */
  hex?: boolean;
}

interface VariablePresentationHint {
  /**
   * The kind of variable. Before introducing additional values, try to use the
   * listed values.
   * Values:
   * 'property': Indicates that the object is a property.
   * 'method': Indicates that the object is a method.
   * 'class': Indicates that the object is a class.
   * 'data': Indicates that the object is data.
   * 'event': Indicates that the object is an event.
   * 'baseClass': Indicates that the object is a base class.
   * 'innerClass': Indicates that the object is an inner class.
   * 'interface': Indicates that the object is an interface.
   * 'mostDerivedClass': Indicates that the object is the most derived class.
   * 'virtual': Indicates that the object is virtual, that means it is a
   * synthetic object introduced by the adapter for rendering purposes, e.g. an
   * index range for large arrays.
   * 'dataBreakpoint': Deprecated: Indicates that a data breakpoint is
   * registered for the object. The `hasDataBreakpoint` attribute should
   * generally be used instead.
   * etc.
   */
  kind?: 'property' | 'method' | 'class' | 'data' | 'event' | 'baseClass'
      | 'innerClass' | 'interface' | 'mostDerivedClass' | 'virtual'
      | 'dataBreakpoint' | string;

  /**
   * Set of attributes represented as an array of strings. Before introducing
   * additional values, try to use the listed values.
   * Values:
   * 'static': Indicates that the object is static.
   * 'constant': Indicates that the object is a constant.
   * 'readOnly': Indicates that the object is read only.
   * 'rawString': Indicates that the object is a raw string.
   * 'hasObjectId': Indicates that the object can have an Object ID created for
   * it.
   * 'canHaveObjectId': Indicates that the object has an Object ID associated
   * with it.
   * 'hasSideEffects': Indicates that the evaluation had side effects.
   * 'hasDataBreakpoint': Indicates that the object has its value tracked by a
   * data breakpoint.
   * etc.
   */
  attributes?: ('static' | 'constant' | 'readOnly' | 'rawString' | 'hasObjectId'
      | 'canHaveObjectId' | 'hasSideEffects' | 'hasDataBreakpoint' | string)[];

  /**
   * Visibility of variable. Before introducing additional values, try to use
   * the listed values.
   * Values: 'public', 'private', 'protected', 'internal', 'final', etc.
   */
  visibility?: 'public' | 'private' | 'protected' | 'internal' | 'final' | string;

  /**
   * If true, clients can present the variable with a UI that supports a
   * specific gesture to trigger its evaluation.
   * This mechanism can be used for properties that require executing code when
   * retrieving their value and where the code execution can be expensive and/or
   * produce side-effects. A typical example are properties based on a getter
   * function.
   * Please note that in addition to the `lazy` flag, the variable's
   * `variablesReference` is expected to refer to a variable that will provide
   * the value through another `variable` request.
   */
  lazy?: boolean;
}

export interface EvaluateResponse extends Response {
  body: {
    /**
     * The result of the evaluate request.
     */
    result: string;

    /**
     * The type of the evaluate result.
     * This attribute should only be returned by a debug adapter if the
     * corresponding capability `supportsVariableType` is true.
     */
    type?: string;

    /**
     * Properties of an evaluate result that can be used to determine how to
     * render the result in the UI.
     */
    presentationHint?: VariablePresentationHint;

    /**
     * If `variablesReference` is > 0, the evaluate result is structured and its
     * children can be retrieved by passing `variablesReference` to the
     * `variables` request as long as execution remains suspended. See 'Lifetime
     * of Object References' in the Overview section for details.
     */
    variablesReference: number;

    /**
     * The number of named child variables.
     * The client can use this information to present the variables in a paged
     * UI and fetch them in chunks.
     * The value should be less than or equal to 2147483647 (2^31-1).
     */
    namedVariables?: number;

    /**
     * The number of indexed child variables.
     * The client can use this information to present the variables in a paged
     * UI and fetch them in chunks.
     * The value should be less than or equal to 2147483647 (2^31-1).
     */
    indexedVariables?: number;

    /**
     * A memory reference to a location appropriate for this result.
     * For pointer type eval results, this is generally a reference to the
     * memory address contained in the pointer.
     * This attribute should be returned by a debug adapter if corresponding
     * capability `supportsMemoryReferences` is true.
     */
    memoryReference?: string;
  };
}

interface EvaluateArguments {
  /**
   * The expression to evaluate.
   */
  expression: string;

  /**
   * Evaluate the expression in the scope of this stack frame. If not specified,
   * the expression is evaluated in the global scope.
   */
  frameId?: number;

  /**
   * The context in which the evaluate request is used.
   * Values:
   * 'watch': evaluate is called from a watch view context.
   * 'repl': evaluate is called from a REPL context.
   * 'hover': evaluate is called to generate the debug hover contents.
   * This value should only be used if the corresponding capability
   * `supportsEvaluateForHovers` is true.
   * 'clipboard': evaluate is called to generate clipboard contents.
   * This value should only be used if the corresponding capability
   * `supportsClipboardContext` is true.
   * 'variables': evaluate is called from a variables view context.
   * etc.
   */
  context?: 'watch' | 'repl' | 'hover' | 'clipboard' | 'variables' | string;

  /**
   * Specifies details on how to format the result.
   * The attribute is only honored by a debug adapter if the corresponding
   * capability `supportsValueFormattingOptions` is true.
   */
  format?: ValueFormat;
}


export class EvaluateRequest extends Request {
  constructor(args: EvaluateArguments) {
    super('evaluate');
    this.arguments = args;
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

// export function buildRequest(command: string, args: any) {
//   return wrapVScodeExtension({
//     arguments: args,
//     type: 'request',
//     command: command,
//     seq: _seq++
//   });
// }

// export function buildBreakpointMessage(path: string, breakpoints: { line: number, column: number }[]) {
//   return JSON.stringify(wrapVScodeExtension({
//     type: ''
//   }))
// }

// export function buildStopOnException(enabled: boolean = false) {
//   return JSON.stringify(wrapVScodeExtension({
//     type: 'stopOnException',
//     stopOnException: enabled
//   }))
// }

// export function buildContinue() {
//   return JSON.stringify(wrapVScodeExtension({
//     type: 'continue'
//   }));
// }

// export function checkEvent(event: any, type: string) {
//   expect(event.type).toBe('event');
//   expect(event.event.type).toBe(type);
// }
